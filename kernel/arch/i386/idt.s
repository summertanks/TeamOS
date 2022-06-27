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

%macro isr_noerr_code 1
global isr%1
isr%1:
	cli
	push byte 0
	push byte %1
	jmp isr_common_stub
%endmacro

%macro isr_err_code 1
global isr%1
isr%1:
	cli
	push byte %1
	jmp isr_common_stub
%endmacro

struc idt
.offset_high	resw	1
.offset_low	resw	1
.selector	resb	1
.flags		resb	1
endstruc

section .text
	global _setidt

isr_noerr_code	0	; Divide-by-zero exception
isr_noerr_code	1	; Debug exception
isr_noerr_code	2	; Non Maskable Interrupt Exception
isr_noerr_code	3	; Breakpoint Exception
isr_noerr_code	4	; Into Detected Overflow Exception
isr_noerr_code	5	; Out of Bounds Exception
isr_noerr_code	6	; Invalid Opcode Exception
isr_noerr_code	7	; No Coprocessor Exception
isr_err_code	8	; Double Fault Exception
isr_noerr_code	9	; Coprocessor Segment Overrun Exception
isr_err_code	10	; Bad TSS Exception
isr_err_code	11	; Segment Not Present Exception
isr_err_code	12	; Stack Fault Exception
isr_err_code	13	; General Protection Fault Exception
isr_err_code	14	; Page Fault Exception
isr_noerr_code	15	; Unknown Interrupt Exception
isr_noerr_code	16	; Coprocessor Fault Exception
isr_noerr_code	17	; Alignment Check Exception (486+)
isr_noerr_code	18	; Machine Check Exception (Pentium/586+)
isr_noerr_code	19	; Reserved
isr_noerr_code	20	; Reserved
isr_noerr_code	21	; Reserved
isr_noerr_code	22	; Reserved
isr_noerr_code	23	; Reserved
isr_noerr_code	24	; Reserved
isr_noerr_code	25	; Reserved
isr_noerr_code	26	; Reserved
isr_noerr_code	27	; Reserved
isr_noerr_code	28	; Reserved
isr_noerr_code	29	; Reserved
isr_noerr_code	30	; Reserved
isr_noerr_code	31	; Reserved


_setidt:
	ret

isr_common_stub:
	pusha
	; save segments	
	push ds
	push es
	push fs
	push gs

	; load kernel segments
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; save stack
	mov eax, esp
	push eax

	; call handler
	lea eax, _isr_handler
	call eax
	pop eax

	pop gs
	pop fs
	pop es
	pop ds
	popa
	add esp, 0x8	; cleans up pushed error code / irq number
	iret

section	.bss
;	idt_null	0


