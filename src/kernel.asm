; kernel.asm — minimal 32-bit kernel
; Loaded by bootloader at physical address 0x10000
; Entry point is the very first byte (no ELF header, raw binary)

bits 32
org 0x10000             ; we are physically at 0x10000 in RAM

KERNEL_ENTRY:
    ; Segment registers are already set by the bootloader
    ; Stack is already set up at 0x9C00 by the bootloader

    ; ------------------------------------------------------------------
    ; Print "KERNEL OK" to VGA text buffer at 0xB8000
    ; VGA text format: [character byte][attribute byte]
    ; Attribute 0x0A = bright green on black
    ; ------------------------------------------------------------------
    mov esi, msg            ; ESI = pointer to our string
    mov edi, 0x000B8000     ; EDI = VGA text buffer address
    mov ah, 0x0A            ; attribute: bright green on black

.print_loop:
    mov al, [esi]           ; load next character
    cmp al, 0               ; is it null terminator?
    je .done                ; yes → stop
    mov [edi], ax           ; write char + attribute to VGA (AH=attr, AL=char)
    add esi, 1              ; advance string pointer
    add edi, 2              ; advance VGA pointer (2 bytes per character: char + attr)
    jmp .print_loop

.done:
    cli
    hlt                     ; halt CPU — kernel is done

; ------------------------------------------------------------------
msg: db "KERNEL OK", 0      ; null-terminated string
