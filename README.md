# Bootloader & 64‑bit Long Mode Project

This repository contains a ** x86 bootloader ** that loads a tiny kernel(just print Ok kernel and halt) and transitions the CPU from **16 bit Real Mode** all the way to **64‑bit Long Mode**.  The work was done step by step in about 2 weeks period of time with a lot of OS documentation reading.A lot of resources if you want to upgrade it further can be found on osdev.org which  has great artiles on each problem you will encounter.. Highly recommended.


##  File structure

 bootloader.asm =  12‑byte BIOS boot sector.  It sets up the stack, reads the kernel from disk, enables A20, builds a minimal 4‑level paging structure, enables PAE and Long Mode, loads a 64‑bit GDT, enables paging and finally jumps to the kernel at physical address 0x10000
kernel.asm = Tiny kernel which just prints Ok kernel and halts.
Makefile = Builds the bootloader, and kernel,asm to .bin and then combines them into disk.img (bootloader.bin + kernel.bin) such that booloader.bin is placed at 1st 512 bytes and kernel at 2nd 512 bytes on the disk


 Some data structue and concepts to understand before starting:
1. Global Descriptor Table(GDT) : 32‑bit GDT for protected mode and a separate 64‑bit GDT that contains a **null descriptor**, a **64‑bit code segment**, and an optional **64‑bit data segment** (the data segment is harmless but kept for completeness) were implemented in this program. . Read  CR0, CR3, CR4, IA32_EFER, and segment selector explanation from osdev.org  
GDT is a table that contains a list of ** descriptors ** which are used to define the attributes of the segments in the memory. It is a 64-bit table that contains a list of 64-bit descriptors.You can look up in os.dev or any yt video for futher information

2.Paging tables: Three 4 KB tables (PML4, PDPT, PD) are zeroed, linked together, and the first 2 MiB is mapped to address the memory we have. This gives the kernel an identity‑mapped address space sufficient for our simple demo.Later kernel and expand this page table to 5 level or accoriding to his needs.

3.long_mode_entry:  4 ‑bit entry point that doesnot use  ds/es/ss/fs/gs registers (as they’re ignored in long mode) still we implemented them just for completion sake.The stack is already set up in protected mode, so we don’t touch it and jumps to the kernel at 0x10000. 

##  How We Verified It

 **Size check** – The bootloader ends with (times 510-($-$$) db 0) and the magic word 0xAA55.  NASM will abort if the binary exceeds 510 bytes, guaranteeing it fits in a boot sector.
 **Hex dump** – Using  graphical hex editor like ghex  i saw real code, large zero padding, and the terminating 55 AA bytes.
 **QEMU test** – make run launches QEMU, which prints the bright green message KERNEL OK on the screen, proving that:
  1. The bootloader correctly loaded the kernel.
  2. Paging and Long Mode were successfully enabled.
  3. The kernel executed in true 64‑bit mode.

  Note : when kenel prints the LFCR is not managed and   QEMU already has some of its content on screen so the output is "KERNEL OK " will be seen on top left of screen which sill overlay over some other characters. You can clear the  screen by adding a function to clear the screen and calling it before printing the message but I am not doing that.

---

##  Next step:  Preparing for a C Kernel

AS writing kernel is very vast field.I want to set up the cross compilers to write kernel in c and with full features of 64 bit long mode.

Here are the steps I got from a youtube video whcih i still need to implment:

1. **Install a cross‑compiler** – to produce no header ,pure ELF objects.
2. **Rename the kernel.asm** – src/kernel.asm to kernel_entry.asm and contains the minimal _start that calls the C function.
3. **Create kernel.c** – Write the kernel logic in C.  The entry function must be declared as void kernel_main(void) and called from the kernel.asm
4. **Linker script (linker.ld)** – Forces the combined object(kernel.o and kernel_entry.o) to be placed at physical address 0x10000 so the bootloader's far jump lands on the correct code.
5. **Update Makefile** – Add rules to compile kernel.c with -ffreestanding -nostdlib -nostartfiles, assemble kernel_entry.asm with nasm -f elf64 , link everything with linker script and the linker using ld tool and finally concatenate with the bootloader.



 I hope you understand each piece of the transition chain: **real mode to protected mode to PAE to long mode to kernel**.
* After that,we can write a **real kernel in C**, using the bridge and linker script.


