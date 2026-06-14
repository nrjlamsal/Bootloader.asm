bits 16
ORG 0x7C00

code_segment equ 0x08    ; code descriptor selector
data_segment equ 0x10    ; data descriptor selector

KERNEL_LOAD_SEG equ 0x1000   ; ES segment where kernel is loaded  (physical 0x10000)
KERNEL_SECTORS  equ 1        ; number of sectors to read (1 = 512 bytes)


start:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    
    ; Save boot drive number from dl register
    mov [boot_drive], dl

; DISK READ: load kernel sectors from disk into memory at 0x10000 
load_kernel:
    mov ax, KERNEL_LOAD_SEG   ; destination segment
    mov es, ax                ; ES = 0x1000
    mov bx, 0x0000            ; BX = 0x0000  →  ES:BX = 0x1000:0x0000 = physical 0x10000

    mov ah, 0x02              ; INT 13h function: Read Sectors
    mov al, KERNEL_SECTORS    ; number of sectors to read
    mov ch, 0                 ; cylinder 0
    mov cl, 2                 ; sector 2 (boot sector is sector 1, kernel starts at 2)
    mov dh, 0                 ; head 0
    mov dl, [boot_drive]      ; drive number saved from BIOS
    int 0x13                  ; call BIOS disk service

    jc disk_error             ; CF=1 means error occurred

    ; Restore ES to 0 after disk read
    mov ax, 0x00
    mov es, ax

    jmp load_gdt              ; disk read OK, proceed to Protected Mode

disk_error:
    ; Print 'E' to screen to signal disk error, then halt
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    hlt

load_gdt:
   cli
   lgdt [gdt_pointer]
   mov eax, cr0 
   or eax, 0x1 ; enable PM(bit 0 of cr0 register)
   mov cr0, eax
   jmp code_segment:protected_mode 

; Data
boot_drive: db 0             ; storage for BIOS boot drive number

 gdt_start:
  ;Null descriptor
    dd 0x00000000, 0x00000000

    ; Code segment
 gdt_code:
    dw 0xffff    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10011010b ; Access byte (Present, Ring 0, Code, Executable, Readable)
    db 11001111b ; Flags (4KB granularity, 32-bit PM) + Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)

    ; Data Segment
    gdt_data:
    dw 0xFFFF    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10010010b ; Access byte (Present, Ring 0, Data, Writable)
    db 11001111b ; Flags (4KB granularity, 32-bit PM) + Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)

gdt_end:

; GDT pointer
gdt_pointer:
    dw gdt_end - gdt_start - 1  ; Size of GDT (limit) - 16 bit
    dd gdt_start                 ; Address of GDT - 32 bit

  bits 32

   protected_mode:
    mov ax, data_segment
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp

    in al, 0x92          ; enable A20 gate via port 0x92 to address upper 1mb of memory
    or al, 2
    out 0x92, al


    jmp code_segment:0x10000

times 510-($-$$) db 0 
dw 0xaa55