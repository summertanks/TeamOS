;
;
;
;

%ifndef _MULTIBOOT2_INC
%define _MULTIBOOT2_INC


; Been conservative of what is added here, adding only used declarations

%define MULTIBOOT2_HEADER_MAGIC			0xe85250d6
%define MULTIBOOT2_BOOTLOADER_MAGIC		0x36d76289

%define MULTIBOOT_ARCHITECTURE_I386		0

%define MULTIBOOT_HEADER_TAG_OPTIONAL		1
%define MULTIBOOT_HEADER_TAG_FRAMEBUFFER	5
%define MULTIBOOT_HEADER_TAG_END  		0


%define MULTIBOOT_MEMORY_AVAILABLE              1
%define MULTIBOOT_MEMORY_RESERVED               2
%define MULTIBOOT_MEMORY_ACPI_RECLAIMABLE       3
%define MULTIBOOT_MEMORY_NVS                    4
%define MULTIBOOT_MEMORY_BADRAM                 5


%define MULTIBOOT_TAG_TYPE_END			0
%define MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME	2
%define MULTIBOOT_TAG_TYPE_BASIC_MEMINFO	4
%define MULTIBOOT_TAG_TYPE_BOOTDEV		5
%define MULTIBOOT_TAG_TYPE_MMAP			6


struc multiboot_info_header
	.header_size	resd	1	
	.reserved	resd	1
	.size:
endstruc

struc multiboot_tag_header
	.tag		resd	1
	.tag_size	resd	1
	.size:
endstruc

struc multiboot_tag_name
	.tag		resd	1
	.tag_size	resd	1
	.name		resb	1	
endstruc

struc multiboot_tag_basic_meminfo
	.tag		resd	1
	.tag_size	resd	1
	.mem_lower	resd	1	; in kb, max 640kb
	.mem_upper	resd	1	; in kb, first upper memory hole minus 1Mb
endstruc

struc multiboot_tag_bootdev
	.tag		resd	1
	.tag_size	resd	1
	.biosdev	resd	1
	.part		resd	1
	.subpart	resd	1
endstruc

struc multiboot_tag_mmap
	.tag		resd	1
	.tag_size	resd	1
	.entry_size	resd	1
	.entry_version	resd	1
	.entries	resb	multiboot_mmap_entry.size
endstruc

struc multiboot_mmap_entry
	.addr		resq	1
	.len		resq	1
	.type		resd	1
	.zero		resd	1
	.size:
endstruc

%endif ; MULTIBOOT_HEADER
