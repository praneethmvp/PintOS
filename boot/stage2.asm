bits 16
org 0x8000

; ============================================================
; STAGE 2 ENTRY
; ============================================================

start:
    call enable_a20
    call test_a20
    call load_gdt

    ; TODO: enter protected mode


hang:
    jmp hang


; ============================================================
; A20
; ============================================================

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

    ; Check that address 0x00000 still contains 0x11
    xor ax, ax
    mov es, ax
    xor di, di
    cmp byte [es:di], 0x11

    je a20_working
    jmp a20_failed


; ============================================================
; GDT
; ============================================================

gdt_start:

    ; Entry 0: NULL
    dq 0

    ; Entry 1: CODE
    db 0xFF, 0xFF
    db 0x00, 0x00, 0x00
    db 0x9A
    db 0xCF
    db 0x00

    ; Entry 2: DATA
    db 0xFF, 0xFF
    db 0x00, 0x00, 0x00
    db 0x92
    db 0xCF
    db 0x00

gdt_end:


; ============================================================
; GDTR
; ============================================================

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


load_gdt:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp dword 0x08:protected_mode

; ============================================================
; MESSAGES
; ============================================================
a20_failed:
    mov si, a20_error
    call print_string  
    jmp hang
a20_error:
    db 'A20 is failing', 0x0D, 0x0A, 0
a20_working:
    mov si, a20_message
    call print_string
    ret

a20_message:
    db 'A20 is working', 0x0D, 0x0A, 0


; ============================================================
; BIOS PRINT
; ============================================================

print_string:
    mov ah, 0x0E

.print_loop:
    lodsb
    cmp al, 0
    je .done

    int 0x10
    jmp .print_loop

.done:
    ret


; ============================================================
; PROTECTED MODE
; ============================================================

bits 32

protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esp, 0x90000

    mov esi, message32
    call print_string32

    jmp $


print_string32:
    mov edi, 0xB8000

.print_loop:
    lodsb

    cmp al, 0
    je .done

    mov [edi], al
    mov byte [edi + 1], 0x0A

    add edi, 2

    jmp .print_loop

.done:
    ret


message32:
    db 'Protected Mode!', 0

; ============================================================
; END
; ============================================================
