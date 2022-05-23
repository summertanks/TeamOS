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

	%include "include/vga.inc" 

[BITS 32]

extern	init_vga
extern	terminal_write_string

global	_kernel_start

_kernel_start:
	mov esi, os_description
	call terminal_write_string
loop:
	jmp loop

;------------------------------------------------------------
section .data

os_description 	db "Starting TeamOS", 0xA, 	; 0xA = line feed
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 0xA,
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training",
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 
		db "32 Bit Kernel from Scratch in assembly for training", 0xA
		db "Copyright (c) Harkirat S Virk", 0xA, 0
