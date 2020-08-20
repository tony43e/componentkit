/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKDefines.h>

#if CK_NOT_SWIFT

#import <stack>
#import <vector>

#import <Foundation/Foundation.h>

#import <ComponentKit/CKAssert.h>
#import <ComponentKit/CKBuildComponent.h>
#import <ComponentKit/CKComponentScopeHandle.h>
#import <ComponentKit/CKGlobalConfig.h>
#import <ComponentKit/CKNonNull.h>
#import <ComponentKit/CKTreeNodeProtocol.h>
#import <ComponentKit/CKScopeTreeNode.h>
#import <ComponentKit/CKComponentCoalescingMode.h>

@protocol CKSystraceListener;

class CKThreadLocalComponentScope {
public:
  CKThreadLocalComponentScope(CKComponentScopeRoot *previousScopeRoot,
                              const CKComponentStateUpdateMap &updates,
                              CKBuildTrigger trigger = CKBuildTriggerNone,
                              BOOL enableComponentReuseOptimizations = YES,
                              BOOL shouldCollectTreeNodeCreationInformation = NO,
                              BOOL alwaysBuildRenderTree = NO,
                              CKComponentCoalescingMode coalescingMode = CKComponentCoalescingModeNone,
                              BOOL enforceCKComponentSubclasses = YES);
  ~CKThreadLocalComponentScope();

  /** Returns nullptr if there isn't a current scope */
  static CKThreadLocalComponentScope *currentScope() noexcept;

  /**
   Marks the current component scope as containing a component tree.
   This is used to ensure that during build component time we are initiating a component tree generation by calling `buildComponentTree:` on the root component.
   */
  static void markCurrentScopeWithRenderComponentInTree();

  CK::NonNull<CKComponentScopeRoot *> const newScopeRoot;
  CKComponentScopeRoot *const previousScopeRoot;
  const CKComponentStateUpdateMap stateUpdates;
  std::stack<CKComponentScopePair> stack;
  std::stack<std::vector<id<NSObject>>> keys;
  std::stack<BOOL> ancestorHasStateUpdate;

  /** The current systrace listener. Can be nil if systrace is not enabled. */
  id<CKSystraceListener> systraceListener;

  /** Build trigger of the corsposnding component creation */
  CKBuildTrigger buildTrigger;

  /** Component Allocations */
  NSUInteger componentAllocations;

  const CKTreeNodeDirtyIds treeNodeDirtyIds;

  const BOOL enableComponentReuseOptimizations;

  const BOOL shouldCollectTreeNodeCreationInformation;

  const CKComponentCoalescingMode coalescingMode;

  const BOOL enforceCKComponentSubclasses;

  void push(CKComponentScopePair scopePair, BOOL keysSupportEnabled = NO);
  void push(CKComponentScopePair scopePair, BOOL keysSupportEnabled, BOOL ancestorHasStateUpdate);
  void pop(BOOL keysSupportEnabled = NO, BOOL ancestorStateUpdateSupportEnabled = NO);

private:
  CKThreadLocalComponentScope *const previousScope;
};

#endif
