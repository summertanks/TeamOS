ARCH = i386
KERNEL = kernel.bin

all: os.iso
kernel/$(KERNEL):	
	@echo "Building Kernel"
	make -C ./kernel

os.iso: kernel/$(KERNEL)
	cp kernel/kernel.bin isodir/boot/
	grub-mkrescue -o os.iso isodir

build: os.iso

run: os.iso
	qemu-system-i386 -cdrom os.iso

debug: os.iso
	qemu-system-i386 -cdrom os.iso -s -S

clean:
	make -C ./kernel clean
	rm -f os.iso
	rm -f isodir/boot/kernel.bin
