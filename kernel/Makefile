GCCPARAMS = -m32 -fno-use-cxa-atexit -fno-builtin -fno-rtti -fno-exceptions
NASMPARAMS = -felf32
LDPARAMS =-melf_i386

objects= loader.o kernel.o vga.o

%.o : %.c
	gcc $(GCCPARAMS) -o $@ -c $<

%.o : %.s
	nasm $(NASMPARAMS) -o $@ $<

TOSKernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

install: TOSKernel.bin
	sudo cp $< /boot/TOSKernel.bin
