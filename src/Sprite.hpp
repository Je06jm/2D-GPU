#pragma once

#include <stdint.h>
#include <memory>
#include "Fixed.hpp"
#include "Matrix.hpp"

namespace GPU::Types {

    class SpriteClass {
    public:
        static constexpr uint8_t Used = 0;
        static constexpr uint8_t RGBA = 1;
        static constexpr uint16_t MaxCount = 512;

        uint8_t flags, pallet;
        Fixed x, y;
        Matrix2x2 transform;
        uint_fast32_t color_address;
        
    };

    typedef std::shared_ptr<SpriteClass> Sprite;

}