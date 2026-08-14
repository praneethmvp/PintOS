bits 16
org 0x8000

start:
    xor ax, ax
    mov ds, ax

    mov si, message
    mov ah, 0x0E

print_loop:
    lodsb
    cmp al, 0
    je hang

    int 0x10
    jmp print_loop

hang:
    jmp hang

message:
    db 'Welcome to PINTOS', 0

times 512 - ($ - $$) db 0