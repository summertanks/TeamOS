#include "include/multiboot2.h"
#include "include/terminal.h"
#include "include/types.h"
#include "include/printk.h"

struct multiboot_tag_mmap 		*multiboot_mmap;
struct multiboot_tag_string 		*multiboot_bootloader;
struct multiboot_tag_basic_meminfo	*multiboot_basic_meminfo;

void _kernel_start(void);

void _kernel_start (void) {
	uint8_t color;
	color = (VGA_COLOR_BLACK << 4 | VGA_COLOR_GREEN);

	terminal_set_color(color);
	terminal_write_string("Welcome to TeamOS\n");

	color = terminal_get_color();
	color = color << 1;
	terminal_set_color(color);
	printk("Copyright (c) 2022 Harkirat S Virk\n");
	
	//-------------------------------------------------------------------
	printk("Booting from bootloader - %s\n", multiboot_bootloader->string);
	printk("Memory Lower %x - Memory Upper %x", multiboot_basic_meminfo-> mem_lower, multiboot_basic_meminfo->mem_upper);
	while(1);
}
