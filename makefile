all: run

build:
	nasm -f bin bootloader.asm -o bootloader.bin

run: build
	qemu-system-x86_64 -drive format=raw,file=bootloader.bin

clean:
	rm -f bootloader.bin
