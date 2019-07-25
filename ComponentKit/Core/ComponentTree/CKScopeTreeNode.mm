/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKScopeTreeNode.h"

#import <algorithm>
#import <unordered_map>

#import "CKThreadLocalComponentScope.h"

static NSUInteger const kParentBaseKey = 0;
static NSUInteger const kOwnerBaseKey = 1;

static bool keyVectorsEqual(const std::vector<id<NSObject>> &a, const std::vector<id<NSObject>> &b)
{
  if (a.size() != b.size()) {
    return false;
  }
  return std::equal(a.begin(), a.end(), b.begin(), [](id<NSObject> x, id<NSObject> y){
    return CKObjectIsEqual(x, y); // be pedantic and use a lambda here becuase BOOL != bool
  });
}

struct CKScopeNodeKey {
  CKTreeNodeComponentKey nodeKey;
  std::vector<id<NSObject>> keys;

  bool operator==(const CKScopeNodeKey &v) const {
    return std::get<0>(this->nodeKey) == std::get<0>(v.nodeKey) &&
    std::get<1>(this->nodeKey) == std::get<1>(v.nodeKey) &&
    CKObjectIsEqual(std::get<2>(this->nodeKey), std::get<2>(v.nodeKey)) &&
    keyVectorsEqual(this->keys, v.keys);
  }
};

namespace std {
  template <>
  struct hash<CKScopeNodeKey> {
    size_t operator ()(CKScopeNodeKey k) const {
      // Note we just use k.keys.size() for the hash of keys. Otherwise we'd have to enumerate over each item and
      // call [NSObject -hash] on it and incorporate every element into the overall hash somehow.
      auto const nodeKey = k.nodeKey;
      NSUInteger subhashes[] = { [std::get<0>(nodeKey) hash], std::get<1>(nodeKey), [std::get<2>(nodeKey) hash], k.keys.size() };
      return CKIntegerArrayHash(subhashes, CK_ARRAY_COUNT(subhashes));
    }
  };
}

@implementation CKScopeTreeNode
{
  std::unordered_map<CKScopeNodeKey, id<CKTreeNodeProtocol>> _children;
  CKTreeNodeKeyToCounter _keyToCounterMap;
}

#pragma mark - CKTreeNodeWithChildrenProtocol

- (std::vector<id<CKTreeNodeProtocol>>)children
{
  std::vector<id<CKTreeNodeProtocol>> children;
  for (auto const &child : _children) {
    if (std::get<1>(child.first.nodeKey) % 2 == kParentBaseKey) {
      children.push_back(child.second);
    }
  }
  return children;
}

- (size_t)childrenSize
{
  return _children.size();
}

- (CKTreeNode *)childForComponentKey:(const CKTreeNodeComponentKey &)key
{
  CKScopeNodeKey stateKey = {key};
  auto const it = _children.find(stateKey);
  if (it != _children.end()) {
    return it->second;
  }
  return nil;
}

- (CKTreeNodeComponentKey)createComponentKeyForChildWithClass:(id<CKComponentProtocol>)componentClass
                                                   identifier:(id<NSObject>)identifier
{
  // Create **parent** based key counter.
  auto const keyCounter = parentKeyCounter(componentClass, identifier, _keyToCounterMap);
  return std::make_tuple(componentClass, keyCounter, identifier);
}

- (void)setChild:(CKTreeNode *)child forComponentKey:(const CKTreeNodeComponentKey &)componentKey
{
  _children[{componentKey}] = child;
}

- (void)didReuseInScopeRoot:(CKComponentScopeRoot *)scopeRoot fromPreviousScopeRoot:(CKComponentScopeRoot *)previousScopeRoot
{
  // In case that CKComponentScope was created, but not acquired from the component (for example: early nil return) ,
  // the component was never linked to the scope handle/tree node, hence, we should stop the recursion here.
  if (self.handle.acquiredComponent == nil) {
    return;
  }

  [super didReuseInScopeRoot:scopeRoot fromPreviousScopeRoot:previousScopeRoot];
  for (auto const &child : _children) {
    if (std::get<1>(child.first.nodeKey) % 2 == kParentBaseKey) {
      [child.second didReuseInScopeRoot:scopeRoot fromPreviousScopeRoot:previousScopeRoot];
    }
  }
}

#pragma mark - CKComponentScopeFrameProtocol

