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

    mov si, available_cmds
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

process_command:
    pusha
    mov si, input_buffer
    
    cmp byte [si], 0
    je .done
    
    mov di, clear_cmd
    call strcmp
    jc .do_clear
    
    mov di, exit_cmd
    call strcmp
    jc .do_exit
    
    mov di, help_cmd
    call strcmp
    jc .do_help
    
    mov di, lfetch_cmd
    call strcmp
    jc .do_lfetch
    
    mov di, panic_cmd
    call strcmp
    jc .do_panic

    mov si, unknown_cmd
    call print_string
    mov si, available_cmds2
    call print_string
    jmp .done
    
.do_clear:
    call clear_screen
    jmp .done
.do_exit:
    call do_exit
    jmp .done
.do_help:
    call show_help
    jmp .done
.do_lfetch:
    call lfetch
    jmp .done
.do_panic:
    call kernel_panic
.done:
    popa
    ret

%include "src/kernel/cmds/clear.asm"
%include "src/kernel/cmds/exit.asm"
%include "src/kernel/cmds/help.asm"
%include "src/kernel/cmds/lfetch.asm"
%include "src/kernel/cmds/panic.asm"

welcome_msg db "Hex16x OS v0.2", 0x0D, 0x0A, 0
available_cmds db "Type 'help' for available commands", 0x0D, 0x0A, 0x0A, 0
available_cmds2 db "Type 'help' for available commands", 0x0D, 0x0A, 0
prompt db "$ ", 0
unknown_cmd db "Unknown command...", 0x0D, 0x0A, 0
input_buffer times 64 db 0