; Team OS
; Copyright (c) 2022 Harkirat S Virk

; multiboot declarations
%define MULTIBOOT2_HEADER_MAGIC                 0xe85250d6
%define MULTIBOOT2_BOOTLOADER_MAGIC             0x36d76289
%define MULTIBOOT_ARCHITECTURE_I386  		0x0
%define MULTIBOOT_TAG_TYPE_FRAMEBUFFER       	8
%define MULTIBOOT_HEADER_TAG_FRAMEBUFFER  	5
%define MULTIBOOT_HEADER_TAG_OPTIONAL 		1
%define MULTIBOOT_TAG_TYPE_END			0

extern	_kernel_start
;extern __BSS_START
;extern __BSS_END

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
	dw	MULTIBOOT_TAG_TYPE_END
	dw	0
	dd	8

multiboot_header_end:

ALIGN 8

section .text
        global  _start

_start:
	; loader code - coming from _start
	; bootloader has loaded to 32 bit protected mode
	; Interrupts disabled
	; Paging disabled
	; Stack undefined
	
	; save multiboot structures
	mov DWORD [multiboot_data_magic], eax
	mov DWORD [multiboot_data_address], ebx

	; provide defined stack
	mov esp, kernel_stack_bottom
	mov ebp, esp
	
	;; zero .bss
;	mov edi, __BSS_START
;	mov ecx, __BSS_END
;	sub ecx, __BSS_START
;	mov eax, 0
;	rep stosb

	call	_kernel_start
	; should never reach here
halt:
	cli
	hlt
	jmp halt
_start_end:

section .data
	global multiboot_data_magic
	global multiboot_data_address

multiboot_data_magic:		dq 0
multiboot_data_address:		dq 0
	
section .bss

; stack on x86 must be 16-byte aligned - System V ABI standard
ALIGN 16
kernel_stack_bottom:
	resb	16384
kernel_stack_top:
