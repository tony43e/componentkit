/**
 * Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

// @Generated by gentest/gentest.rb from gentest/fixtures/YGSizeOverflowTest.html

#include <gtest/gtest.h>
#include <yoga/Yoga.h>

TEST(YogaTest, nested_overflowing_child) {
  const YGConfigRef config = YGConfigNew();

  const YGNodeRef root = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root, 100);
  YGNodeStyleSetHeight(root, 100);

  const YGNodeRef root_child0 = YGNodeNewWithConfig(config);
  YGNodeInsertChild(root, root_child0, 0);

  const YGNodeRef root_child0_child0 = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root_child0_child0, 200);
  YGNodeStyleSetHeight(root_child0_child0, 200);
  YGNodeInsertChild(root_child0, root_child0_child0, 0);
  YGNodeCalculateLayout(root, YGUndefined, YGUndefined, YGDirectionLTR);

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetWidth(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0_child0));

  YGNodeCalculateLayout(root, YGUndefined, YGUndefined, YGDirectionRTL);

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0));

  ASSERT_FLOAT_EQ(-100, YGNodeLayoutGetLeft(root_child0_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetWidth(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0_child0));

  YGNodeFreeRecursive(root);

  YGConfigFree(config);
}

TEST(YogaTest, nested_overflowing_child_in_constraint_parent) {
  const YGConfigRef config = YGConfigNew();

  const YGNodeRef root = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root, 100);
  YGNodeStyleSetHeight(root, 100);

  const YGNodeRef root_child0 = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root_child0, 100);
  YGNodeStyleSetHeight(root_child0, 100);
  YGNodeInsertChild(root, root_child0, 0);

  const YGNodeRef root_child0_child0 = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root_child0_child0, 200);
  YGNodeStyleSetHeight(root_child0_child0, 200);
  YGNodeInsertChild(root_child0, root_child0_child0, 0);
  YGNodeCalculateLayout(root, YGUndefined, YGUndefined, YGDirectionLTR);

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root_child0));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetWidth(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0_child0));

  YGNodeCalculateLayout(root, YGUndefined, YGUndefined, YGDirectionRTL);

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root_child0));

  ASSERT_FLOAT_EQ(-100, YGNodeLayoutGetLeft(root_child0_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetWidth(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0_child0));

  YGNodeFreeRecursive(root);

  YGConfigFree(config);
}

TEST(YogaTest, parent_wrap_child_size_overflowing_parent) {
  const YGConfigRef config = YGConfigNew();

  const YGNodeRef root = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root, 100);
  YGNodeStyleSetHeight(root, 100);

  const YGNodeRef root_child0 = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root_child0, 100);
  YGNodeInsertChild(root, root_child0, 0);

  const YGNodeRef root_child0_child0 = YGNodeNewWithConfig(config);
  YGNodeStyleSetWidth(root_child0_child0, 100);
  YGNodeStyleSetHeight(root_child0_child0, 200);
  YGNodeInsertChild(root_child0, root_child0_child0, 0);
  YGNodeCalculateLayout(root, YGUndefined, YGUndefined, YGDirectionLTR);

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0_child0));

  YGNodeCalculateLayout(root, YGUndefined, YGUndefined, YGDirectionRTL);

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetHeight(root));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0));

  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetLeft(root_child0_child0));
  ASSERT_FLOAT_EQ(0, YGNodeLayoutGetTop(root_child0_child0));
  ASSERT_FLOAT_EQ(100, YGNodeLayoutGetWidth(root_child0_child0));
  ASSERT_FLOAT_EQ(200, YGNodeLayoutGetHeight(root_child0_child0));

  YGNodeFreeRecursive(root);

  YGConfigFree(config);
}
