NASMPARAMS = -felf32

objects= loader.o kernel.o vga.o gdt.o idt.o pic.o nmi.o

%.o : %.s
	nasm $(NASMPARAMS) -o $@ $<


