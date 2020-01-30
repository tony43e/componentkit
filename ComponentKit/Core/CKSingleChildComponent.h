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

#import <UIKit/UIKit.h>

#import <ComponentKit/CKComponent.h>

NS_ASSUME_NONNULL_BEGIN

/** Infra components with single child should inherit from this one. Please DO NOT use it directly. */
@interface CKSingleChildComponent : CKComponent
- (CKComponent * _Nullable)child;
@end

NS_ASSUME_NONNULL_END

#endif
