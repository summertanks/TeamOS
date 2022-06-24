; Team OS
; Copyright (c) 2022 Harkirat S Virk

; Structure for Global Descriptor Table
; Five Segments - Null, Kernel Code, Kernel Data, User Code, User Data
;

ALIGN 8
	global _setgdt
	global gdt32

_setgdt:
	; load simple GDT
	lgdt [gdtr]

	; long jump to enable GDT
	; seg 0x8 - first entry to GDT - Kernel Code
	jmp 0x8:.enable_gdt

.enable_gdt:
	mov cx, 0x10 ;; data seg
 	mov ss, cx
	mov ds, cx
	mov es, cx
	mov fs, cx
	
	mov cx, 0x20 ;; GS seg
	mov gs, cx
	ret

section .data
	
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

	; Base: 32 bit value containing the linear address where the segment begins.
	; Limit: 20-bit value, tells the maximum addressable unit, either in 1 byte units, or in 4KiB pages.

	; dw limit_low		- The lower 16 bits of the limit (15:0)
	; dw base_low		- The lower 16 bits of the base (15:0)
	; db base_middle	- The next 8 bits of the base (23:16)
	; db access		- 8 bits
	;
	;	  7   6   5   4   3   2    1    0          
	;	+---------------------------------+
	;	| P |  DPL  | S | E | DC | RW | A |	DATA & CODE Segments
	;	+---------------------------------+
	;
	;			- A 	(1 bit) accessed - bit is set to 1 by hardware when the segment 
	;					is accessed, and cleared by software.
	;			- R/W 	(1 bit) Read Write 
	;					Code Seg If set, the segment may be read from, not if clear
	;					Data Seg If set, the data segment may be not written to, not if clear
	;					Cannot write to code segment and cannot execure data segment
	;			- DC	(1 bit) DC: Direction bit/Conforming bit.
	;					For data selectors: Direction bit. If clear (0) the segment grows up. 
	;					If set (1) the segment grows down, ie. the Offset has to be greater than the Limit.
	;					For code selectors: Conforming bit. If clear (0) code in this segment can only be 
	;					executed from the ring set in DPL. If set (1) code in this segment can be executed 
	;					from an equal or lower privilege level. this is applicable to far jmp
	;			- E	(1 bit) Executable bit. If clear (0) the descriptor defines a data segment. 
	;					If set (1) it defines a code segment which can be executed from
	;			- S	(1 bit) S: Descriptor type bit. If clear (0) the descriptor defines a system segment (eg. a TSS). 
	;					If set (1) it defines a code or data segment.
	;			- DPL	(2 bit) DPL=Descriptor privilege level Privilege level (ring) 
	;			- P	(1 bit) Present If clear, a "segment not present" 
	;					exception is generated on any reference to this segment
	;
	;	  7   6   5   4   3   2    1    0          
	;	+---+-------+---+-----------------+
	;	| P |  DPL  | S |       Type      |	System Segment
	;	+---+-------+---+-----------------+
	;			- Type	(2 bit) Type: Type of system segment.
	;					0x1: 16-bit TSS (Available)
	;					0x2: LDT
	;					0x3: 16-bit TSS (Busy)
	;					0x9: 32-bit TSS (Available)
	;					0xB: 32-bit TSS (Busy)
	; db flag_limit		- 8 bits
	;			- upper 4 bits - Flags
	;			- lower 4 bits - upper bits of base (19:16)
	; 
	;	  3   2    1      0
	;	+---+----+---+----------+
	;	| G | DB | L | Reserved | Flags
	;	+---+----+---+----------+
	;			- G	(1 bit) Indicates the size the Limit value is scaled by. 
	;					If clear (0), the Limit is in 1 Byte blocks (byte granularity). 
	;					If set (1), the Limit is in 4 KiB blocks (page granularity).
	;
	;			- DB	(1 bit) Size flag. 
	;					If clear (0), the descriptor defines a 16-bit protected mode segment. 
	;					If set (1) it defines a 32-bit protected mode segment. 
	;					A GDT can have both 16-bit and 32-bit selectors at once.
	;			- L	(1 bit) Long-mode code flag. 
	;					If set (1), the descriptor defines a 64-bit code segment. When set, DB should always be clear. 
	;					For any other type of segment (other code types or any data segment), it should be clear (0).
	;
	; db base_high		- The last 8 bits of the base (31:24)

	;; Kernel Code Segment  
	;; Entry 0x8: Code segment
	;; Base - 0x00000000
	;; Limit - 0xffff
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
