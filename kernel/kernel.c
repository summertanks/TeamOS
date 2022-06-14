#include "include/multiboot2.h"
#include "include/terminal.h"
#include "include/types.h"
#include "include/printk.h"

struct multiboot_tag_mmap *mmap;

void _kernel_start(void);

void _kernel_start (void) {
	char *name = "Harkirat S Virk";
	uint8_t color;
	color = (VGA_COLOR_BLACK << 4 | VGA_COLOR_GREEN);

	terminal_set_color(color);
	terminal_write_string("Welcome to TeamOS\n");

	color = terminal_get_color();
	color = color << 1;
	terminal_set_color(color);
	printk("Copyright (c) 2022 %s Syspro %c  at %x\n", name, name[1], name);
	
	while(1);
}
