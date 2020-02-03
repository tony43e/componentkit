/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKRenderComponent.h"

#import <ComponentKit/CKGlobalConfig.h>
#import <ComponentKit/CKInternalHelpers.h>
#import <ComponentKit/CKMutex.h>

#import "CKBuildComponent.h"
#import "CKComponentInternal.h"
#import "CKComponentSubclass.h"
#import "CKRenderHelpers.h"
#import "CKTreeNode.h"

@implementation CKRenderComponent
{
  CKComponent *_child;
}

#if DEBUG
+ (void)initialize
{
  if (self != [CKRenderComponent class]) {
    CKAssert(!CKSubclassOverridesInstanceMethod([CKRenderComponent class], self, @selector(computeLayoutThatFits:)),
             @"%@ overrides -computeLayoutThatFits: which is not allowed. "
             "Consider subclassing CKLayoutComponent directly if you need to perform custom layout.",
             self);
    CKAssert(!CKSubclassOverridesInstanceMethod([CKRenderComponent class], self, @selector(layoutThatFits:parentSize:)),
             @"%@ overrides -layoutThatFits:parentSize: which is not allowed. "
             "Consider subclassing CKLayoutComponent directly if you need to perform custom layout.",
             self);
  }
}
#endif

+ (instancetype)new
{
  return [super newRenderComponentWithView:{} size:{}];
}

+ (instancetype)newWithView:(const CKComponentViewConfiguration &)view
                       size:(const CKComponentSize &)size
{
  return [super newRenderComponentWithView:view size:size];
}

- (CKComponent *)render:(id)state
{
  CKFailAssert(@"%@ MUST override the '%@' method.", [self class], NSStringFromSelector(_cmd));
  return nil;
}

- (void)buildComponentTree:(id<CKTreeNodeWithChildrenProtocol>)parent
            previousParent:(id<CKTreeNodeWithChildrenProtocol> _Nullable)previousParent
                    params:(const CKBuildComponentTreeParams &)params
      parentHasStateUpdate:(BOOL)parentHasStateUpdate
{
  // Build the component tree.
  auto const node = CKRender::ComponentTree::Render::build(self, &_child, parent, previousParent, params, parentHasStateUpdate, nil);
  auto const viewConfiguration = [self viewConfigurationWithState:node.state];
  if (!viewConfiguration.isDefaultConfiguration()) {
    [self setViewConfiguration:viewConfiguration];
  }
}

- (CKComponentLayout)computeLayoutThatFits:(CKSizeRange)constrainedSize
                          restrictedToSize:(const CKComponentSize &)size
                      relativeToParentSize:(CGSize)parentSize
{
  CKAssert(size == CKComponentSize(),
           @"CKRenderComponent only passes size {} to the super class initializer, but received size %@ "
           "(component=%@)", size.description(), _child);

  if (_child) {
    CKComponentLayout l = [_child layoutThatFits:constrainedSize parentSize:parentSize];
    return {self, l.size, {{{0,0}, l}}};
  }
  return [super computeLayoutThatFits:constrainedSize restrictedToSize:size relativeToParentSize:parentSize];
}

- (CKComponent *)child
{
  return _child;
}

#pragma mark - CKRenderComponentProtocol

+ (id)initialStateWithComponent:(id<CKRenderComponentProtocol>)component
{
  return [self initialState];
}

+ (id)initialState
{
  return CKTreeNodeEmptyState();
}

- (BOOL)shouldComponentUpdate:(id<CKRenderComponentProtocol>)component
{
  return YES;
}

- (void)didReuseComponent:(id<CKRenderComponentProtocol>)component {}

- (CKComponentViewConfiguration)viewConfigurationWithState:(id)state
{
  return {};
}

- (id _Nullable)componentIdentifier
{
  return nil;
}

+ (BOOL)requiresScopeHandle
{
  const Class componentClass = self;

  static CK::StaticMutex mutex = CK_MUTEX_INITIALIZER; // protects cache
  CK::StaticMutexLocker l(mutex);

  static std::unordered_map<Class, BOOL> *cache = new std::unordered_map<Class, BOOL>();
  const auto &it = cache->find(componentClass);
  if (it == cache->end()) {
    BOOL hasAnimations = NO;
    if (CKSubclassOverridesInstanceMethod([CKComponent class], componentClass, @selector(animationsFromPreviousComponent:)) ||
        CKSubclassOverridesInstanceMethod([CKComponent class], componentClass, @selector(animationsOnInitialMount)) ||
        CKSubclassOverridesInstanceMethod([CKComponent class], componentClass, @selector(animationsOnFinalUnmount))) {
      hasAnimations = YES;
    }
    cache->insert({componentClass, hasAnimations});
    return hasAnimations;
  }
  return it->second;
}

@end
