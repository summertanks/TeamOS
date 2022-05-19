;
;

%define	PIC_Master	0x20
%define PIC_Slave	0xA0

%define PIC_Master_IRQ	0x20	; 0x20h -> 0x2fh - After remapping
%define PIC_Slave_IRQ	0x70	; 0x70h -> 0x77h

%define PIC_Master_Command	PIC_Master
%define PIC_Master_Data		PIC_Master + 1

%define PIC_Slave_Command	PIC_Slave
%define PIC_Slave_Data		PIC_Slave + 1

%define PIC_EOI			0x20

; PIC End of Interrupt
; eax: interrupt number
PIC_sendEOI:
	push eax
	cmp al, PIC_Slave_IRQ
	mov al, PIC_EOI
	jl .master
.slave:
	out PIC_Slave, al
	jmp .done
.master:
	out PIC_Master, al
.done:
	pop eax
	ret

