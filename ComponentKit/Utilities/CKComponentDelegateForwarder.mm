/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKComponentDelegateForwarder.h"

#import <vector>
#import <objc/runtime.h>

#import "CKAssert.h"
#import "CKComponentViewInterface.h"
#import "CKComponentSubclass.h"

std::string CKIdentifierFromDelegateForwarderSelectors(const CKComponentForwardedSelectors& first)
{
  if (first.size() == 0) {
    return "";
  }
  std::string so = "Delegate";
  for (auto& s : first) {
    so = so + "-" + sel_getName(s);
  }
  return so;
}

@interface CKComponentDelegateForwarder () {
  @package
  CKComponentForwardedSelectors _selectors;
}

@end

@implementation CKComponentDelegateForwarder : NSObject

+ (instancetype)newWithSelectors:(CKComponentForwardedSelectors)selectors
{
  CKComponentDelegateForwarder *f = [[self alloc] init];
  if (!f) return nil;

  f->_selectors = selectors;

  return f;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  if ([super respondsToSelector:aSelector]) {
    return YES;
  } else {
    BOOL responds = std::find(_selectors.begin(), _selectors.end(), aSelector) != std::end(_selectors);
    return responds;
  }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
  CKComponent *responder = _view.ck_component;
  CKAssertNotNil(responder, @"Delegate method is being called on an unmounted component's view: %@", _view);
  return [responder targetForAction:aSelector withSender:responder];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
  // The delegate forwarder is applied as a component view attribute, which is not un-applied to the view on entry
  // into the reuse pool, yet the *component* property on the view will begin returning nil in this case. This would
  // turn into a hard-crash because above forwardingTargetForSelector: will return nil, and the method will be directly
  // invoked on this object. In this case, we have no option but to assert, and not crash, as we do with unhandled
  // component actions.
  const BOOL shouldRespond = std::find(_selectors.begin(), _selectors.end(), aSelector) != std::end(_selectors);
  if (!shouldRespond) {
    [super doesNotRecognizeSelector:aSelector];
  }
}

@end


@implementation NSObject (CKComponentDelegateForwarder)

static const char kCKComponentDelegateProxyKey = ' ';

- (CKComponentDelegateForwarder *)ck_delegateProxy
{
  return objc_getAssociatedObject(self, &kCKComponentDelegateProxyKey);
}

- (void)ck_setDelegateProxy:(CKComponentDelegateForwarder *)delegateProxy
{
  objc_setAssociatedObject(self, &kCKComponentDelegateProxyKey, delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
