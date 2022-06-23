CC := gcc
LD := ld
ASM := nasm


CCPARAMS  := -m32 -O0 -fno-pic -fno-builtin -fno-exceptions -fno-stack-protector -nostdlib -nodefaultlibs -Wall -Wextra
ASMPARAMS := -felf32
LDPARAMS  := -melf_i386

KERNOBJS = kernel.o
ARCHOBJS = loader.o vga.o gdt.o idt.o nmi.o pic.o tss.o
COMMONOBJS = printk.o string.o

OBJS += $(foreach obj, $(ARCHOBJS), $(addprefix arch/i386/, $(obj)))
OBJS += $(foreach obj, $(COMMONOBJS), $(addprefix common/, $(obj)))
OBJS += $(KERNOBJS)

all: kernel.bin

%.o : %.c
	@echo compiling $<
	$(CC) $(CCPARAMS) -o $@ -c $<

%.o : %.s
	@echo compiling $<
	$(ASM) $(ASMPARAMS) -o $@ $<

kernel.bin: linker.ld $(OBJS)
	@echo Starting to link $(ARCHOBJS)
	$(LD) $(LDPARAMS) -T $< -o $@ $(OBJS)

clean: 
	rm -f $(OBJS)
	rm -f kernel.bin

