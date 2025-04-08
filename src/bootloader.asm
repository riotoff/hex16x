; hex16x/src/bootloader.asm

[BITS 16]
[ORG 0x7C00]

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00
mov ax, 0x0003
int 0x10

mov si, loading_msg
call print_string

mov ah, 0x02
mov al, 4
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, 0x00
mov bx, 0x1000
mov es, bx
xor bx, bx
int 0x13
jc disk_error
mov si, loaded_msg
call print_string

jmp 0x1000:0000

disk_error:
    mov si, error_msg
    call print_string
    mov al, ah
    call print_hex
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

print_hex:
    push ax
    shr al, 4
    call .nibble_to_hex
    mov ah, 0x0E
    int 0x10
    pop ax
    and al, 0x0F
    call .nibble_to_hex
    mov ah, 0x0E
    int 0x10
    ret
.nibble_to_hex:
    add al, '0'
    cmp al, '9'
    jbe .done
    add al, 7
.done:
    ret

loading_msg db "Loading hex16x kernel...", 0x0D, 0x0A, 0
loaded_msg db "Kernel loaded, jumping...", 0x0D, 0x0A, 0
error_msg db "Disk error! Code: ", 0

times 510-($-$$) db 0
dw 0xAA55
