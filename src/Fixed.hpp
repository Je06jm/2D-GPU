#pragma once

#include <stdint.h>

namespace GPU::Types {

    class Fixed {
    public:
        Fixed() {}

        Fixed(uint16_t other) {
            number = uint_fast16_t(other);
        }

        Fixed(const Fixed& other) {
            number = other.number;
        }

        Fixed(double other) {
            int whole = int(other);
            int fraction = int((other - (double)whole) * 64.0);

            whole <<= 6;
            whole |= (fraction & 0b111111);
            number = int_fast16_t(whole);
        }
        
        double AsDouble() const {
            int fraction = number & 0b111111;
            int whole = number >> 6;

            return double(whole) + double(fraction) / 64.0;
        }

        Fixed operator+(const Fixed& other) {
            Fixed f;
            f.number = number + other.number;
            return f;
        }

        Fixed operator-(const Fixed& other) {
            Fixed f;
            f.number = number - other.number;
            return f;
        }

        Fixed operator*(const Fixed& other) {
            Fixed f;
            f.number = int_fast16_t((int_fast32_t(number) * int_fast32_t(other.number)) / int_fast32_t(6));
            return f;
        }

        Fixed operator/(const Fixed& other) {
            Fixed f;
            f.number = int_fast16_t((int_fast32_t(number) * int_fast32_t(6)) / int_fast32_t(other.number));
            return f;
        }

        Fixed& operator+=(const Fixed& other) {
            number += other.number;
            return *this;
        }

        Fixed& operator-=(const Fixed& other) {
            number -= other.number;
            return *this;
        }

        Fixed& operator*=(const Fixed& other) {
            number = int_fast16_t((int_fast32_t(number) * int_fast32_t(other.number)) / int_fast32_t(6));
            return *this;
        }

        Fixed& operator/=(const Fixed& other) {
            number = int_fast16_t((int_fast32_t(number) * int_fast32_t(6)) / int_fast32_t(other.number));
            return *this;
        }

        bool operator==(const Fixed& other) {
            return number == other.number;
        }

        bool operator!=(const Fixed& other) {
            return number != other.number;
        }

        bool operator>(const Fixed& other) {
            return number > other.number;
        }

        bool operator<(const Fixed& other) {
            return number < other.number;
        }

        bool operator<=(const Fixed& other) {
            return number <= other.number;
        }

        bool operator>=(const Fixed& other) {
            return number >= other.number;
        }

    private:
        int_fast16_t number;
    };

}