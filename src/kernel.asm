; hex16x/src/kernel.asm

[BITS 16]
[ORG 0x0000]

start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE

    call clear_screen
    mov si, welcome_msg
    call print_string

    mov si, welcome_msg2
    call print_string

main_loop:
    mov si, prompt
    call print_string
    
    mov di, input_buffer
    mov cx, 64
    xor al, al
    rep stosb
    
    mov di, input_buffer
    call read_line
    call process_command
    jmp main_loop


clear_screen:
    pusha
    mov ax, 0x0600
    mov bh, 0x07
    xor cx, cx
    mov dx, 0x184F
    int 0x10
    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 0x10
    popa
    ret

print_string:
    pusha
.print_loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print_loop
.done:
    popa
    ret

read_line:
    pusha
    mov di, input_buffer
    xor cx, cx
.input_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x0D
    je .enter_pressed
    cmp al, 0x08
    je .backspace_pressed
    
    cmp al, ' '
    jb .input_loop
    cmp al, '~'
    ja .input_loop
    cmp cx, 63
    jae .input_loop
    
    mov [di], al
    inc di
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .input_loop

.backspace_pressed:
    test cx, cx
    jz .input_loop
    dec di
    dec cx
    mov byte [di], 0
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .input_loop

.enter_pressed:
    mov byte [di], 0
    call new_line
    popa
    ret

new_line:
    push ax
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    pop ax
    ret

power_off:
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x0102
    int 0x15
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    
    mov ax, 0x2000
    mov ds, ax
    mov word [0x604], 0x2000
    
    cli
    hlt

show_help:
    pusha
    mov si, help_msg
    call print_string
    mov si, help_clear
    call print_string
    mov si, help_exit
    call print_string
    mov si, help_help
    call print_string
    popa
    ret

process_command:
    pusha
    mov si, input_buffer
    
    cmp byte [si], 0
    je .empty
    
    mov di, clear_cmd
    call strcmp
    jc .do_clear
    
    mov di, exit_cmd
    call strcmp
    jc .do_exit
    
    mov di, help_cmd
    call strcmp
    jc .do_help
    
    mov si, unknown_cmd
    call print_string
    jmp .done
    
.empty:
    jmp .done
.do_clear:
    call clear_screen
    jmp .done
.do_exit:
    mov si, shutdown_msg
    call print_string
    call power_off
.do_help:
    call show_help
.done:
    popa
    ret

strcmp:
    pusha
.compare:
    mov al, [si]
    cmp al, [di]
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .compare
.not_equal:
    clc
    jmp .exit
.equal:
    stc
.exit:
    popa
    ret

welcome_msg db "Hex16x OS v0.1", 0x0D, 0x0A, 0
welcome_msg2 db "Type 'help' for available commands", 0x0D, 0x0A, 0x0A, 0
prompt db "$ ", 0
clear_cmd db "clear", 0
exit_cmd db "exit", 0
help_cmd db "help", 0
unknown_cmd db "Unknown command", 0x0D, 0x0A, 0
shutdown_msg db "Shutting down...", 0x0D, 0x0A, 0

help_msg db "Available commands:", 0x0D, 0x0A, 0
help_clear db "  clear - Clear the screen", 0x0D, 0x0A, 0
help_exit db "  exit  - Shutdown the computer", 0x0D, 0x0A, 0
help_help db "  help  - Show this help message", 0x0D, 0x0A, 0

input_buffer times 64 db 0
