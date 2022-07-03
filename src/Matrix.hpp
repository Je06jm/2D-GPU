#pragma once

#include "Fixed.hpp"

namespace GPU::Types {

    class Matrix2x2 {
    public:
        Fixed m00, m01;
        Fixed m10, m11;

        Matrix2x2 inverse() {
            Matrix2x2 m;
            m.m00 = m11;
            m.m01 = Fixed(0.0)-m01;
            m.m10 = Fixed(0.0)-m10;
            m.m11 = m00;

            Fixed determinant = m00 * m11 - m01 * m10;
            m.m00 /= determinant;
            m.m01 /= determinant;
            m.m10 /= determinant;
            m.m11 /= determinant;

            return m;
        }

        Matrix2x2 operator*(const Matrix2x2& other) {
            Matrix2x2 m;
            m.m00 = m00 * other.m00 + m10 * other.m01;
            m.m01 = m01 * other.m00 + m11 * other.m01;
            m.m10 = m00 * other.m10 + m10 * other.m11;
            m.m11 = m01 * other.m10 + m11 * other.m11;

            return m;
        }

        Matrix2x2& operator*=(const Matrix2x2& other) {
            Matrix2x2 m = *this * other;
            return m;
        }

    };

    class Matrix2x1 {
    public:
        Fixed m0, m1;

        Matrix2x1 operator+(const Matrix2x1& other) {
            Matrix2x1 m;
            m.m0 = m0 + other.m0;
            m.m1 = m1 + other.m1;
            return m;
        }

        Matrix2x1 operator-(const Matrix2x1& other) {
            Matrix2x1 m;
            m.m0 = m0 - other.m0;
            m.m1 = m1 + other.m1;
            return m;
        }

        Matrix2x1 operator*(const Matrix2x2& other) {
            Matrix2x1 m;
            m.m0 = m0 * other.m00 + m1 * other.m01;
            m.m1 = m0 * other.m10 + m1 * other.m11;
            return m;
        }

        Matrix2x1& operator+=(const Matrix2x1& other) {
            m0 += other.m0;
            m1 += other.m1;
            return *this;
        }

        Matrix2x1& operator-=(const Matrix2x1& other) {
            m0 -= other.m0;
            m1 -= other.m1;
            return *this;
        }

        Matrix2x1& operator*=(const Matrix2x2& other) {
            Matrix2x1 m = *this * other;
            return m;
        }
    };

}