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

	%include "include/arch/common/vga.inc" 

[BITS 32]

global	terminal_set_color
global	terminal_get_color
global	terminal_write_string
global	terminal_clearscreen

section .text

; Set default color
; IN al -> 8 bit : foreground 4 bits | background 4 bits
terminal_set_color:
	; saving to default
	mov [terminal_color], al
	ret

; Get default color
; OUT al -> 8 bit : foreground 4 bits | background 4 bits
terminal_get_color:
	; return current color
	mov al, [terminal_color]
	ret	

; Clear Screen, reset cursor


; Write string to terminal
; IN = ESI: string location
; OUT = ECX: string size
terminal_write_string:
	pusha
	xor ecx, ecx

	; Print String 
.write:
	mov al, [esi]

	; Check for end of string
	cmp al, 0
	jz .write_done

	; TODO: TAB
	; TODO: Backspace
	; TODO: Carriage Return

	; check for linefeed
	cmp al, 0xa
	jne .write_putchar
	call terminal_putchar.linefeed
	jmp .write_next

.write_putchar:
	call terminal_putchar

.write_next:
	inc esi
	inc ecx
	jmp .write

.write_done:
	; TODO : modify ecx in stack
	popa
	ret

; Puts character at current cursor position
; IN = al: ASCII char
terminal_putchar:
	call .get_offset	; return screen offset in dx	

 	; default color
	mov ah, [terminal_color]
	; character to first byte
	mov byte [VGA_BUFFER + edx], al
	; set color on second byte
	mov byte [VGA_BUFFER + edx + 1], ah

	call .inc_offset
	ret

.get_offset:
	push eax

	xor eax, eax	; simpler to work with
	xor edx, edx

	; load cursor - terminal_column at DH
	;		terminal_row at DL
	mov dx, [terminal_cursor_pos]

	; Sanity check - bounds assume 80*25
	; offset = (y * VGA_WIDTH * 2) + (x * 2)
	; one buffer entry is 2 bytes (dw)
	shl dh, 1	;	x = x*2
 	shl dl, 1	;	y = y*2

	mov al, VGA_WIDTH	; upper bits are 0
	
	; y * VGA_WIDTH
	mul dl			; eax = dl * eax => y * VGA_WIDTH * 2
	mov dl, dh
	xor dh, dh		; x => dl
	add dx, ax		; added offset x 
 
	pop eax
	ret

; increment cursor position by one, incase end of line, wrap to next
.inc_offset:
	; load cursor - terminal_column at DH
	;		terminal_row at DL
	xor edx, edx
	mov dx, [terminal_cursor_pos]
	
	; adjust cursor position
	inc dh
	cmp dh, VGA_WIDTH	
	jl .save_cursor
 	
	; inc reached end of the line, wrap around
	mov dh, 0
	inc dl

.check_screen_end:
	; end of screen
	cmp dl, VGA_HEIGHT
	jl .save_cursor
 	
	; TODO: shift screen up, dont wrap
	; set to start of the screen

.shift_screen:
	; slide screen up shift everything left in memory
	push esi
	push ecx
	push eax

	mov edi, VGA_BUFFER
	mov esi, edi
	add esi, VGA_WIDTH * 2	; each character takes 2 bytes

	mov ecx, (VGA_HEIGHT - 1) * VGA_WIDTH
	repz movsw

	mov ecx, VGA_WIDTH
	xor eax, eax
	repz stosw

	pop eax
	pop ecx
	pop esi

	dec dl
 
.save_cursor:
	push eax
	push ebx
	push edx

	xor eax, eax
	mov al, VGA_WIDTH	; upper bits are 0
	mul dl			; eax = dl * eax => y * VGA_WIDTH
	mov dl, dh
	xor dh, dh		; x => dl
	add dx, ax		; added offset x 
	mov bx, dx

	mov al, 0x0E
	mov dx, 0x3D4
	out dx, al	; out 0x3D4, 0x0E

	inc dx		; 0x3D5
	mov al, bh
	out dx, al	; out 0x3D5, offset_y

	dec dx		; 0x3D4
	mov al, 0x0F
	out dx, al	; out 0x3D4, 0x0F

	inc dx		; 0x3D5
	mov al, bl	;
	out dx, al	; out 0x3D5, offset_x

	pop edx
	pop ebx
	pop eax
	; Store new cursor position 
	mov [terminal_cursor_pos], dx
	ret

; Go to start of next line
.linefeed:
	; load cursor - terminal_column at DH
	;		terminal_row at DL
	xor edx, edx
	mov dx, [terminal_cursor_pos]
	; start of line
	mov dh, 0
	; move to next line
	inc dl
	
	jmp .check_screen_end

; Clear Screen
terminal_clearscreen:
	push edx
	push ecx
	push eax
	push edi

	xor edx, edx
	call terminal_putchar.save_cursor
	
	xor eax, eax
	mov ecx, VGA_WIDTH * VGA_HEIGHT * 2 	
	mov edi, VGA_BUFFER
	repz stosb

	pop edi
	pop eax
	pop ecx
	pop edx
	ret

	
;-------------------------------------------------------

section .data

; default color  
	terminal_color	db 	((VGA_COLOR_BLACK << 4) | VGA_COLOR_WHITE)

;------------------------------------------------------

section .bss

; current cursor position 
terminal_cursor_pos:
	terminal_column	resb 	1
	terminal_row	resb 	1
