ARCH = i386

all: 
	@echo "Building Kernel"
	make -C ./kernel

os.iso: kernel.bin
	cp kernel/kernel.bin isodir/boot/
	grub-mkrescue -o OS.iso isodir

build: os.iso

run: os.iso
	qemu-system-i386 -cdrom OS.iso

clean:
	make -C ./kernel clean
	rm -f OS.iso
	rm -f isodir/boot/kernel.bin
