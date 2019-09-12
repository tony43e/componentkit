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

#import <ComponentKit/CKBuildComponent.h>
#import <ComponentKit/CKComponentInternal.h>
#import <ComponentKit/CKRootTreeNode.h>

@protocol CKRenderWithChildComponentProtocol;
@protocol CKRenderWithChildrenComponentProtocol;

@class CKRenderComponent;
@class CKTreeNodeWithChild;

using CKRenderDidReuseComponentBlock = void(^)(id<CKRenderComponentProtocol>);

namespace CKRender {
  /**
   Build component tree for a component with child component that has been initialized.
   This should be called when a component, on initialization, receives its child component from the outside and it's not meant to be converted to a render component.

   @param component The component at the head of the component tree.
   @param childComponent The pre-computed child component owned by the component in input.
   @param parent The current parent tree node of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   @param parentHasStateUpdate Flag used to run optimizations at component tree build time. `YES` if the input parent received a state update.
   */
  auto buildComponentTreeWithPrecomputedChild(id<CKTreeNodeComponentProtocol> component,
                                              id<CKTreeNodeComponentProtocol> childComponent,
                                              id<CKTreeNodeWithChildrenProtocol> parent,
                                              id<CKTreeNodeWithChildrenProtocol> previousParent,
                                              const CKBuildComponentTreeParams &params,
                                              BOOL parentHasStateUpdate) -> void;


  /**
   Build component tree for a components with children components that have been initialized.
   This should be called when a component receives its children components as a prop and it's not meant to be converted to a render component.

   @param component The component at the head of the component tree.
   @param childrenComponent The pre-computed children components owned by the component in input.
   @param parent The current parent tree node of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   @param parentHasStateUpdate Flag used to run optimizations at component tree build time. `YES` if the input parent received a state update.
   */
  auto buildComponentTreeWithPrecomputedChildren(id<CKTreeNodeComponentProtocol> component,
                                                 std::vector<id<CKTreeNodeComponentProtocol>> childrenComponents,
                                                 id<CKTreeNodeWithChildrenProtocol> parent,
                                                 id<CKTreeNodeWithChildrenProtocol> previousParent,
                                                 const CKBuildComponentTreeParams &params,
                                                 BOOL parentHasStateUpdate) -> void;

  /**
   Build component tree for render layout components (CKRenderLayoutComponent).

   @param component The component at the head of the component tree.
   @param parent The current parent tree node of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   @param parentHasStateUpdate Flag used to run optimizations at component tree build time. `YES` if the input parent received a state update.
   */
  auto buildComponentTreeForRenderLayoutComponent(id<CKRenderWithChildComponentProtocol> component,
                                                  id<CKTreeNodeWithChildrenProtocol> parent,
                                                  id<CKTreeNodeWithChildrenProtocol> previousParent,
                                                  const CKBuildComponentTreeParams &params,
                                                  BOOL parentHasStateUpdate) -> id<CKTreeNodeProtocol>;

  /**
   Build component tree for layout render component with children components (CKRenderLayoutWithChildrenComponent).

   @param component The *render* component at the head of the component tree.
   @param parent The current parent of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   @param parentHasStateUpdate Flag used to run optimizations at component tree build time. `YES` if the input parent received a state update.

   */
  auto buildComponentTreeForRenderLayoutComponentWithChildren(id<CKRenderWithChildrenComponentProtocol> component,
                                                              id<CKTreeNodeWithChildrenProtocol> parent,
                                                              id<CKTreeNodeWithChildrenProtocol> previousParent,
                                                              const CKBuildComponentTreeParams &params,
                                                              BOOL parentHasStateUpdate) -> id<CKTreeNodeProtocol>;

  /**
   Build component tree for *render* component.

   @param component The *render* component at the head of the component tree.
   @param childComponent The child component owned by the component in input.
   @param parent The current parent tree node of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   @param parentHasStateUpdate Flag used to run optimizations at component tree build time. `YES` if the input parent received a state update.
   @param didReuseBlock Will be called in case that the component from the previous generation has been reused.
   */
  auto buildComponentTreeForRenderComponent(id<CKRenderWithChildComponentProtocol> component,
                                            __strong id<CKTreeNodeComponentProtocol> *childComponent,
                                            id<CKTreeNodeWithChildrenProtocol> parent,
                                            id<CKTreeNodeWithChildrenProtocol> previousParent,
                                            const CKBuildComponentTreeParams &params,
                                            BOOL parentHasStateUpdate,
                                            CKRenderDidReuseComponentBlock didReuseBlock = nil) -> id<CKTreeNodeProtocol>;

  /**
   Builds a component tree for *render* component with children components (CKRenderWithChildrenComponent).

   @param component The *render* component at the head of the component tree.
   @param parent The current parent of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   @param parentHasStateUpdate Flag used to run optimizations at component tree build time. `YES` if the input parent received a state update.
   */
  auto buildComponentTreeWithChildren(id<CKRenderWithChildrenComponentProtocol> component,
                                      id<CKTreeNodeWithChildrenProtocol> parent,
                                      id<CKTreeNodeWithChildrenProtocol> previousParent,
                                      const CKBuildComponentTreeParams &params,
                                      BOOL parentHasStateUpdate) -> id<CKTreeNodeProtocol>;

  /**
   Builds a leaf node for a leaf component in the tree.
   This should be called when the component in input is a leaf component in the tree.

   @param component The leaf component at the end of the component tree.
   @param parent The current parent of the component in input.
   @param previousParent The previous generation of the parent tree node of the component in input.
   @param params Collection of parameters to use to properly setup build component tree step.
   */
  auto buildComponentTreeForLeafComponent(id<CKTreeNodeComponentProtocol> component,
                                          id<CKTreeNodeWithChildrenProtocol> parent,
                                          id<CKTreeNodeWithChildrenProtocol> previousParent,
                                          const CKBuildComponentTreeParams &params) -> void;


  /**
   @return `YES` if the input node is part of a state update path. `NO` otherwise.
   */
  auto componentHasStateUpdate(id<CKTreeNodeProtocol> node,
                               id<CKTreeNodeWithChildrenProtocol> previousParent,
                               const CKBuildComponentTreeParams &params) -> BOOL;

  /**
   Mark all the dirty nodes, on a path from an existing node up to the root node in the passed CKTreeNodeDirtyIds set.
   */
  auto markTreeNodeDirtyIdsFromNodeUntilRoot(CKTreeNodeIdentifier nodeIdentifier,
                                             CKRootTreeNode &previousRootNode,
                                             CKTreeNodeDirtyIds &treeNodesDirtyIds) -> void;
  
  /**
   @return A collection of tree node marked as dirty if any. An empty collection otherwise.
   */
  auto treeNodeDirtyIdsFor(CKComponentScopeRoot *previousRoot,
                           const CKComponentStateUpdateMap &stateUpdates,
                           const BuildTrigger &buildTrigger) -> CKTreeNodeDirtyIds;
}
