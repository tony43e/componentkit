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

#import <Foundation/Foundation.h>

#include <string>
#import <ComponentKit/CKAction.h>

/** Exposed only for testing. Do not touch this directly. */
@interface CKComponentGestureActionForwarder : NSObject
+ (instancetype)sharedInstance;
- (void)handleGesture:(UIGestureRecognizer *)recognizer;
@end

CKComponentViewAttributeValue CKComponentGestureAttributeInternal(Class gestureRecognizerClass,
                                                                  CKComponentGestureRecognizerSetupFunction setupFunction,
                                                                  CKAction<UIGestureRecognizer *> action,
                                                                  const std::string& identifierSuffix,
                                                                  void (^applicatorBlock)(UIView *, UIGestureRecognizer *),
                                                                  void (^unapplicatorBlock)(UIGestureRecognizer *));

#endif
