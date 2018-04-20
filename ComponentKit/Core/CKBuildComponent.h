/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>

#import <ComponentKit/CKComponentScopeTypes.h>
#import <ComponentKit/CKComponentBoundsAnimation.h>
#import <ComponentKit/CKComponentLayout.h>

@class CKComponentScopeRoot;
@class CKComponent;

/**
 The results of a build operation.

 A bounds animations are returned in this method if a component in the hierarchy requested an animation from its prior
 state. These animations should be applied with CKComponentBoundsAnimationApply.
 */
struct CKBuildComponentResult {
  CKComponent *component;
  CKComponentScopeRoot *scopeRoot;
  CKComponentBoundsAnimation boundsAnimation;
};

/**
 Used to construct a component hierarchy. This is necessary to configure the thread-local state so that components
 can be properly connected to a scope root.

 @param previousRoot The previous scope root that was associated with the cell. May be nil if no prior root is available
 @param stateUpdates A map of state updates that have accumulated since the last component generation was constructed.
 @param componentFactory A block that constructs your component. Must not be nil.
 @param buildComponentTree Defines whether the method should constract a component tree (CKTreeNode) from the root component when it has a render component in the tree.
 @param alwaysBuildComponentTree Defines whether the method should ALWAYS constract a component tree from the root component (CKTreeNode) or not.
 */
CKBuildComponentResult CKBuildComponent(CKComponentScopeRoot *previousRoot,
                                        const CKComponentStateUpdateMap &stateUpdates,
                                        CKComponent *(^componentFactory)(void),
                                        BOOL buildComponentTree = NO,
                                        BOOL alwaysBuildComponentTree = NO);

/**
 The results of a build and layout operation.

 A bounds animations are returned in this method if a component in the hierarchy requested an animation from its prior
 state. These animations should be applied with CKComponentBoundsAnimationApply.

 The layout returned is the complete layout of the actual component tree

 THIS IS EXPERIMENTAL, LINKED WITH THE DEFERRED CHILD COMPONENT CREATION (-render:() RFC) - DO NOT USE DIRECTLY
 */

struct CKBuildAndLayoutComponentResult {
  CKBuildComponentResult buildComponentResult;
  CKComponentLayout computedLayout;
};

/**
 Used to construct and layout a component hierarchy. This is necessary to configure the thread-local state so that components
 can be properly connected to a scope root.

 @param previousRoot The previous scope root that was associated with the cell. May be nil if no prior root is available
 @param stateUpdates A map of state updates that have accumulated since the last component generation was constructed.
 @param sizeRange The size range to compute the component layout within.
 @param componentFactory A block that constructs your component. Must not be nil.

 THIS IS EXPERIMENTAL, LINKED WITH THE DEFERRED CHILD COMPONENT CREATION (-render:() RFC) - DO NOT USE DIRECTLY
 */


CKBuildAndLayoutComponentResult CKBuildAndLayoutComponent(CKComponentScopeRoot *previousRoot,
                                         const CKComponentStateUpdateMap &stateUpdates,
                                         const CKSizeRange &sizeRange,
                                         CKComponent *(^componentFactory)(void));

