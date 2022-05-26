;
;
;

[BITS 32]

%define PIC_Master_IRQ		0x20	; 0x20h -> 0x2fh - After remapping
%define PIC_Slave_IRQ		0x70	; 0x70h -> 0x77h

%define PIC_Master_Command	0x20
%define PIC_Master_Data		PIC_Master_Command + 1

%define PIC_Slave_Command	0xA0
%define PIC_Slave_Data		PIC_Slave_Command + 1

%define PIC_EOI			0x20

%define PIC_READ_IRR		0x0A	; OCW3 irq ready next CMD read
%define PIC_READ_ISR		0x0B	; OCW3 irq service next CMD read


; TOTO - Handle spurious IRQ wiki.osdev.org/PIC

; Initialise the IRQ
pic_init_IRQ:
	push ax
	push cx
	; use pic_remap_IRQ as helper
	
	; Master - AH: 0, CL - 0x20
	xor ah,ah
	mov cl, PIC_Master_IRQ
	call pic_remap_IRQ

	; Slave - AH: 1, CL - 0x70
	mov ah, 1
	mov cl, PIC_Slave_IRQ
	call pic_remap_IRQ

	pop cx
	pop ax
	ret	


; PIC End of Interrupt
; eax: interrupt number
pic_sendEOI:
	cmp al, PIC_Slave_IRQ
	mov al, PIC_EOI
	jl .master
.slave:
	out PIC_Slave_Command, al
	ret
.master:
	out PIC_Master_Command, al
	ret

; Remapping the PIC
; AH : PIC to remap - 0: Master 1: Slave
; CL : vector offset - IRQ becomes CX -> CX + 7
pic_remap_IRQ:

	or ah, ah
	jnz .slave

.master:
	; save masks
	in al, PIC_Master_Data
	push ax
	
	; start init
	; ICW1_ICW4 | ICW1_INIT (0x10 | 0x01)
	mov al, 0x11
	out PIC_Master_Command, al
	call io_wait

	; Vector Offset
	mov al, cl
	out PIC_Master_Data, al
	call io_wait

	; Master -> Slave PIC at IRQ2
	mov al, 4
	out PIC_Master_Data, al
	call io_wait

	; 
	mov al, 1
	out PIC_Master_Data, al
	call io_wait

	; restored saved masks
	pop ax
	out PIC_Master_Data, al
	ret

.slave:
        ; save masks
        in al, PIC_Slave_Data
	push ax

        ; start init
        ; ICW1_ICW4 | ICW1_INIT (0x10 | 0x01)
	mov al, 0x11
        out PIC_Slave_Command, al
        call io_wait

        ; Vector Offset
	mov al, cl
        out PIC_Slave_Data, al
        call io_wait

        ; Slave -> is cascade identity
	mov al, 2
        out PIC_Slave_Data, al
        call io_wait

        ; 
	mov al, 1
        out PIC_Slave_Data, al
        call io_wait

        ; restored saved masks
	pop ax
        out PIC_Slave_Data, al
        ret

; Mask IRQ 
; AL: IRQ number
; Ignore incorrect IRQ numbers

pic_mask:
	push cx
	mov cl, al
	
	; doesnt fit either IRQ ranges
	and al, 10001000b
	jnz .done

	; zero out lower bits and invert
	mov al, cl
	and al, 01110000b
	not al

	; calculate pin to mask
	; (1 << IRQ line)
	and cl, 00000111b
	mov ch, 1
	shl ch, cl

	; check for 0x70 range
	xor al, 10001111b
	jz .slave

	; check of 0x20 range
	and al, 01010000b
	jnz .done

; range 0x20h - 0x27h
.master:
	in al, PIC_Master_Data	
	or al, ch
	out PIC_Master_Data, al
	jmp .done

; range 0x70h - 0x77h
.slave:
	in al, PIC_Slave_Data
	or al, ch
	out PIC_Slave_Data, al

.done:
	pop cx
	ret


; UnMask IRQ 
; AL: IRQ number
; Ignore incorrect IRQ numbers

pic_unmask:
        push cx
        mov cl, al

        ; doesnt fit either IRQ ranges
        and al, 10001000b
        jnz .done

        ; zero out lower bits and invert
        mov al, cl
        and al, 01110000b
        not al

        ; calculate pin to unmask
	; ~(1 << IRQ Line)
        and cl, 00000111b
        mov ch, 1
        shl ch, cl
	not ch

        ; check for 0x70 range
        xor al, 10001111b
        jz .slave

        ; check of 0x20 range
        and al, 01010000b
        jnz .done

; range 0x20h - 0x27h
.master:
        in al, PIC_Master_Data
        and al, ch
        out PIC_Master_Data, al
        jmp .done

; range 0x70h - 0x77h
.slave:
        in al, PIC_Slave_Data
        and al, ch
        out PIC_Slave_Data, al

.done:
        pop cx
        ret

; Helper Function - Read IRQ
; AL : Request Register Type (ISR, IRR)
pic_get_irq:
	; Write ocw3
	out PIC_Master_Command, al
	out PIC_Slave_Command, al
	
	; Response 
	in al, PIC_Slave_Command
	mov ah, al
	in al, PIC_Master_Command

	; Register value in ax
	ret

; Get IRR State 16 bits from both PIC
; Value in AX
pic_get_irr:
	mov ax, PIC_READ_IRR
	call pic_get_irq
	ret

; Get ISR State 16 bits from both PIC
; Value in AX
pic_get_isr:
	mov ax, PIC_READ_ISR
	call pic_get_irq
	ret

; Disabling PIC 
; Incase we are using APIC & IOPIC
pic_disable:
	push ax
	mov al, 0xff	; Disable
	out PIC_Master_Data, al
	out PIC_Slave_Data, al
	pop ax
	ret

; hardware based delay
; one call - 1ms
io_wait:
        push ax
        xor ax, ax
        out 0x80, al
        ret

