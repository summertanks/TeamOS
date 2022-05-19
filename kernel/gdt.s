; Team OS
; Copyright (c) 2022 Harkirat S Virk

; Structure for Global Descriptor Table
; Five Segments - Null, Kernel Code, Kernel Data, User Code, User Data
;

ALIGN 8
	global _setgdt

_setgdt:
	; load simple GDT
	lgdt [gdtr]

	; long jump to enable GDT
	; seg 0x8 - first entry to GDT - Kernel Code
	jmp 0x8:enable_gdt

.enable_gdt:
	mov cx, 0x10 ;; data seg
 	mov ss, cx
	mov ds, cx
	mov es, cx
	mov fs, cx
	
	mov cx, 0x20 ;; GS seg
	mov gs, cx
	ret
	
ALIGN 32

gdtr:
	dw gdt32_end - gdt32 - 1
	dd gdt32

ALIGN 32

gdt32:
	;; TODO: Make Non overlapping

	;; Entry 0x0: Null descriptor
	;; First seg desc is expected to be NULL  
	dq 0x0
	
	;; Kernel Code Segment  
	;; Entry 0x8: Code segment
	dw 0xffff          ;Limit
	dw 0x0000          ;Base 15:00
	db 0x00            ;Base 23:16
	dw 0xcf9a          ;Flags / Limit / Type [F,L,F,Type]
	db 0x00            ;Base 32:24
  
	;; Kernel Data Segment
	;; Entry 0x10: Data segment
	dw 0xffff          ;Limit
	dw 0x0000          ;Base 15:00
	db 0x00            ;Base 23:16
	dw 0xcf92          ;Flags / Limit / Type [F,L,F,Type]
	db 0x00            ;Base 32:24
  
	;; User Code Segment
	;; Entry 0x18: Code segment
	dw 0x0100          ;Limit
        dw 0x1000          ;Base 15:00
        db 0x00            ;Base 23:16
        dw 0x409a          ;Flags / Limit / Type [F,L,F,Type]
        db 0x00            ;Base 32:24

	;; User Data Segment
	;; Entry 0x20: Data segment
	dw 0x0100          ;Limit
	dw 0x1000          ;Base 15:00
	db 0x00            ;Base 23:16
	dw 0x4092          ;Flags / Limit / Type [F,L,F,Type]
	db 0x00            ;Base 32:24

gdt32_end:
