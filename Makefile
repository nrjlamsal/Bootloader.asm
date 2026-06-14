all: run

build:
	nasm -f bin src/bootloader.asm -o bin/bootloader.bin
	nasm -f bin src/kernel.asm -o bin/kernel.bin
	cat bin/bootloader.bin bin/kernel.bin > bin/disk.img

run: build
	qemu-system-x86_64 -drive format=raw,file=bin/disk.img

clean:
	rm -f bin/*