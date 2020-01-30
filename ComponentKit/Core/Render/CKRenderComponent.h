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


#import <ComponentKit/CKComponent.h>
#import <ComponentKit/CKSingleChildComponent.h>
#import <ComponentKit/CKRenderComponentProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/*
@warning Overriding -layoutThatFits:parentSize: or -computeLayoutThatFits: is **not allowed** for any subclass.
*/

@interface CKRenderComponent : CKSingleChildComponent <CKRenderWithChildComponentProtocol>

/**
 Returns a child component that needs to be rendered from this component.

 @param state The current state of the component.
 */
- (CKComponent * _Nullable)render:(id _Nullable)state;

/**
 Returns view configuration for the component.

 This method is optional - it can be used in case the view configuration is based on a state.
 View configuration: A struct describing the view for this component.

 @param state The current state of the component.
 */
- (CKComponentViewConfiguration)viewConfigurationWithState:(id)state;

@end

NS_ASSUME_NONNULL_END

#endif
