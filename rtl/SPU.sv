`include "rtl/types.svh"

module SPU (
    input wire i_clock,
    input wire i_enable,

    input wire[9:0] tile_x, tile_y,
    input wire[$clog2(TILE_SIZE)-1:0] i_process_x,
    input wire[$clog2(TILE_SIZE)-1:0] i_process_y,

    input wire i_clear, i_draw_sprite,
    input wire ColorRGB i_clear_color,

    input wire[15:0] i_sprite_x, i_sprite_y,
    input wire ColorRGBA i_sprite_color, // Sprite alpha already applied

    input wire i_get_color,
    output wire ColorRGB o_color_data
);
    parameter TILE_SIZE = 10;

    reg ColorRGB output_color;
    assign o_color_data = output_color;

    reg ColorRGB colors[TILE_SIZE-1:0][TILE_SIZE-1:0];

    wire can_process_x = (i_sprite_x < (tile_x * TILE_SIZE + i_process_x));
    wire can_process_y = (i_sprite_y < (tile_y * TILE_SIZE + i_process_y));
    wire can_process = can_process_x && can_process_y;

    wire ColorRGB current = colors[i_process_x][i_process_y];
    wire ColorRGB current_with_alpha = {
        ({current.r, 8'b0} * (16'hff - i_sprite_color.a)) >> 8,
        ({current.g, 8'b0} * (16'hff - i_sprite_color.a)) >> 8,
        ({current.b, 8'b0} * (16'hff - i_sprite_color.a)) >> 8
    };

    always @(posedge i_clock) begin
        if (i_enable) begin
            if (i_get_color) begin
                output_color <= colors[i_process_x][i_process_y];
            end else if (i_draw_sprite && can_process) begin
                colors[i_process_x][i_process_y] <= {
                    current_with_alpha.r + i_sprite_color.r,
                    current_with_alpha.g + i_sprite_color.g,
                    current_with_alpha.b + i_sprite_color.b
                };
            end else if (i_clear) begin
                colors[i_process_x][i_process_y] <= i_clear_color;
            end
        end
    end

endmodule