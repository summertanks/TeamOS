GCCPARAMS  = -m32 -fno-use-cxa-atexit -fno-builtin -fno-rtti -fno-exceptions
NASMPARAMS = -felf32
LDPARAMS   = -melf_i386

objects= loader.o kernel.o vga.o gdt.o idt.o pic.o nmi.o

%.o : %.c
	gcc $(GCCPARAMS) -o $@ -c $<

%.o : %.s
	nasm $(NASMPARAMS) -o $@ $<

kernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

OS.iso: kernel.bin
	cp kernel.bin isodir/boot/
	grub-mkrescue -o OS.iso isodir

build: OS.iso

run: OS.iso
	qemu-system-i386 -cdrom OS.iso

clean: 
	rm -f *.o
	rm -f OS.iso
	rm -f kernel.bin
	rm -f isodir/boot/kernel.bin

