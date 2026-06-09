bits 16
ORG 0x7C00

start:
 mov ax,0x00
 mov ds,ax
 mov ss,ax
 mov es,ax
 mov sp,0x7C00


mov si,msg

print:
   lodsb 
   cmp al,0
   je end
   mov ah,0x0E
   int 0x10
   jmp print

 msg:
db 'MY NAME IS NIRAJ LAMSAL',0

   end:
   cli
   hlt

times 510-($-$$) db 0
dw 0xAA55

   


