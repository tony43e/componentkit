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

#import <ComponentKit/CKGlobalConfig.h>

#import "CKThreadLocalComponentScope.h"
#import "CKTreeNodeProtocol.h"

@implementation CKScopeTreeNode

#pragma mark - CKTreeNodeWithChildrenProtocol

- (std::vector<id<CKTreeNodeProtocol>>)children
{
  std::vector<id<CKTreeNodeProtocol>> children;
  for (auto const &child : _children) {
    if (child.key.type() == CKTreeNodeComponentKey::Type::parent) {
      children.push_back(child.node);
    }
  }
  return children;
}

- (size_t)childrenSize
{
  return _children.size();
}

- (id<CKTreeNodeProtocol>)childForComponentKey:(const CKTreeNodeComponentKey &)key
{
  for (auto const &child : _children) {
    if (child.key == key) {
      return child.node;
    }
  }
  return nil;
}

- (CKTreeNodeComponentKey)createParentKeyForComponentTypeName:(const char *)componentTypeName
                                                   identifier:(id<NSObject>)identifier
                                                         keys:(const std::vector<id<NSObject>> &)keys
{
  // Create **parent** based key counter.
  NSUInteger keyCounter = CKTreeNodeComponentKey::kCounterParentOffset;
  for (auto const &child : _children) {
    if (child.key.componentTypeName == componentTypeName && RCObjectIsEqual(child.key.identifier, identifier)) {
      keyCounter += 2;
    }
  }

  return CKTreeNodeComponentKey{componentTypeName, keyCounter, identifier, keys};
}

- (void)setChild:(id<CKTreeNodeProtocol>)child forComponentKey:(const CKTreeNodeComponentKey &)componentKey
{
  _children.push_back(CKTreeNodeComponentKeyToNode{.key = componentKey, .node = child});
}

- (void)didReuseWithParent:(id<CKTreeNodeProtocol>)parent
               inScopeRoot:(CKComponentScopeRoot *)scopeRoot
{
  // In case that CKComponentScope was created, but not acquired from the component (for example: early nil return) ,
  // the component was never linked to the scope handle/tree node, hence, we should stop the recursion here.
  if (self.component == nil) {
    return;
  }

  [super didReuseWithParent:parent inScopeRoot:scopeRoot];

  for (auto const &child : _children) {
    if (child.key.type() == CKTreeNodeComponentKey::Type::parent) {
      [child.node didReuseWithParent:self inScopeRoot:scopeRoot];
    }
  }
}

- (CKTreeNodeComponentKey)createKeyForComponentTypeName:(const char *)componentTypeName
                                             identifier:(id)identifier
                                                   keys:(const std::vector<id<NSObject>> &)keys
{
  // Create **owner** based key counter.
  NSUInteger keyCounter = CKTreeNodeComponentKey::kCounterOwnerOffset;
  for (auto const &child : _children) {
    if (child.key.componentTypeName == componentTypeName && RCObjectIsEqual(child.key.identifier, identifier)) {
      keyCounter += 2;
    }
  }
  // Update the stateKey with the type name key counter to make sure we don't have collisions.
  return CKTreeNodeComponentKey{componentTypeName, keyCounter, identifier, keys};
}

- (CKScopeTreeNode *)childScopeForComponentKey:(const CKTreeNodeComponentKey &)key
{
  return (CKScopeTreeNode *)[self childForComponentKey:key];
}

- (void)setChildScope:(CKScopeTreeNode *)child forComponentKey:(const CKTreeNodeComponentKey &)componentKey
{
  _children.push_back(CKTreeNodeComponentKeyToNode{.key = componentKey, .node = child});
}

