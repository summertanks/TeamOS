[BITS 32]

VGA_WIDTH 	equ 	80
VGA_HEIGHT 	equ 	25
 
VGA_COLOR_BLACK		equ 	0
VGA_COLOR_BLUE		equ 	1
VGA_COLOR_GREEN		equ 	2
VGA_COLOR_CYAN		equ 	3
VGA_COLOR_RED		equ 	4
VGA_COLOR_MAGENTA	equ 	5
VGA_COLOR_BROWN		equ 	6
VGA_COLOR_LIGHT_GREY	equ 	7
VGA_COLOR_DARK_GREY	equ 	8
VGA_COLOR_LIGHT_BLUE	equ 	9
VGA_COLOR_LIGHT_GREEN	equ	10
VGA_COLOR_LIGHT_CYAN	equ	11
VGA_COLOR_LIGHT_RED	equ 	12
VGA_COLOR_LIGHT_MAGENTA	equ 	13
VGA_COLOR_LIGHT_BROWN	equ 	14
VGA_COLOR_WHITE		equ	15

VGA_BUFFER		equ	0xB8000
 
global	init_vga
global	terminal_write_string

; Initialising defaults
; just initialise the colors
init_vga:
	push dx
	mov dh, VGA_COLOR_WHITE
	mov dl, VGA_COLOR_BLACK
	call terminal_set_color
	pop dx
	ret

; Setting default color
; IN = dl: bg color, dh: fg color
; OUT = none
terminal_set_color:
	shl dl, 4	; shift left 4 bit
	or dl, dh	; or with dh
	; dl -> 8 bit : foreground 4 bits | background 4 bits
	; saving 
	mov [terminal_color], dl
	ret


; Calculate offset based on cursor (x,y)
; IN = dl: y, dh: x
; OUT = dx: Index with offset 0xB8000 at VGA buffer
; TODO: sanity check on values

terminal_getoffset:
	; save eax
	push eax

	; offset = (y * VGA_WIDTH * 2) + (x * 2)
	; one buffer entry is 2 bytes (dw)
	shl dh, 1	;	x = x*2
 	shl dl, 1	;	y = y*2

	mov eax, VGA_WIDTH	; upper bits are 0
	; y * VGA_WIDTH
	mul dl			; eax = dl * eax 
	shr dx, 8		; shift right to dl
	add dx, ax		; 
 
	pop eax
	ret

; Put chartacter at cursor value (x,y)
; IN = dl: y, dh: x, al: ASCII char
; OUT = none
terminal_putchar_xy:
	pusha		; push all
	
	; get the offset location
	call terminal_getoffset
	mov ebx, edx

 	; default color
	mov dl, [terminal_color]
	; character to first byte
	mov byte [VGA_BUFFER + ebx], al
	; set color on second byte
	mov byte [VGA_BUFFER + ebx + 1], dl
 
	popa
	ret
 
; put character at current cursor position
; IN = al: ASCII char
terminal_putchar:
	; load cursor - terminal_column at DH, and terminal_row at DL
	mov dx, [terminal_cursor_pos]
 	; print character
	call terminal_putchar_xy

	; adjust cursor position
	inc dh
	cmp dh, VGA_WIDTH
	jne .cursor_moved
 	
	; wrap arround
	mov dh, 0
	inc dl
 
	; end of screen
	cmp dl, VGA_HEIGHT
	jne .cursor_moved
 	
	mov dl, 0
 
.cursor_moved:
	; Store new cursor position 
	mov [terminal_cursor_pos], dx
	ret

; Print String 
; IN = cx: length of string, ESI: string location
; OUT = none
terminal_write:
	pusha

.loop:
	mov al, [esi]
	call terminal_putchar
 
	; decrease counter
	dec cx
	cmp cx, 0
	je .done
 
	inc esi
	jmp .loop

.done:
	popa
	ret

; Calculate String length
; IN = ESI: zero delimited string location
; OUT = ECX: length of string
terminal_strlen:
	push eax
	push esi
	mov ecx, 0

.loop:
	mov al, [esi]
	cmp al, 0
	je .done
 
	inc esi
	inc ecx
	jmp .loop
 
 .done:
 	pop esi
	pop eax
 	ret

; Write string to terminal
; IN = ESI: string location
; OUT = none
terminal_write_string:
	pusha
	; calculate the string length
	call terminal_strlen
	; print string
	call terminal_write
	popa
	ret
 
; default color  
	terminal_color	db 	0

; current cursor position 
terminal_cursor_pos:
	terminal_column	db 	0
	terminal_row	db 	0
