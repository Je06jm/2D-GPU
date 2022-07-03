512 Sprites

8 MiB video memory

Double Buffered

800x600 resolution

Variable sizes sprites, but each dimension must be evenly dividable by 8

Each sprite can be
    translated
    scaled
    rotated
    skewed

Sprite transformations is applied using the following
<img src="https://latex.codecogs.com/gif.image?\inline&space;\dpi{110}\bg{white}\begin{bmatrix}x&space;\\y&space;\\\end{bmatrix}*\begin{bmatrix}s&space;&&space;j&space;\\k&space;&&space;l\end{bmatrix}&plus;\begin{bmatrix}t_{x}&space;\\t_{y}\end{bmatrix}=\begin{bmatrix}x'&space;\\y'\end{bmatrix}&space;" title="https://latex.codecogs.com/gif.image?\inline \dpi{110}\bg{white}\begin{bmatrix}x \\y \\\end{bmatrix}*\begin{bmatrix}s & j \\k & l\end{bmatrix}+\begin{bmatrix}t_{x} \\t_{y}\end{bmatrix}=\begin{bmatrix}x' \\y'\end{bmatrix}"/>

Each sprite has a draw order determined by the sprite slot

The screen is processed in 10x10 tiles

There are 4 sprite processing units. Each unit works on one tile at a time.
All units works on the same sprite

Sprites color data is organized rows in incrementing order. There are two modes: indexed and RGBA.
* RGBA mode defines a RGBA color per pixel with each channel being a single byte.
* Indexed mode uses 4 bits to index into a pallet to determine each pixel's color.

Each sprite slot is defined as:
* 1 byte - flags (0 - Used, 1 - Use RGBA mode)
* 1 byte - pallet number (Indexed mode only)
* 1 byte - X size / 8
* 1 byte - Y size / 8
* 2 bytes - X translation
* 2 bytes - Y translation
* 8 bytes - Transform matrix in colum row order. Each 2 bytes is a 10.6 fixed signed number
* 4 bytes - Pointer to color data

Control registers (0x00000 - 0x00400)
* 0x000 - 0x003 - Flags (0 - Enable, 1 - Enable VSync interrupt)
* 0x100 - 0x103 - Front framebuffer address
* 0x104 - 0x107 - Back framebuffer address
* 0x108 - 0x10b - Pallet address
* 0x10c - 0x10f - Sprite slots address
* 0x200 - 0x201 - Window X translation
* 0x202 - 0x203 - Window Y translation
* 0x204 - 0x20b - Window transform matrix
* 0x20c - 0x20f - Clear color
* Every other byte between 0x00000 and 0x00400 is reserved
