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

