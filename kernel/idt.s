; Team OS
; Copyright (c) 2022 Harkirat S Virk

; Interrupts give the ability to respond to synchronous and asynchronous events
; Broadly there are
;	Software Interrupts via Int xxh instruction
;	Interrupts (External)- Maskable & non-Maskable
;	Exception - Processor (Fault, Traps & Aborts) & Programmed

; NMI and Exception range from 0 to 31 (0x0 - 0x1F)
; Faults - caused before the instruction is executed, permits restart
; Traps - Exception reported after the instruction
; Aborts - unrecoverable severe errors (including hardware)

; 0            Divide error
; 1            Debug exceptions
; 2            Nonmaskable interrupt
; 3            Breakpoint (one-byte INT 3 instruction)
; 4            Overflow (INTO instruction)
; 5            Bounds check (BOUND instruction)
; 6            Invalid opcode
; 7            Coprocessor not available
; 8            Double fault
; 9            (reserved)
; 10           Invalid TSS
; 11           Segment not present
; 12           Stack exception
; 13           General protection
; 14           Page fault
; 15           (reserved)
; 16           Coprecessor error
; 17-31        (reserved)

; IF Flag - for maskable interrupts via external INTr Pin
;         - if CPL <= IOPL. A protection exception occurs when CPL > IOPL
;	  - Task switches, POPF and IRET load the flags register - modifies IF
;	  - Interrupts through interrupt gates reset IF, disabling interrupts
;	  - Interrupts throup trap doesnt reset IF

; RF bit in  EFLAGS controls the recognition of debug faults

; After MOV/POP involving SS processor inhibits NMI, INTR, debug exceptions, 
; and single-step traps at the instruction boundary following the instruction that changes SS

; Trap gates cause TF to be reset after the current value of TF is saved on 
; the stack as part of EFLAGS - IRET instruction restores TF to the value in the EFLAGS

;                                80386 TASK GATE
;   31                23                15                7                0
;  +-----------------+-----------------+---+---+---------+-----------------+
;  |#############(NOT USED)############| P |DPL|0 0 1 0 1|###(NOT USED)####|4
;  |-----------------------------------+---+---+---------+-----------------|
;  |             SELECTOR              |#############(NOT USED)############|0
;  +-----------------+-----------------+-----------------+-----------------+
;
;                                80386 INTERRUPT GATE
;   31                23                15                7                0
;  +-----------------+-----------------+---+---+---------+-----+-----------+
;  |           OFFSET 31..16           | P |DPL|0 1 1 1 0|0 0 0|(NOT USED) |4
;  |-----------------------------------+---+---+---------+-----+-----------|
;  |             SELECTOR              |           OFFSET 15..0            |0
;  +-----------------+-----------------+-----------------+-----------------+
;
;                                80386 TRAP GATE
;   31                23                15                7                0
;  +-----------------+-----------------+---+---+---------+-----+-----------+
;  |          OFFSET 31..16            | P |DPL|0 1 1 1 1|0 0 0|(NOT USED) |4
;  |-----------------------------------+---+---+---------+-----+-----------|
;  |             SELECTOR              |           OFFSET 15..0            |0
;  +-----------------+-----------------+-----------------+-----------------+
;
;  31                                  15                              2 1 0
;  +---------------+-------------------+---------------------+-------+-+-+-+
;  |###################################|                             |T| |E|
;  |###########UNDEFINED###############|     SELECTOR INDEX          | |I| |
;  |###################################|                             |I| |X|
;  +---------------+-------------------+-----------------+-----------+-+-+-+
;  Ext - External Event, TI - Referes to GDT/LDT, I - Index refers to gate desc (IDT)
; Stack state

; Without Priviledge Transistion
; <Old SS:ESP> | Old EFLAGS (16) | xxxx (8) Old CS(8) | Old EIP (16) | Error Code (16) | <New SS:ESP>

; With Priviledge Transistion
; <Old SS:ESP> | xxxx (8) Old SS (8) | Old ESP (16) | Old EFLAGS (16) | xxxx (8) Old CS(8) | Old EIP (16) | Current SS:ESP

; CPU does not permit an interrupt to transfer control to a procedure in a segment of lesser privilege

struc idt
.offset_high	resw	1
.offset_low	resw	1
.selector	resb	1
.flags		resb	1
endstruc

section .text
	global _setidt

_setidt:
	ret

section	.bss
;	idt_null	0


