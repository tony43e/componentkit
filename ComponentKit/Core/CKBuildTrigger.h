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
#import <ComponentKit/CKDefines.h>

#if CK_NOT_SWIFT

// Collection of events that trigger a new component generation.
typedef NS_OPTIONS(NSInteger, CKBuildTrigger) {
  CKBuildTriggerNone = 0,
  CKBuildTriggerPropsUpdate = 1 << 0,
  CKBuildTriggerStateUpdate = 1 << 1,
};

#endif
