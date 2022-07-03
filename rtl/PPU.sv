`include "rtl/types.svh"

`define CTL_FLAGS 32'h000

`define CTL_FRONT 32'h100
`define CTL_BACK 32'h104
`define CTL_PALLET 32'h108
`define CTL_SPRITES 32'h10c

`define CTL_WINDOW 32'h200
`define CTL_CLEAR_COLOR 32'h20c

typedef enum logic[2:0] {
    StateIdle,
    StateLookupWindow,
    StateLookupSprite,
    StateClearColor,
    StateDrawSprite,
    StateOutput
} State;

module PPU(
    input wire i_clock, i_reset, i_enable,

    output reg o_mem_read, o_mem_write,
    output reg[31:0] o_mem_address,
    input wire i_mem_valid,
    inout wire[7:0] io_mem_data,

    input wire i_start_draw,

    output reg o_finish_draw
);
    parameter TILE_SIZE = 10;

    wire[7:0] i_mem_data;
    reg[7:0] o_mem_data;

    assign i_mem_data = o_mem_read ? io_mem_data : 8'bz;
    assign io_mem_data = o_mem_write ? o_mem_data : 8'bz;

    reg SpriteSlot sprite;
    reg WindowTransform window;

    reg State state;
    reg[4:0] sub_state;
    
    wire[9:0] tile0x0_xpos = 0;
    wire[9:0] tile0x0_ypos = 0;
    
    wire[9:0] tile1x0_xpos = TILE_SIZE;
    wire[9:0] tile1x0_ypos = 0;

    wire[9:0] tile0x1_xpos = 0;
    wire[9:0] tile0x1_ypos = TILE_SIZE;

    wire[9:0] tile1x1_xpos = TILE_SIZE;
    wire[9:0] tile1x1_ypos = TILE_SIZE;

    reg[9:0] tile_x_processing, tile_y_processing;

    reg[$clog2(TILE_SIZE)-1:0] x_processing, y_processing;

    reg clear_tiles;
    reg draw_sprite;
    reg ColorRGB clear_color;

    reg[31:0] sprite_addresses;

    // Calculate sprite's pixel from screen pixel
    reg[15:0] screen_x, screen_y;

    wire[15:0] j_hat = x_processing * sprite.m_00 + y_processing * sprite.m_01;
    wire[15:0] k_hat = x_processing * sprite.m_10 + y_processing * sprite.m_11;

    wire[15:0] window_offset_x = j_hat + sprite.x - window.x;
    wire[15:0] window_offset_y = k_hat + sprite.y - window.y;

    wire[15:0] window_j_hat = window_offset_x * window.m_00 + window_offset_y * window.m_01;
    wire[15:0] window_k_hat = window_offset_x * window.m_10 + window_offset_y * window.m_11;

    wire[15:0] sprite_x = window_j_hat + tile_x_processing + x_processing;
    wire[15:0] sprite_y = window_k_hat + tile_y_processing + y_processing;

    wire[15:0] im_mem_offset_x = sprite.flags[1] ? sprite_x * 4 : sprite_x / 4;
    wire[31:0] im_sprite_memory = im_mem_offset_x + sprite_y * (sprite.flags[1] ? sprite.size_x * 4 : sprite.size_x / 4);
    wire[31:0] sprite_memory = im_sprite_memory + sprite.color_data;

    reg ColorRGBA sprite_color;

    reg get_color;
    wire ColorRGB tile0x0_color, tile0x1_color, tile1x0_color, tile1x1_color;

    SPU spu_tile0x0(
        i_clock, i_enable,

        tile0x0_xpos + tile_x_processing,
        tile0x0_ypos + tile_y_processing,

        x_processing, y_processing,

        clear_tiles,
        draw_sprite,
        clear_color,

        screen_x, screen_y,
        sprite_color,

        get_color,
        tile0x0_color
    );

    SPU spu_tile0x1(
        i_clock, i_enable,

        tile0x1_xpos + tile_x_processing,
        tile0x1_ypos + tile_y_processing,

        x_processing, y_processing,

        clear_tiles,
        draw_sprite,
        clear_color,

        screen_x, screen_y,
        sprite_color,

        get_color,
        tile0x1_color
    );

    SPU spu_tile1x0(
        i_clock, i_enable,

        tile1x0_xpos + tile_x_processing,
        tile1x0_ypos + tile_y_processing,

        x_processing, y_processing,

        clear_tiles,
        draw_sprite,
        clear_color,

        screen_x, screen_y,
        sprite_color,

        get_color,
        tile1x0_color
    );

    SPU spu_tile1x1(
        i_clock, i_enable,

        tile1x1_xpos + tile_x_processing,
        tile1x1_ypos + tile_y_processing,

        x_processing, y_processing,

        clear_tiles,
        draw_sprite,
        clear_color,

        screen_x, screen_y,
        sprite_color,

        get_color,
        tile1x1_color
    );

    always @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            o_mem_read <= 0;
            o_mem_write <= 0;

            o_finish_draw <= 0;

            state <= StateIdle;
            sub_state <= 0;
        end else if (i_enable) begin
            case (state)
                StateIdle: begin // Only can enter other states from here
                    if (i_start_draw) begin
                        o_mem_address <= `CTL_WINDOW;
                        o_mem_read <= 1;

                        state <= StateLookupWindow;
                    end
                end
                StateLookupWindow: begin
                    case (sub_state)
                        0: window.x <= {i_mem_data, 8'b0};
                        1: window.x <= {window.x[15:8], i_mem_data};
                        2: window.y <= {i_mem_data, 8'b0};
                        3: window.y <= {window.y[15:8], i_mem_data};
                        4: window.m_00 <= {i_mem_data, 8'b0};
                        5: window.m_00 <= {window.m_00[15:8], i_mem_data};
                        6: window.m_01 <= {i_mem_data, 8'b0};
                        7: window.m_01 <= {window.m_01[15:8], i_mem_data};
                        8: window.m_10 <= {i_mem_data, 8'b0};
                        9: window.m_10 <= {window.m_10[15:0], i_mem_data};
                        10: window.m_11 <= {i_mem_data, 8'b0};
                        11: window.m_11 <= {window.m_11[15:8], i_mem_data};
                    endcase
                    
                    if (sub_state == 11) begin
                        o_mem_address <= `CTL_SPRITES;
                        state <= StateLookupSprite;
                        sub_state <= 0;
                        tile_x_processing <= 0;
                        tile_y_processing <= 0;
                        x_processing <= 0;
                        y_processing <= 0;
                        screen_x <= 0;
                        screen_y <= 0;
                    end else begin
                        sub_state <= sub_state + 1;
                        o_mem_address <= o_mem_address + 1;
                    end
                end
                StateLookupSprite: begin
                    case (sub_state)
                        0: sprite_addresses <= {i_mem_data, 24'b0};
                        1: sprite_addresses <= {sprite_addresses[31:24], i_mem_data, 16'b0};
                        2: sprite_addresses <= {sprite_addresses[31:16], i_mem_data, 8'b0};
                        3: sprite_addresses <= {sprite_addresses[31:8], i_mem_data};
                        // Sprite lookup
                        4: o_mem_address <= sprite_addresses;
                        5: sprite.flags <= i_mem_data;
                        6: sprite.pallet <= i_mem_data;
                        7: sprite.x <= {i_mem_data, 8'b0};
                        8: sprite.x <= {sprite.x, i_mem_data};
                        9: sprite.y <= {i_mem_data, 8'b0};
                        10: sprite.y <= {sprite.y, i_mem_data};
                        11: sprite.m_00 <= {i_mem_data, 8'b0};
                        12: sprite.m_00 <= {sprite.m_00[15:8], i_mem_data};
                        13: sprite.m_01 <= {i_mem_data, 8'b0};
                        14: sprite.m_01 <= {sprite.m_01[15:8], i_mem_data};
                        15: sprite.m_10 <= {i_mem_data, 8'b0};
                        16: sprite.m_10 <= {sprite.m_10[15:8], i_mem_data};
                        17: sprite.m_11 <= {i_mem_data, 8'b0};
                        18: sprite.m_11 <= {sprite.m_11[15:8], i_mem_data};
                    endcase
                    
                    if (sub_state == 4) begin
                        // Do nothing
                    end else if (sub_state == 18) begin
                        o_mem_address <= sprite_addresses;
                    end
                end
            endcase
        end
    end

endmodule