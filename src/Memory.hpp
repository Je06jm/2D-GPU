#pragma once

#include <stdint.h>
#include <memory>

namespace GPU {

    class MemoryClass {
    public:
        MemoryClass(uint32_t size_in_mb) {
            max_size = size_in_mb * 1024 * 1024;
            data = std::unique_ptr<uint8_t[]>(new uint8_t[max_size]);
        }

        uint8_t Read8(uint32_t address) const {
            if (address >= max_size) return 0;
            return data[address];
        }

        uint16_t Read16(uint32_t address) const {
            if ((address+1) >= max_size) return 0;
            return uint16_t(data[address]) | (uint16_t(data[address]) << 8);
        }

        uint32_t Read32(uint32_t address) const {
            if ((address+3) >= max_size) return 0;
            return uint32_t(data[address]) |
                (uint32_t(data[address+1]) << 8) |
                (uint32_t(data[address+2]) << 16) |
                (uint32_t(data[address+3]) << 24);
        }

        void Write8(uint32_t address, uint8_t byte) {
            if (address >= max_size) return;
            data[address] = byte;
        }

        void Write16(uint32_t address, uint16_t word) {
            if (address >= max_size) return;
            data[address] = uint8_t(word);
            if ((address+1) >= max_size) return;
            data[address+1] = uint8_t(word >> 8);
        }

        void Write32(uint32_t address, uint32_t dword) {
            if (address >= max_size) return;
            data[address] = uint8_t(dword);
            if ((address+1) >= max_size) return;
            data[address+1] = uint8_t(dword >> 8);
            if ((address+2) >= max_size) return;
            data[address+2] = uint8_t(dword >> 16);
            if ((address+3) >= max_size) return;
            data[address+3] = uint8_t(dword >> 24);
        }

    private:
        std::unique_ptr<uint8_t[]> data;
        uint32_t max_size;
    };

    typedef std::shared_ptr<MemoryClass> Memory;

}