CC := gcc
LD := ld
ASM := nasm

CCPARAMS  := -m32 -fno-use-cxa-atexit -fno-builtin -fno-rtti -fno-exceptions
ASMPARAMS := -felf32
LDPARAMS  := -melf_i386

ARCHOBJS = loader.o kernel.o vga.o gdt.o idt.o nmi.o pic.o tss.o
OBJS += $(foreach obj, $(ARCHOBJS), $(addprefix arch/i386/, $(obj)))

all: kernel.bin

%.o : %.c
	@echo compiling $<
	$(CC) $(GCCPARAMS) -o $@ -c $<

%.o : %.s
	@echo compiling $<
	$(ASM) $(ASMPARAMS) -o $@ $<

kernel.bin: linker.ld $(OBJS)
	@echo Starting to link $(ARCHOBJS)
	$(LD) $(LDPARAMS) -T $< -o $@ $(OBJS)

clean: 
	rm -f $(OBJS)
	rm -f kernel.bin

