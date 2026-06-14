

bits 32
org 0x10000             ; we are physically at 0x10000 in RAM

KERNEL_ENTRY:
    ; Segment registers are already set by the bootloader
    ; Stack is already set up at 0x9C00 by the bootloader


    mov esi, msg           
    mov edi, 0x000B8000     
    mov ah, 0x0A         

.print_loop:
    mov al, [esi]           ; load next character
    cmp al, 0               ; is it null terminator?
    je .done               
    mov [edi], ax          
    add esi, 1            
    add edi, 2              
    jmp .print_loop

.done:
    cli
    hlt                     ; halt CPU

msg: db "KERNEL OK", 0      ; null-terminated string
