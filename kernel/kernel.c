#include "include/multiboot2.h"
#include "include/terminal.h"
#include "include/types.h"

struct multiboot_tag_mmap *mmap;

void _kernel_start(void);

void _kernel_start (void) {
	uint8_t color;
	color = (VGA_COLOR_BLACK << 4 | VGA_COLOR_GREEN);

	terminal_set_color(color);
	terminal_write_string("Welcome to TeamOS\n");
	
	color = terminal_get_color();
	
	color = color << 1;
	terminal_set_color(color);



	terminal_write_string("Copyright (c) 2022 Harkirat S Virk\n");

	while(1);
}
