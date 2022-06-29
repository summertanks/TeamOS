/* Team OS
; MIT License

; Copyright (c) 2022 Harkirat Singh Virk

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
*/

#ifndef __TERMINAL_H
#define __TERMINAL_H


#include <stddef.h>
#include "types.h"

#define VGA_COLOR_BLACK		0
#define VGA_COLOR_BLUE		1
#define VGA_COLOR_GREEN		2
#define VGA_COLOR_CYAN	 	3
#define VGA_COLOR_RED	 	4
#define VGA_COLOR_MAGENTA 	5
#define VGA_COLOR_BROWN	 	6
#define VGA_COLOR_LIGHT_GREY 	7
#define VGA_COLOR_DARK_GREY 	8
#define VGA_COLOR_LIGHT_BLUE 	9
#define VGA_COLOR_LIGHT_GREEN	10
#define VGA_COLOR_LIGHT_CYAN	11
#define VGA_COLOR_LIGHT_RED 	12
#define VGA_COLOR_LIGHT_MAGENTA	13
#define VGA_COLOR_LIGHT_BROWN	14
#define VGA_COLOR_WHITE		15

uint8_t terminal_get_color(void);
void terminal_set_color(uint8_t color);
int terminal_write_string (const char* str);
int terminal_write_chars (const char* string, size_t count);
int terminal_write_hex (size_t value);

#endif
