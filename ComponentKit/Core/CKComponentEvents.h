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

#import <ComponentKit/CKComponentScopeRoot.h>
#import <ComponentKit/CKComponentLayout.h>

/**
 A predicate that identifies if a component implements bounds animations. This predicate is passed to the scope root
 and is checked on the initialization of components and cached. This allows us to rapidly identify which components
 require animating.
 */
#if !defined(NO_PROTOCOLS_IN_OBJCPP)
BOOL CKComponentBoundsAnimationPredicate(id<CKComponentProtocol> component);
#else
BOOL CKComponentBoundsAnimationPredicate(id component);
#endif

/**
 A predicate that identifies a component that it's controller overrides the 'didPrepareLayout:forComponent:' method.
 */
#if !defined(NO_PROTOCOLS_IN_OBJCPP)
BOOL CKComponentDidPrepareLayoutForComponentToControllerPredicate(id<CKComponentProtocol> component);
#else
BOOL CKComponentDidPrepareLayoutForComponentToControllerPredicate(id component);
#endif

/**
 Computes and returns the bounds animations for the transition from a prior generation's scope root.
 */
CKComponentBoundsAnimation CKComponentBoundsAnimationFromPreviousScopeRoot(CKComponentScopeRoot *newRoot, CKComponentScopeRoot *previousRoot);

/**
 Iterates over the components that their controller overrides 'didPrepareLayout:ForComponent:' and send the callback.
 */
void CKComponentSendDidPrepareLayoutForComponent(CKComponentScopeRoot *scopeRoot, const CKComponentLayout layout);
