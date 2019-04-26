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

#import <ComponentKit/CKAnalyticsListener.h>

struct CKGlobalConfig {
  /** Default analytics listener which will be used in cased that no other listener is provided */
  id<CKAnalyticsListener> defaultAnalyticsListener = nil;
  /** Can be used to trigger asserts for Render components even if there is no Render component in the tree */
  BOOL forceBuildRenderTreeInDebug = NO;
  /** Used for testing performance implication of calling `invalidateController` between component generations on data source */
  BOOL shouldInvalidateControllerBetweenComponentGenerationsInDataSource = NO;
  /** Used for testing performance implication of calling `invalidateController` between component generations on hosting view */
  BOOL shouldInvalidateControllerBetweenComponentGenerationsInHostingView = NO;
};

CKGlobalConfig CKReadGlobalConfig();
