#pragma once

#include <stdint.h>
#include "Fixed.hpp"
#include "Matrix.hpp"
#include "Memory.hpp"
#include "Sprite.hpp"
#include "RGBA.hpp"

namespace GPU {
    class SPU {
    public:
        static constexpr size_t TileSize = 10;
        static constexpr size_t MaxWidth = 800;
        static constexpr size_t MaxHeight = 600;
        
        SPU(Memory memory) : memory(memory) {
            flags = memory->Read32(0x000);
            front_address = memory->Read32(0x100);
            back_address = memory->Read32(0x104);
            pallet_address = memory->Read32(0x108);
            sprite_address = memory->Read32(0x10c);
            window_pos.m0 = Types::Fixed(memory->Read16(0x200));
            window_pos.m1 = Types::Fixed(memory->Read16(0x202));
            window_transform.m00 = Types::Fixed(memory->Read16(0x204));
            window_transform.m01 = Types::Fixed(memory->Read16(0x206));
            window_transform.m10 = Types::Fixed(memory->Read16(0x208));
            window_transform.m11 = Types::Fixed(memory->Read16(0x20a));
            clear_color.R = memory->Read8(0x20c);
            clear_color.G = memory->Read8(0x20d);
            clear_color.B = memory->Read8(0x20e);
        }

        void StartDraw() {
            for (size_t x = 0; x < TileSize; x++) {
                for (size_t y = 0; y < TileSize; x++) {
                    pixels[x][y] = clear_color;
                }
            }
        }

        void ProcessSprite(Types::Sprite sprite) {
            Types::Matrix2x2 transform = sprite->transform.inverse();
            Types::Matrix2x1 sprite_pos;
            sprite_pos.m0 = sprite->x;
            sprite_pos.m1 = sprite->y;

            Types::Matrix2x1 pos;
            
            for (size_t x = 0; x < TileSize; x++) {
                for (size_t y = 0; y < TileSize; y++) {
                    pos.m0 = Types::Fixed(double(x));
                    pos.m1 = Types::Fixed(double(y));

                    // Matrix transform
                    pos *= transform;
                    pos -= sprite_pos;

                    // Window transform
                    pos *= window_transform;
                    pos += window_pos;

                    if (
                        (pos.m0 < Types::Fixed(0.0)) ||
                        (pos.m1 < Types::Fixed(0.0)) ||
                        (pos.m0 >= Types::Fixed(double(MaxWidth))) ||
                        (pos.m1 >= Types::Fixed(double(MaxHeight)))
                    ) {
                        // Discard pixel
                        continue;
                    }

                    uint32_t pixel_x = uint32_t(pos.m0.AsDouble());
                    uint32_t pixel_y = uint32_t(pos.m1.AsDouble());
                    
                    

                }
            }
        }

        void Dump() {

        }

    private:
        const Memory memory;

        uint32_t flags;
        uint32_t front_address;
        uint32_t back_address;
        uint32_t pallet_address;
        uint32_t sprite_address;
        Types::Matrix2x1 window_pos;
        Types::Matrix2x2 window_transform;
        Types::RGBA clear_color;

        Types::RGBA pixels[TileSize][TileSize];
    };
}