/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKCompositeComponent.h>

/**
 CKStatelessComponent is a component that can be represented with a pure
 function that takes props and returns component hierarchy. This component adds a
 string identifier to store the debug information about the calling function
 */
@interface CKStatelessComponent : CKCompositeComponent

@property (nonatomic, readonly) NSString *identifier;

/**
 @param view Passed to CKComponent's initializer.
 @param component Result component hierarchy generated by the stateless functional component
 @param identifier Debug identifier of the stateless functional component
 */
+ (instancetype)newWithView:(const CKComponentViewConfiguration &)view component:(CKComponent *)component identifier:(NSString *)identifier;

@end
