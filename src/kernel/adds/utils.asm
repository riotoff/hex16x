; hex16x/src/kernel/utils.asm

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
    
    cmp al, 'A'
    jb .not_upper
    cmp al, 'Z'
    ja .not_upper
    add al, 0x20
.not_upper:
    
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