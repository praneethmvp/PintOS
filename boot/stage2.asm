bits 16
org 0x8000

start:
    call enable_a20
    call test_a20
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

enable_a20:
    mov ax, 0x2401
    int 0x15
    jc a20_failed
    ret

test_a20:
    ; Write 0x11 to physical address 0x00000
    xor ax, ax
    mov es, ax
    xor di, di
    mov byte [es:di], 0x11
    ; Write 0x22 to physical address 0x100000
    mov ax, 0xFFFF
    mov es, ax
    mov di, 0x0010
    mov byte [es:di], 0x22
    ; Read physical address 0x00000
    xor ax, ax
    mov es, ax
    xor di, di
    cmp byte [es:di], 0x11
    je working
    ret
working:
    mov si, worked
    mov ah, 0x0E
working_print:
    lodsb
    cmp al,0
    je hang
    int 0x10
    jmp working_print

a20_failed:
    mov si, a20_error
    mov ah, 0x0E

a20_error_print:
    lodsb
    cmp al,0
    je hang
    int 0x10
    jmp a20_error_print

hang:
    jmp hang

message:
    db 'Welcome to PINTOS', 0

a20_error:  
    db 'A20 is failing', 0
worked:
    db 'A20 is working', 0

times 512 - ($ - $$) db 0