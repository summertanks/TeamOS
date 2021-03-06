; Team OS
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

; Design Notes:
; Unlike other places where the loader just gets you to call _kernel_some_init_function
; Lets see what we can consolidate here. Difficulty was to decide if the init for IDT,
; GDT, TSS etc. to be done here or in the kernel. Finally, decided to do those in kernel
; and just enable stack to be in such a condition that we can go there. Not happy about
; doing stack in two stages but it would have uglier to do that all in one file without
; CALL (which requires stack). Ended up doing the following here:-
; 	- setup the multiboot2 header
;	- set IDT to null
;	- Set temp stack
;	- Zero out .bss
;	- Save multiboot params
;	- call the big boss _kernel_start
 
; multiboot declarations
	%include "include/arch/common/multiboot2.inc"

; external references - functions / definations
	extern terminal_write_string
	extern _kernel_start
	extern _setgdt
	extern gdt32
	extern __BSS_START
	extern __BSS_END

	extern multiboot_bootloader
	extern multiboot_basic_meminfo
	extern multiboot_bootdev
	extern multiboot_mmap

[BITS 32]
section .multiboot

ALIGN 8
; multiboot2 header
; https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
; will search for Header Magic in the first 8KiB

multiboot_header:
	dd	MULTIBOOT2_HEADER_MAGIC
	dd	MULTIBOOT_ARCHITECTURE_I386
	dd	multiboot_header_end - multiboot_header
	dd	-(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))

ALIGN 8
; framebuffer tag - optional
;framebuffer_tag_start:
;	dw	MULTIBOOT_HEADER_TAG_FRAMEBUFFER
;	dw	MULTIBOOT_HEADER_TAG_OPTIONAL
;	dd	framebuffer_tag_end - framebuffer_tag_start
;	dd	1024	; width
;	dd	768	; height
;	dd	32	; depth
;framebuffer_tag_end:

ALIGN 8
; multiboot header end
	dw	MULTIBOOT_HEADER_TAG_END
	dw	0
	dd	8

multiboot_header_end:

ALIGN 8

section .text
        global  _start

%define MAX_MMAP_SIZE	0x400
%define MAX_STR_SIZE	0x100
_start:
	; loader code - coming from _start
	; bootloader has loaded to 32 bit protected mode
	; Interrupts disabled
	; Paging disabled
	; Stack undefined

	; State when boot loader invokes the 32-bit OS
	; EAX - Must contain the magic value 0x36d76289
	; EBX - Must contain the 32-bit physical address of the Multiboot2 
	;	information structure
	; CS  - Must be a 32-bit read/execute code segment with an offset of 0
	;	and a limit of 0xFFFFFFFF. The exact value is undefined.

	; DS,ES,FS,GS,SS -Must be a 32-bit read/write data segment with an 
	;	offset of 0 and a limit of 0xFFFFFFFF. The exact values are all undefined.

	; A20 Gate - Must be enabled 
	; CR0 - Bit 31 (PG) must be cleared. Bit 0 (PE) must be set. Others undefined.
	; EFLAGS - Bit 17 (VM) must be cleared. Bit 9 (IF) must be cleared. Others undefined.
	; All other processor registers and flag bits are undefined.

	; ESP, GDTR, IDTR - Neet to be setup, till then, 
	;	* do not reload segment registers
	;	* do not enable interrupts


	; First things first lets set IDT
	; Reusing the GDT structure, declaring something for one time use is a waste
	; Pointing IDT to <NULL> structure, on exception/fault/int it resets system
	lidt [gdt32]

	; provide basic stack
	mov ecx, kernel_stack_bottom
	mov esp, ecx
	mov ebp, ecx

	; Zero .bss
	; ABI specifications say that variables in .bbs will be zeroed, abinitio
	; the complete section gets zeroed. But this is not the linux kernel loading
	; elf, so not sure and didnt have time to read source code of grub
	
	; zero .bss
	mov edx, eax	; saving magic, cant use stack - we are zeroing it :0
	mov edi, __BSS_START
	mov ecx, __BSS_END
	sub ecx, __BSS_START
	mov al, 0
	rep stosb

