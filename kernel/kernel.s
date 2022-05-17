[BITS 32]

extern	init_vga
extern	terminal_write_string

global	_kernel_start

_kernel_start:
	call init_vga
	mov esi, os_description
	call terminal_write_string
loop:
	jmp loop


os_description db "Starting TeamOS", 0xA, 0 ; 0xA = line feed

