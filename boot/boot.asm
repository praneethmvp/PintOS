bits 16
org 0x7C00

start:
    ; initializing Stack
    cli ; clears the interrupt flags
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl ; here we are loading the boot_drive with bios boot_drive value
    sti ; turns on external interrupt flags

    mov dl, [boot_drive]
    xor ax,ax
    mov es,ax
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov bx, 0x8000
    int 0x13
    jc disk_error
    jmp 0x0000:0x8000

    ; printing out message
    xor ax,ax
    mov ds,ax
    mov si, message
    ; write character on screen with teletype
    mov ah, 0x0E

print_loop:
    ; loads DS:SI address into memory
    lodsb
    cmp al, 0
    je hang
    ; video interrupt to print
    int 0x10
    jmp print_loop

hang:
    jmp hang

disk_error:
    mov si, error_msg
    mov ah,0x0E
    

error_print_loop:
    lodsb
    cmp al, 0
    je hang

    int 0x10
    jmp error_print_loop

message:
    db 'Welcome to PINTOS', 0

boot_drive:
    db 0
error_msg:
    db 'Something wrong with the DISK', 0
times 510 - ($ - $$) db 0
dw 0xAA55