.info_header:
	; Save the multiboot structure
	; Long, convoluted and painful
	; TODO: 
	
	; saving multiboot info structure address
	push ebp
	mov ebp, ebx

	; check integrity of multiboot structures
	xor edx, MULTIBOOT2_BOOTLOADER_MAGIC
	jz .magic_check_ok
	
	; die die die my darling, did not match magic, 
	mov esi, missing_magic
	call terminal_write_string	
	jmp halt

.magic_check_ok:

	; Lets copy the header out
	mov ecx, [ebp + multiboot_info_header.header_size]
	mov esi, ebp
	mov edi, multiboot_hdr
	rep movsb	

	; Total header size not really required, we assume the header to 
	; well formed, that is, have MULTIBOOT_TAG_END tag and the sizes match
	; Also if one isnt, no assurances that the other would be 
	mov ebp, multiboot_hdr
	add ebp, multiboot_info_header.size	; should get us to the first tag

	; loop through tags, could have done it in serial manner but
	; multiboot doesnt assure that tags will be sequential
	; The chaining looks profoundly ugly - open to suggestions - maybe macro?
.tag_loop:
	; loading current tag type
	mov eax, [ebp + multiboot_tag_header.tag]

.tag_0: ; case 0: Multiboot End
	; end of the road
	cmp eax, MULTIBOOT_TAG_TYPE_END
	je .tag_done

.tag_2:	; case 2: Bootloader name
	cmp eax, MULTIBOOT_TAG_TYPE_BOOT_LOADER_NAME
	jne .tag_4

	; save pointer
	mov [multiboot_bootloader], ebp
	jmp .next_tag
	
.tag_4:	; case 4: Basic Meminfo
	cmp eax, MULTIBOOT_TAG_TYPE_BASIC_MEMINFO
	jne .tag_5

	; save pointer
	mov [multiboot_basic_meminfo],ebp
	jmp .next_tag
	
.tag_5:	; case 5: Boot device
	cmp eax, MULTIBOOT_TAG_TYPE_BOOTDEV
	jne .tag_6

	mov [multiboot_bootdev], ebp
	jmp .next_tag

.tag_6:	; case 6: Memory Map
	; mmap will have to be parsed later, lets save it at the moment
	cmp eax, MULTIBOOT_TAG_TYPE_MMAP
	jne .next_tag

	mov [multiboot_mmap], ebp
	jmp .next_tag

.next_tag:
	mov ecx, [ebp + multiboot_tag_header.tag_size]
	
	; ALIGN 8
	; (size + 7) & (~7)
	add ecx, 0x7
	mov eax, 0x7
	not eax
	and ecx, eax

	; point to next tag
	add ebp, ecx
	jmp .tag_loop

.tag_done:
	pop ebp

	; Setting GDT
	call _setgdt

	; jmp to C file 
	call	_kernel_start
	; should never reach here
halt:
	cli
	hlt
	jmp halt
_start_end:

;-----------------------------------------------------------------------------
section .data

missing_magic	db	"FATAL: Incorrect Multiboot Magic, Halting...", 0xA, 0

;	.loader_name	db ?
;	.command_line	db ?


;----------------------------------------------------------------------------
section .bss

	global multiboot
	global multiboot_boot_loader 
ALIGN 16
multiboot_hdr:		resb	0x4000

ALIGN 16
multiboot:
	.data_magic	resq	1
	.mem_lower	resq	1
	.mem_upper	resq	1
	.bios_dev	resq	1
	.bios_part	resq	1
	.bios_subpart	resq	1
	.mmap		resb	MAX_MMAP_SIZE	; lets hope that is sufficient 0x400
	.command_line	resb	MAX_STR_SIZE

multiboot_boot_loader:	resb	MAX_STR_SIZE

; stack on x86 must be 16-byte aligned - System V ABI standard
ALIGN 16

kernel_stack_bottom:
	resb	16384
kernel_stack_top:
