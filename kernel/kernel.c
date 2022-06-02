#include "include/multiboot2.h"
#include "include/terminal.h"

struct multiboot_tag_mmap *mmap;

void _kernel_start(void);

void _kernel_start (void) {
	terminal_write_string("Welcome to TeamOS\n");
	terminal_write_string("Copyright (c) 2022 Harkirat S Virk\n");

	while(1);
}
