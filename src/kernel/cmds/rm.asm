; hex16x/src/kernel/cmds/rm.asm

rm_cmd       db "rm", 0

delete_file_cmd:
    pusha
    mov si, input_buffer
    add si, 3
    
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    
    cmp byte [si], 0
    je .no_filename
    
    call delete_file
    jc .delete_error
    
    mov si, file_deleted_msg
    call print_string
    jmp .done
    
.no_filename:
    mov si, rm_usage
    call print_string
    jmp .done
    
.delete_error:
    mov si, rm_error
    call print_string
    
.done:
    popa
    ret

rm_usage db "Usage: rm <filename>", 0x0D, 0x0A, 0
rm_error db "Error deleting file", 0x0D, 0x0A, 0
file_deleted_msg db "File deleted", 0x0D, 0x0A, 0