+ (CKComponentScopePair)childPairForPair:(const CKComponentScopePair &)pair
                                 newRoot:(CKComponentScopeRoot *)newRoot
                       componentTypeName:(const char *)componentTypeName
                              identifier:(id)identifier
                                    keys:(const std::vector<id<NSObject>> &)keys
                     initialStateCreator:(id (^)(void))initialStateCreator
                            stateUpdates:(const CKComponentStateUpdateMap &)stateUpdates
                     requiresScopeHandle:(BOOL)requiresScopeHandle
{
  RCAssertNotNil(pair.node, @"Must have a node");
  RCAssertNotNil(initialStateCreator, @"Must has an initial state creator");

  // Generate key inside the new parent
  CKTreeNodeComponentKey componentKey = [pair.node createKeyForComponentTypeName:componentTypeName
                                                                      identifier:identifier
                                                                            keys:keys];
  // Get the child from the previous equivalent scope.
  CKScopeTreeNode *childScopeFromPreviousScope = [pair.previousNode childScopeForComponentKey:componentKey];

  return [self childPairForPair:pair
                        newRoot:newRoot
              componentTypeName:componentTypeName
                   componentKey:componentKey
    childScopeFromPreviousNode:childScopeFromPreviousScope
            initialStateCreator:initialStateCreator
                   stateUpdates:stateUpdates
            requiresScopeHandle:requiresScopeHandle];
}

+ (CKComponentScopePair)childPairForPair:(const CKComponentScopePair &)pair
                                 newRoot:(CKComponentScopeRoot *)newRoot
                       componentTypeName:(const char *)componentTypeName
                            componentKey:(const CKTreeNodeComponentKey &)componentKey
              childScopeFromPreviousNode:(CKScopeTreeNode *)childScopeFromPreviousScope
                     initialStateCreator:(id (^)(void))initialStateCreator
                            stateUpdates:(const CKComponentStateUpdateMap &)stateUpdates
                     requiresScopeHandle:(BOOL)requiresScopeHandle
{
  RCAssertNotNil(pair.node, @"Must have a node");
  RCAssertNotNil(initialStateCreator, @"Must has an initial state creator");

  // Create new handle.
  CKComponentScopeHandle *newHandle;

  if (childScopeFromPreviousScope != nil) {
    newHandle = [childScopeFromPreviousScope.scopeHandle newHandleWithStateUpdates:stateUpdates];
  } else if (requiresScopeHandle) {
    newHandle = [[CKComponentScopeHandle alloc] initWithListener:newRoot.listener
                                                  rootIdentifier:newRoot.globalIdentifier
                                               componentTypeName:componentTypeName
                                                    initialState:(initialStateCreator ? initialStateCreator() : nil)];
  }

  RCAssert((newHandle != nil) == requiresScopeHandle, @"Expecting scopeHandle (%@) to be [un]set for requiresScopeHandleValue", newHandle);

  // Create new node.
  CKScopeTreeNode *newChild = [[CKScopeTreeNode alloc]
                               initWithPreviousNode:childScopeFromPreviousScope
                               scopeHandle:newHandle];

  // Link the tree node to the scope handle.
  [newHandle setTreeNode:newChild];

  // Insert the new node to its parent map.
  [pair.node setChildScope:newChild forComponentKey:componentKey];

  // Update the component key on the new child.
  newChild->_componentKey = componentKey;
  return {.node = newChild, .previousNode = childScopeFromPreviousScope};
}

#pragma mark - Helpers

#if DEBUG
// Iterate threw the nodes according to the **parent** based key
- (NSArray<NSString *> *)debugDescriptionNodes
{
  NSMutableArray<NSString *> *debugDescriptionNodes = [NSMutableArray arrayWithArray:[super debugDescriptionNodes]];
  for (auto const &child : _children) {
    if (child.key.type() == CKTreeNodeComponentKey::Type::parent) {
      for (NSString *s in [child.node debugDescriptionNodes]) {
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
    if (child.key.type() == CKTreeNodeComponentKey::Type::owner) {
      auto const description = [NSString stringWithFormat:@"- %s%@%@",
                                child.key.componentTypeName,
                                (child.key.identifier
                                 ? [NSString stringWithFormat:@":%@", child.key.identifier]
                                 : @""),
                                child.key.keys.empty() ? @"" : formatKeys(child.key.keys)];
      [childrenDebugDescriptions addObject:description];
      for (NSString *s in [(CKScopeTreeNode *)child.node debugDescriptionComponents]) {
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
