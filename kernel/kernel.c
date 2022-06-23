#include "include/multiboot2.h"
#include "include/terminal.h"
#include "include/types.h"
#include "include/printk.h"

struct multiboot_tag_mmap 		*multiboot_mmap;
struct multiboot_mmap_entry		*mmap_entry;

struct multiboot_tag_string 		*multiboot_bootloader;
struct multiboot_tag_basic_meminfo	*multiboot_basic_meminfo;
struct multiboot_tag_bootdev		*multiboot_bootdev;

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
	printk("Booting - %s\n", multiboot_bootloader->string);
	printk("Boot Dev - %x:%x:%x\n", multiboot_bootdev->biosdev, multiboot_bootdev->slice, multiboot_bootdev->part);
	printk("Memory Lower KB %x - Memory Upper %x KB\n", multiboot_basic_meminfo-> mem_lower, multiboot_basic_meminfo->mem_upper);
	// printk("mmap - %x, entry - %x, mmap size - %x, entry size - %x\n", multiboot_mmap, multiboot_mmap->entries, multiboot_mmap->size, multiboot_mmap->entry_size);

	for (mmap_entry = multiboot_mmap->entries; 
			(multiboot_uint8_t *) mmap_entry < ((multiboot_uint8_t *)multiboot_mmap + multiboot_mmap->size);
			mmap_entry = (multiboot_uint8_t *)mmap_entry + multiboot_mmap->entry_size)
		printk ("Memory Map - Base Addr = %x, Length = %x, Type = %x\n",
				(unsigned) (mmap_entry->addr),
				(unsigned) (mmap_entry->len),
				(unsigned) (mmap_entry->type));

	while(1);
}
