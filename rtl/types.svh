`ifndef TYPES
`define TYPES

typedef struct packed {
    logic[9:0] whole;
    logic[5:0] fraction;
} Fixed;

typedef struct packed {
    logic[7:0] flags;
    logic[7:0] pallet;
    logic[7:0] size_x;
    logic[7:0] size_y;
    logic[15:0] x;
    logic[15:0] y;
    Fixed m_00;
    Fixed m_10;
    Fixed m_01;
    Fixed m_11;
    logic[31:0] color_data;
} SpriteSlot;

typedef struct packed {
    logic[7:0] r;
    logic[7:0] g;
    logic[7:0] b;
    logic[7:0] a;
} ColorRGBA;

typedef struct packed {
    logic[7:0] r;
    logic[7:0] g;
    logic[7:0] b;
} ColorRGB;

typedef struct packed {
    logic[4:0] i0;
    logic[4:0] i1;
    logic[4:0] i2;
    logic[4:0] i3;
    logic[4:0] i4;
    logic[4:0] i5;
    logic[4:0] i6;
    logic[4:0] i7;
} ColorIndex;

typedef struct packed {
    logic[15:0] x;
    logic[15:0] y;
    Fixed m_00;
    Fixed m_10;
    Fixed m_01;
    Fixed m_11;
} WindowTransform;

`endif