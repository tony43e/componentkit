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

#import <ComponentKit/CKComponentContextHelper.h>

/**
 Provides a way to implicitly pass parameters to child components. Items are keyed by class. Example usage:

 {
   CKComponentMutableContext<CKFoo> c(foo);
   // Any components created while c is in scope will be able to read its value
   // by calling CKComponentMutableContext<CKFoo>::get().
 }

 You may nest contexts with the same class, in which case the innermost context defines the value when fetched:

 {
   CKComponentMutableContext<CKFoo> c1(foo1);
   {
     CKComponentMutableContext<CKFoo> c2(foo2);
     // CKComponentMutableContext<CKFoo>::get() will return foo2 here
   }
   // CKComponentMutableContext<CKFoo>::get() will return foo1 here
 }

 @warning Context should be used sparingly. Prefer explicitly passing parameters instead.
 @warning If you have to use context, consider using CKComponentConstContext instead. CKComponentMutableContext makes component reuse more difficult.
 */
template<typename T>
class CKComponentMutableContext {
public:
  /**
   Fetches an object from the context dictionary.
   You may only call this from inside +new. If you want access to something from context later, store it in an ivar.
   @example CKFoo *foo = CKComponentMutableContext<CKFoo>::get();
   */
  static T *get() { return CKComponentContextHelper::fetch([T class]); }

  CKComponentMutableContext(T *object) : _previousState(CKComponentContextHelper::store([T class], object)) {}
  ~CKComponentMutableContext() { CKComponentContextHelper::restore(_previousState); }

private:
  const CKComponentContextPreviousState _previousState;

  CKComponentMutableContext(const CKComponentMutableContext&) = delete;
  CKComponentMutableContext &operator=(const CKComponentMutableContext&) = delete;
};

/**
 CKComponentConstContext is similar to CKComponentMutableContext, but for context values that are NOT expected to change.

 Using CKComponentContext can affect component reuse, which could make components' creation slower.
 By using CKComponentConstContext, the infrasturctue can reuse components safley and make the component creation faster.
 Unless your component context value is expeted to change, you should ALWAYS use CKComponentConstContext.

 Example usage:

 {
 CKComponentConstContext<CKFoo> c(foo);
 // Any components created while c is in scope will be able to read its value
 // by calling CKComponentConstContext<CKFoo>::get().
 }

 @warning Context should be used sparingly. Prefer explicitly passing parameters instead.
 */
template<typename T>
class CKComponentConstContext {
public:
  /**
   Fetches an object from the context dictionary.
   You may only call this from inside +new. If you want access to something from context later, store it in an ivar.
   @example CKFoo *foo = CKComponentConstContext<CKFoo>::get();
   */
  static T *get() { return CKComponentContextHelper::fetchConst([T class]); }

  CKComponentConstContext(T *object) : _previousState(CKComponentContextHelper::store([T class], object)) {}
  ~CKComponentConstContext() { CKComponentContextHelper::restore(_previousState); }

private:
  const CKComponentContextPreviousState _previousState;

  CKComponentConstContext(const CKComponentConstContext&) = delete;
  CKComponentConstContext &operator=(const CKComponentConstContext&) = delete;
};
