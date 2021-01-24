// (c) Facebook, Inc. and its affiliates. Confidential and proprietary.

#import <ComponentKit/CKAssert.h>
#import <ComponentKit/CKComponentScopeHandle.h>
#import <ComponentKit/CKTreeNodeProtocol.h>
#import <ComponentKit/CKTrigger.h>

static auto _scopedResponderAndKey(id<CKTreeNodeComponentProtocol> component, NSString *context) -> CKTriggerScopedResponderAndKey {

  auto const handle = [component scopeHandle];
  auto const scopedResponder = handle.scopedResponder;
  auto const responderKey = [scopedResponder keyForHandle:handle];

  CKCAssertWithCategory(
      component != nil && handle != nil && scopedResponder != nil,
      context,
      @"Binding a trigger but something is nil (component %@, handle: %@, scopedResponder: %@)",
      component,
      handle,
      scopedResponder);

  return {scopedResponder, responderKey};
}

CKTriggerScopedResponderAndKey::CKTriggerScopedResponderAndKey(CKScopedResponder *responder, CKScopedResponderKey key) : responder(responder), key(key) {}

CKTriggerScopedResponderAndKey::CKTriggerScopedResponderAndKey(id<CKTreeNodeComponentProtocol> component, NSString *context) : CKTriggerScopedResponderAndKey(_scopedResponderAndKey(component, context)) {}
