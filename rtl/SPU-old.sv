`include "rtl/types.svh"

typedef enum logic[1:0] {
    StateIdle,
    StateClearColor,
    StateProcessingSprites,
    StateDumps
} SPUState;

typedef enum logic {
    MemoryIdle,
    MemoryWaiting
} MemoryState;

typedef enum logic[2:0] {
    ColorIdle,
    ColorMemory,
    ColorMemoryPallet,
    ColorProcessingR,
    ColorProcessingG,
    ColorProcessingB
} ColorProcessState;

module SPU(
    input wire i_clock, i_reset,
    input wire i_enable,

    input wire[31:0] i_pallet_address,
    input wire[tile_number_bits-1:0] i_tile_x, i_tile_y,

    input wire i_clear,
    input wire ColorRGBA i_clear_color,
    input wire WindowTransform i_window_transform,

    input wire i_start_processing_sprite,
    input wire SpriteSlot i_sprite,
    output reg o_finish_processing_sprite,

    output reg o_mem_read,
    output reg[31:0] o_mem_address,
    input wire i_mem_valid,
    input wire[31:0] i_mem_data,

    input wire i_start_dump,
    input wire i_next_dump,
    output wire ColorRGB o_dump_color
);
    parameter tile_size = 10;
    parameter tile_number_bits = 7;
    parameter tile_index_bits = 4;

    reg ColorRGB colors[tile_size-1:0][tile_size-1:0];
    reg[tile_size-1:0] process_x;
    reg[tile_size-1:0] process_y;

    reg SPUState state;
    reg MemoryState m_state;
    reg ColorProcessState c_state;

    // All martixes are inverted in the parent module
    wire[15:0] j_hat = process_x * i_sprite.m_00 + process_y * i_sprite.m_01;
    wire[15:0] k_hat = process_x * i_sprite.m_10 + process_y * i_sprite.m_11;

    wire[15:0] window_offset_x = j_hat - i_window_transform.x;
    wire[15:0] window_offset_y = k_hat - i_window_transform.y;

    wire[15:0] window_j_hat = window_offset_x * i_window_transform.m_00 + window_offset_y * i_window_transform.m_01;
    wire[15:0] window_k_hat = window_offset_x * i_window_transform.m_10 + window_offset_y * i_window_transform.m_11;

    wire[15:0] sprite_x = window_j_hat + i_tile_x * tile_size;
    wire[15:0] sprite_y = window_k_hat + i_tile_y * tile_size;

    wire[15:0] im_mem_offset_x = i_sprite.flags[1] ? sprite_x * 4 : sprite_x / 4;
    wire[31:0] im_sprite_memory = im_mem_offset_x + sprite_y * i_sprite.size_x * 8;
    wire[31:0] sprite_memory = im_sprite_memory + i_sprite.color_data;
    
    wire can_process = i_enable && (sprite_x < (i_sprite.size_x * 8)) && (sprite_y < (i_sprite.size_y * 8)) & i_sprite.flags[0];

    always @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            process_x <= 0;
            process_y <= 0;

            state <= StateIdle;
            m_state <= MemoryIdle;
            c_state <= ColorIdle;
        end else if (i_enable) begin
            case (state)
                StateIdle: begin // We can only state other states from here
                    if (i_start_dump) begin
                        state <= StateDumps;
                    end else if (i_start_processing_sprite) begin
                        state <= StateProcessingSprites;
                    end else if (i_clear_color) begin
                        state <= StateClearColor;
                    end
                    process_x <= 0;
                    process_y <= 0;

                end
                StateClearColor: begin // Clear tile
                    colors[process_x][process_y] <= i_clear_color;
                    if (process_x == 8'hff) begin
                        if (process_y == 8'hff) begin
                            state <= StateIdle;
                        end else begin
                            process_x <= 0;
                            process_y <= process_y + 1;
                        end
                    end else begin
                        process_x <= process_x + 1;
                    end
                end
                StateProcessingSprites: begin // Process tile color

                end
            endcase
        end
    end

endmodule

// [x] * [00 01]
// [y] * [10 11]