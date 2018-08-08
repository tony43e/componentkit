/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "CKOverlayLayoutComponent.h"

#import <ComponentKit/CKAssert.h>
#import <ComponentKit/CKMacros.h>
#import <ComponentKit/CKComponentInternal.h>

#import "CKComponentSubclass.h"
#import "CKRenderTreeNodeWithChildren.h"

@implementation CKOverlayLayoutComponent
{
  CKComponent *_overlay;
  CKComponent *_component;
}

+ (instancetype)newWithComponent:(CKComponent *)component
                         overlay:(CKComponent *)overlay
{
  if (component == nil) {
    return nil;
  }
  CKOverlayLayoutComponent *c = [super newWithView:{} size:{}];
  if (c) {
    c->_overlay = overlay;
    c->_component = component;
  }
  return c;
}

+ (instancetype)newWithView:(const CKComponentViewConfiguration &)view size:(const CKComponentSize &)size
{
  CK_NOT_DESIGNATED_INITIALIZER();
}

- (void)buildComponentTree:(id<CKTreeNodeWithChildrenProtocol>)parent
             previousParent:(id<CKTreeNodeWithChildrenProtocol>)previousParent
                    params:(const CKBuildComponentTreeParams &)params
                    config:(const CKBuildComponentConfig &)config
{
  auto const node = [[CKTreeNodeWithChildren alloc]
                     initWithComponent:self
                     parent:parent
                     previousParent:previousParent
                     scopeRoot:params.scopeRoot
                     stateUpdates:params.stateUpdates];
  
  auto const previousParentForChild = (id<CKTreeNodeWithChildrenProtocol>)[previousParent childForComponentKey:[node componentKey]];
  [_component buildComponentTree:node previousParent:previousParentForChild params:params config:config];
  [_overlay buildComponentTree:node previousParent:previousParentForChild params:params config:config];
}

/**
 First layout the contents, then fit the overlay on top of it.
 */
- (CKComponentLayout)computeLayoutThatFits:(CKSizeRange)constrainedSize
                          restrictedToSize:(const CKComponentSize &)size
                      relativeToParentSize:(CGSize)parentSize
{
  CKAssert(size == CKComponentSize(),
           @"CKOverlayLayoutComponent only passes size {} to the super class initializer, but received size %@ "
           "(component=%@, overlay=%@)", size.description(), _component, _overlay);

  const CKComponentLayout contentsLayout = [_component layoutThatFits:constrainedSize parentSize:parentSize];
  
  return {
    self,
    contentsLayout.size,
    _overlay
    ? std::vector<CKComponentLayoutChild> {
      {{0,0}, contentsLayout},
      {{0,0}, [_overlay layoutThatFits:{contentsLayout.size, contentsLayout.size} parentSize:contentsLayout.size]},
    }
    : std::vector<CKComponentLayoutChild> {
      {{0,0}, contentsLayout},
    }
  };
}

@end