+ (CKComponentScopeFramePair)childPairForPair:(const CKComponentScopeFramePair &)pair
                                      newRoot:(CKComponentScopeRoot *)newRoot
                               componentClass:(Class<CKComponentProtocol>)componentClass
                                   identifier:(id)identifier
                                         keys:(const std::vector<id<NSObject>> &)keys
                          initialStateCreator:(id (^)(void))initialStateCreator
                                 stateUpdates:(const CKComponentStateUpdateMap &)stateUpdates
{
  CKScopeTreeNode *frame = (CKScopeTreeNode *)pair.frame;
  CKScopeTreeNode *previousFrame = (CKScopeTreeNode *)pair.previousFrame;

  CKAssertNotNil(frame, @"Must have frame");
  CKAssert(frame.class == [CKScopeTreeNode class], @"frame should be CKScopeTreeNode instead of %@", frame.class);
  CKAssert(previousFrame == nil || previousFrame.class == [CKScopeTreeNode class], @"previousFrame should be CKScopeTreeNode instead of %@", previousFrame.class);

  // Create **owner** based key counter.
  auto const keyCounter = ownerKeyCounter(componentClass, identifier, frame->_keyToCounterMap);
  // Update the stateKey with the class key counter to make sure we don't have collisions.
  CKScopeNodeKey stateKey = {std::make_tuple(componentClass, keyCounter, identifier), keys};

  // Get the child from the previous equivalent node.
  CKScopeTreeNode *existingChildNodeOfPreviousNode;
  if (previousFrame) {
    const auto &previousNodeChildren = previousFrame->_children;
    const auto it = previousNodeChildren.find(stateKey);
    existingChildNodeOfPreviousNode = (it == previousNodeChildren.end()) ? nil : (CKScopeTreeNode *)it->second;
  }

  // Create new handle.
  CKComponentScopeHandle *newHandle = existingChildNodeOfPreviousNode
  ? [existingChildNodeOfPreviousNode.handle newHandleWithStateUpdates:stateUpdates componentScopeRoot:newRoot]
  : [[CKComponentScopeHandle alloc] initWithListener:newRoot.listener
                                      rootIdentifier:newRoot.globalIdentifier
                                      componentClass:componentClass
                                        initialState:(initialStateCreator ? initialStateCreator() : [componentClass initialState])];

  // Create new node.
  CKScopeTreeNode *newChild = [[CKScopeTreeNode alloc]
                               initWithPreviousNode:existingChildNodeOfPreviousNode
                               handle:newHandle];

  // Insert the new node to its parent map.
  frame->_children.insert({stateKey, newChild});
  return {.frame = newChild, .previousFrame = existingChildNodeOfPreviousNode};
}

+ (void)willBuildComponentTreeWithTreeNode:(id<CKTreeNodeProtocol>)node
{
  auto const threadLocalScope = CKThreadLocalComponentScope::currentScope();
  if (threadLocalScope == nullptr) {
    return;
  }

  // Create a unique key based on the tree node identifier and the component class.
  CKScopeNodeKey stateKey = {std::make_tuple([node.component class], 0, @(node.nodeIdentifier))};

  // Get the frame from the previous generation if it exists.
  CKComponentScopeFramePair &pair = threadLocalScope->stack.top();

  CKScopeTreeNode *childFrameOfPreviousFrame;
  CKScopeTreeNode *frame = (CKScopeTreeNode *)pair.frame;
  CKScopeTreeNode *previousFrame = (CKScopeTreeNode *)pair.previousFrame;

  CKAssert(frame.class == [CKScopeTreeNode class], @"frame should be CKScopeTreeNode instead of %@", frame.class);
  CKAssert(previousFrame == nil || previousFrame.class == [CKScopeTreeNode class], @"previousFrame should be CKScopeTreeNode instead of %@", previousFrame.class);

  if (previousFrame) {
    const auto &previousFrameChildren = previousFrame->_children;
    const auto it = previousFrameChildren.find(stateKey);
    childFrameOfPreviousFrame = (it == previousFrameChildren.end()) ? nil : (CKScopeTreeNode *)it->second;
  }

  // Create a scope frame for the render component children.
  CKScopeTreeNode *newFrame = [[CKScopeTreeNode alloc] init];
  // Push the new scope frame to the parent frame's children.
  frame->_children.insert({stateKey, newFrame});
  // Push the new pair into the thread local.
  threadLocalScope->stack.push({.frame = newFrame, .previousFrame = childFrameOfPreviousFrame});
}

+ (void)didBuildComponentTreeWithNode:(id<CKTreeNodeProtocol>)node
{
  auto const threadLocalScope = CKThreadLocalComponentScope::currentScope();
  if (threadLocalScope == nullptr) {
    return;
  }

  CKAssert(!threadLocalScope->stack.empty() && threadLocalScope->stack.top().frame.handle == node.handle, @"frame.handle is not equal to node.handle");
  // Pop the top element of the stack.
  threadLocalScope->stack.pop();
}

