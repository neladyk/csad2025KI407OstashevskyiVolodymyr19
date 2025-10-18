#include <gtest/gtest.h>
#include "../math_operations.h"

TEST(AdditionTest, AddsTwoPositiveNumbers) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(10, 20), 30);
}

TEST(AdditionTest, AddsTwoNegativeNumbers) {
    EXPECT_EQ(add(-2, -3), -5);
    EXPECT_EQ(add(-10, -20), -30);
}

TEST(AdditionTest, AddsNegativeAndPositiveNumber) {
    EXPECT_EQ(add(-5, 3), -2);
    EXPECT_EQ(add(7, -4), 3);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}