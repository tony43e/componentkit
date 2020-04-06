/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKComponentScope.h"

#import "CKAnalyticsListener.h"
#import "CKComponentScopeHandle.h"
#import "CKComponentScopeRoot.h"
#import "CKThreadLocalComponentScope.h"
#import "CKScopeTreeNode.h"
#import "CKTreeNodeProtocol.h"

#import <ComponentKit/CKRenderHelpers.h>
#import <ComponentKit/CKCoalescedSpecSupport.h>

static auto toInitialStateCreator(id (^initialStateCreator)(void), Class componentClass) {
  return initialStateCreator ?: ^{
    return [componentClass initialState];
  };
}

CKComponentScope::~CKComponentScope()
{
  if (_threadLocalScope != nullptr) {
    [_scopeHandle resolve];

    if (_threadLocalScope->systraceListener) {
      auto const componentTypeName = _threadLocalScope->stack.top().node.scopeHandle.componentTypeName ?: "UnkownTypeName";
      CKCAssertWithCategory(objc_getClass(componentTypeName) != nil,
                            [NSString stringWithUTF8String:componentTypeName],
                            @"Creating an action from a scope should always yield a class");

      [_threadLocalScope->systraceListener didBuildComponent:componentTypeName];
    }

    _threadLocalScope->pop(YES, YES);
  }
}

CKComponentScope::CKComponentScope(Class __unsafe_unretained componentClass, id identifier, id (^initialStateCreator)(void)) noexcept
{
  CKCAssert(class_isMetaClass(object_getClass(componentClass)), @"Expected %@ to be a meta class", componentClass);
  _threadLocalScope = CKThreadLocalComponentScope::currentScope();
  if (_threadLocalScope != nullptr) {
    const auto componentTypeName = class_getName(componentClass);

    [_threadLocalScope->systraceListener willBuildComponent:componentTypeName];

    const auto& pair = _threadLocalScope->stack.top();

    const auto childPair = [CKScopeTreeNode childPairForPair:pair
                                                     newRoot:_threadLocalScope->newScopeRoot
                                           componentTypeName:componentTypeName
                                                  identifier:identifier
                                                        keys:_threadLocalScope->keys.top()
                                         initialStateCreator:toInitialStateCreator(initialStateCreator, componentClass)
                                                stateUpdates:_threadLocalScope->stateUpdates
                                         mergeTreeNodesLinks:_threadLocalScope->mergeTreeNodesLinks
                                         requiresScopeHandle:YES];
    _scopeHandle = childPair.node.scopeHandle;

    const auto ancestorHasStateUpdate =
        (_threadLocalScope->coalescingMode == CKComponentCoalescingModeComposite &&
         _threadLocalScope->enableComponentReuseOptimizations &&
         _threadLocalScope->buildTrigger != CKBuildTrigger::NewTree)
        ? (_threadLocalScope->ancestorHasStateUpdate.top() ||
           CKRender::componentHasStateUpdate(
               childPair.node.scopeHandle,
               pair.previousNode,
               _threadLocalScope->buildTrigger,
               _threadLocalScope->stateUpdates))
        : true;

    _threadLocalScope->push({.node = childPair.node, .previousNode = childPair.previousNode}, YES, ancestorHasStateUpdate);
  }
  CKCAssertWithCategory(_threadLocalScope != nullptr,
                        NSStringFromClass(componentClass),
                        @"Component with scope must be created inside component provider function.");
}

id CKComponentScope::state(void) const noexcept
{
  return _scopeHandle.state;
}

CKComponentScopeHandleIdentifier CKComponentScope::identifier(void) const noexcept
{
  return _scopeHandle.globalIdentifier;
}

void CKComponentScope::replaceState(const CKComponentScope &scope, id state)
{
  [scope._scopeHandle replaceState:state];
}

CKComponentStateUpdater CKComponentScope::stateUpdater(void) const noexcept
{
  // We must capture _scopeHandle in a local, since this may be destroyed by the time the block executes.
  CKComponentScopeHandle *const scopeHandle = _scopeHandle;
  return ^(id (^stateUpdate)(id), NSDictionary<NSString *, id> *userInfo, CKUpdateMode mode) {
    [scopeHandle updateState:stateUpdate
                    metadata:{.userInfo = userInfo}
                        mode:mode];
  };
}

CKComponentScopeHandle *CKComponentScope::scopeHandle(void) const noexcept
{
  return _scopeHandle;
}