+ (void)didReuseRenderWithTreeNode:(id<CKTreeNodeProtocol>)node
{
  auto const threadLocalScope = CKThreadLocalComponentScope::currentScope();
  if (threadLocalScope == nullptr) {
    return;
  }

  // Create a unique key based on the tree node identifier and the component class.
  CKScopeNodeKey stateKey = {std::make_tuple([node.component class], 0, @(node.nodeIdentifier))};

  // Get the frame from the previous generation if it exists.
  CKComponentScopeFramePair &pair = threadLocalScope->stack.top();

  CKScopeTreeNode *childFrameOfPreviousFrame;
  CKScopeTreeNode *frame = (CKScopeTreeNode *)pair.frame;
  CKScopeTreeNode *previousFrame = (CKScopeTreeNode *)pair.previousFrame;

  CKAssert(frame.class == [CKScopeTreeNode class], @"frame should be CKScopeTreeNode instead of %@", frame.class);
  CKAssert(previousFrame == nil || previousFrame.class == [CKScopeTreeNode class], @"previousFrame should be CKScopeTreeNode instead of %@", previousFrame.class);

  if (previousFrame) {
    const auto &previousFrameChildren = previousFrame->_children;
    const auto it = previousFrameChildren.find(stateKey);
    childFrameOfPreviousFrame = (it == previousFrameChildren.end()) ? nil : (CKScopeTreeNode *)it->second;
  }

  // Transfer the previous frame into the parent from the new generation.
  if (childFrameOfPreviousFrame) {
    frame->_children.insert({stateKey, childFrameOfPreviousFrame});
  }
}

#pragma mark - Helpers

static NSUInteger parentKeyCounter(id<CKComponentProtocol> componentClass,
                                  id<NSObject> identifier,
                                  CKTreeNodeKeyToCounter &keyToCounterMap) {
  
  // Create key to retrive the counter of the CKScopeNodeKey (in case of identical key, we increment it to avoid collisions).
  CKTreeNodeComponentKey componentKey = std::make_tuple(componentClass, kParentBaseKey, identifier);
  // We use even numbers to represent **parent** based keys (0,2,4,..).
  return (keyToCounterMap[componentKey]++) * 2;
}

static NSUInteger ownerKeyCounter(id<CKComponentProtocol> componentClass,
                                  id<NSObject> identifier,
                                  CKTreeNodeKeyToCounter &keyToCounterMap) {
  // Create key to retrive the counter of the CKScopeNodeKey (in case of identical key, we incrment it to avoid collisions).
  CKTreeNodeComponentKey componentKey = std::make_tuple(componentClass, kOwnerBaseKey, identifier);
  // We use odd numbers to represent **owner** based keys (1,3,5,..).
  return (keyToCounterMap[componentKey]++) * 2 + 1;
}

#if DEBUG
// Iterate threw the nodes according to the **parent** based key
- (NSArray<NSString *> *)debugDescriptionNodes
{
  NSMutableArray<NSString *> *debugDescriptionNodes = [NSMutableArray arrayWithArray:[super debugDescriptionNodes]];
  for (auto const &child : _children) {
    if (std::get<1>(child.first.nodeKey) % 2 == kParentBaseKey) {
      for (NSString *s in [child.second debugDescriptionNodes]) {
        [debugDescriptionNodes addObject:[@"  " stringByAppendingString:s]];
      }
    }
  }
  return debugDescriptionNodes;
}

// Iterate threw the nodes according to the **owner** based key
- (NSArray<NSString *> *)debugDescriptionComponents
{
  NSMutableArray<NSString *> *childrenDebugDescriptions = [NSMutableArray new];
  for (auto const &child : _children) {
    if (std::get<1>(child.first.nodeKey) % 2 == kOwnerBaseKey) {
      auto const description = [NSString stringWithFormat:@"- %@%@%@",
                                NSStringFromClass(std::get<0>(child.first.nodeKey)),
                                (std::get<2>(child.first.nodeKey)
                                 ? [NSString stringWithFormat:@":%@", std::get<2>(child.first.nodeKey)]
                                 : @""),
                                child.first.keys.empty() ? @"" : formatKeys(child.first.keys)];
      [childrenDebugDescriptions addObject:description];
      for (NSString *s in [(id<CKComponentScopeFrameProtocol>)child.second debugDescriptionComponents]) {
        [childrenDebugDescriptions addObject:[@"  " stringByAppendingString:s]];
      }
    }
  }
  return childrenDebugDescriptions;
}

static NSString *formatKeys(const std::vector<id<NSObject>> &keys)
{
  NSMutableArray<NSString *> *a = [NSMutableArray new];
  for (auto key : keys) {
    [a addObject:[key description] ?: @"(null)"];
  }
  return [a componentsJoinedByString:@", "];
}

#endif
@end
