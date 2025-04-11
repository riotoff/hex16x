; hex16x/src/kernel/cmds/cat.asm

cat_cmd      db "cat", 0

cat_file:
    pusha
    mov si, input_buffer
    add si, 4
    
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    
    cmp byte [si], 0
    je .no_filename
    
    mov bx, file_data_buffer
    call read_file
    jc .read_error
    
    mov si, bx
    call print_string
    call new_line
    jmp .done
    
.no_filename:
    mov si, cat_usage
    call print_string
    jmp .done
    
.read_error:
    mov si, cat_error
    call print_string
    
.done:
    popa
    ret

cat_usage db "Usage: cat <filename>", 0x0D, 0x0A, 0
cat_error db "Error reading file", 0x0D, 0x0A, 0