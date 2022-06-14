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
	%include "include/arch/common/c32.mac"

[BITS 32]

global	terminal_set_color
global	terminal_get_color
global	terminal_write_string
global	terminal_write_chars
global	terminal_write_hex
global	terminal_clearscreen

section .text

;-----------------------------------------------------------------------------
; Set default color
; IN -> 8 bit : foreground 4 bits | background 4 bits
proc terminal_set_color,eax

arg	_color,1
	
	mov al, _color

	; saving to default
	mov [terminal_color], al

endproc

;-----------------------------------------------------------------------------
; Get default color
; OUT -> 8 bit : foreground 4 bits | background 4 bits
terminal_get_color:
	; return current color
	mov al, [terminal_color]
	ret	

; Clear Screen, reset cursor

;----------------------------------------------------------------------------
; Write hex to terminal
; IN = number to print - EAX
; Used registers -  ECX
proc terminal_write_hex, ecx

arg	_hex, 4

	; print prefix 0x
	mov eax, '0'
	call terminal_putchar
	mov eax, 'x'
	call terminal_putchar

	; get value to print
	mov ecx, _hex
	or ecx, ecx
	jne .write
	mov eax, '0'
	call terminal_putchar
	jmp .write_done

.write:
	; load byte to print
	mov eax, ecx
	and eax, 0xf0000000
	shr eax, 0x1c		; shift to last digit
	
	cmp eax, 0x9
	jg .upper
	add eax, 0x30
	jmp .write_digit
.upper:
	add eax, 0x37

.write_digit:
	call terminal_putchar
	shl ecx, 0x4
	or ecx, ecx
	jnz .write_done
	
.write_done:
	; return number of characters printed
	; current string loc - starting loc

	call update_hardware_cursor
endproc


;----------------------------------------------------------------------------
; Write fixed numer of characters to terminal
; IN = string location: ESI
; IN = character count: ECX
; Used registers - ESI, ECX
proc terminal_write_chars, ecx, esi

arg	_strloc, 4
arg	_charcount, 4

	; get string address from stack
	mov esi, _strloc
	mov ecx, _charcount	
.write:
	; load byte to print
	movzx eax, byte [esi]
	
	push ecx		; terminal_putchar destroys ecx
	; place character
	call terminal_putchar
	pop ecx

	; move to the next byte
	inc esi
	loop .write

.write_done:
	; return number of characters printed
	; current string loc - starting loc

	call update_hardware_cursor
	mov eax, esi
	sub eax, _strloc
endproc


;----------------------------------------------------------------------------
; Write string to terminal
; IN = ESI: string location
; Used registers - ESI, ECX
proc terminal_write_string, ecx, esi

arg	_strloc1,4

	; get string address from stack
	mov esi, _strloc1
	
.write:
	; load byte to print
	movzx eax, byte [esi]

	; Check for end of string '\0'
	or al, al
	jz .write_done

	; place character
	call terminal_putchar

	; move to the next byte
	inc esi
	jmp .write

.write_done:
	; return number of characters printed
	; current string loc - starting loc

	call update_hardware_cursor
	mov eax, esi
	sub eax, _strloc
endproc

;-----------------------------------------------------------------------------
; Puts character at current cursor position
; IN = al: ASCII char
terminal_putchar:


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
	shl dh, 1		;	x = x*2
 	shl dl, 1		;	y = y*2

	mov al, VGA_WIDTH	; upper bits are 0
	
	; y * VGA_WIDTH
	mul dl			; eax = dl * eax => y * VGA_WIDTH * 2
	mov dl, dh
	xor dh, dh		; x => dl
	add dx, ax		; added offset x 
 
	pop eax
	
	; the buffer offset is in dx
	xor ecx, ecx		; set ecx = 1
	inc ecx			; print one char 

.tab:
	; Check for tab
	cmp al, 0x9
	jne .backspace

	mov al, ' '		; space
	mov cl, 0x8		; hard coded for 8 spaces
	movzx ecx, cl		; zero out the higher bits
	jmp .print

.backspace:
	cmp al, 0x8
	jne .return

	; TODO Backspace logic
	jmp .print

.return:
	cmp al, 0x0D
	jne .linefeed

	; TODO Carriage Return
	jmp .print

.linefeed:
	; check for linefeed
	cmp al, 0xa
	jne .print
	
	mov ax, [terminal_cursor_pos]
	mov ah, VGA_WIDTH - 1		; point to end of line
	mov [terminal_cursor_pos], ax	; save
	call .inc_offset		; not increment cursor
	ret

.print:
 	; default color
	mov ah, byte [terminal_color]

.print_loop:

	; character to first byte
	mov byte [VGA_BUFFER + edx], al
	; set color on second byte
	mov byte [VGA_BUFFER + edx + 1], ah
	
	inc edx			; to the next location
	inc edx

	call .inc_offset	; should update dx
	loop .print_loop
	
	ret

; increment cursor position by one, incase end of line, wrap to next
.inc_offset:
	; load cursor - terminal_column at DH
	;		terminal_row at DL
	push eax
	xor eax, eax
	mov ax, [terminal_cursor_pos]
	
	; adjust cursor position
	inc ah
	cmp ah, VGA_WIDTH
	jl .save_cursor
 	
	; inc reached end of the line, wrap around
	mov ah, 0
	inc al

.check_screen_end:
	; end of screen
	cmp al, VGA_HEIGHT
	jl .save_cursor
 	
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
	mov ah, byte [terminal_color]
	mov al, ' '
	repz stosw

	pop eax
	pop ecx
	pop esi

	dec al

.save_cursor:
	
	; Store new cursor position 
	mov [terminal_cursor_pos], ax
	pop eax
	ret



;	CRT Microcontroller - Index Register
;	Index Offset	CRT Controller Register
;	0x0	Horizontal Total
;	0x1	Horizontal Display Enable End
;	0x2	Start Horizontal Blanking
;	0x3	End Horizontal Blanking
;	0x4	Start Horizontal Retrace Pulse
;	0x5	End Horizontal Retrace
;	0x6	Vertical Total
;	0x7	Overflow
;	0x8	Preset Row Scan
;	0x9	Maximum Scan Line
;	0xA	Cursor Start
;	0xB	Cursor End
;	0xC	Start Address High
;	0xD	Start Address Low
;	0xE	Cursor Location High
;	0xF	Cursor Location Low
;	0x10	Vertical Retrace Start
;	0x11	Vertical Retrace End
;	0x12	Vertical Display Enable End
;	0x13	Offset
;	0x14	Underline Location
;	0x15	Start Vertical Blanking
;	0x16	End Vertical Blanking
;	0x17	CRT Mode Control
;	0x18	Line Compare

update_hardware_cursor:
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
	ret
	

; Clear Screen
proc terminal_clearscreen, edx, ecx, edi

	xor edx, edx
	call terminal_putchar.save_cursor
	
	xor eax, eax
	mov ecx, VGA_WIDTH * VGA_HEIGHT	
	mov edi, VGA_BUFFER
	repz stosw

endproc
	
;-------------------------------------------------------

section .data

; default color  
	terminal_color		db	((VGA_COLOR_BLACK << 4) | VGA_COLOR_WHITE)
	terminal_hex_prefix	db	"0x"

;------------------------------------------------------

section .bss

; current cursor position 
terminal_cursor_pos:
	terminal_column	resb 	1
	terminal_row	resb 	1
