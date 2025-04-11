; hex16x/src/kernel/filesystem/fs.asm

FS_TABLE_SECTOR    equ 0
FS_FILE_SECTORS    equ 1
MAX_FILES          equ 16
FILE_ENTRY_SIZE    equ 32
FILENAME_LEN       equ 16
SECTOR_SIZE        equ 512

file_table times MAX_FILES*FILE_ENTRY_SIZE db 0
current_dir db '/', 0

init_fs:
    pusha
    mov ax, 0x0201
    mov bx, file_table
    mov cx, FS_TABLE_SECTOR
    mov dx, 0x0080
    int 0x13
    jc .error
    popa
    ret
.error:
    mov si, fs_init_error
    call print_string
    popa
    ret
find_file:
    push bx
    push cx
    push di
    mov bx, file_table
    mov cx, MAX_FILES
.search_loop:
    push si
    push cx
    mov di, bx
    mov cx, FILENAME_LEN
    repe cmpsb
    pop cx
    pop si
    je .found
    add bx, FILE_ENTRY_SIZE
    loop .search_loop

    stc
    jmp .exit
.found:
    sub bx, file_table
    mov ax, bx
    mov bx, FILE_ENTRY_SIZE
    xor dx, dx
    div bx
    clc
.exit:
    pop di
    pop cx
    pop bx
    ret

read_file:
    pusha
    call find_file
    jc .error
    
    mov cx, FILE_ENTRY_SIZE
    mul cx
    mov di, file_table
    add di, ax
    
    mov ax, [di+16]
    mov cx, [di+18]
    
    push cx
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, byte [di+16]
    mov dh, 0
    mov dl, 0x80
    int 0x13
    pop cx
    jc .error
    
    clc
    jmp .exit
.error:
    mov si, file_read_error
    call print_string
    stc
.exit:
    popa
    ret

write_file:
    pusha
    cmp cx, SECTOR_SIZE
    ja .error

    mov di, file_table
    mov cx, MAX_FILES
.find_free:
    cmp byte [di], 0
    je .found_free
    add di, FILE_ENTRY_SIZE
    loop .find_free
    jmp .error
    
.found_free:
    push di
    mov cx, FILENAME_LEN
.copy_name:
    lodsb
    test al, al
    jz .name_copied
    stosb
    loop .copy_name
.name_copied:
    pop di
    
    call find_free_sector
    jc .error
    
    mov [di+16], ax
    mov [di+18], cx

    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, al
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc .error
    
    mov ax, 0x0301
    mov bx, file_table
    mov cx, FS_TABLE_SECTOR
    mov dx, 0x0080
    int 0x13
    jc .error
    
    clc
    jmp .exit
.error:
    mov si, file_write_error
    call print_string
    stc
.exit:
    popa
    ret

find_free_sector:
    push cx
    push di
    mov ax, FS_FILE_SECTORS
    mov cx, MAX_FILES
.check_sector:
    mov di, file_table
    push cx
    mov cx, MAX_FILES
.check_entries:
    cmp [di+16], ax
    je .next_sector
    add di, FILE_ENTRY_SIZE
    loop .check_entries
    clc
    jmp .exit
.next_sector:
    inc ax
    pop cx
    loop .check_sector
    stc
.exit:
    pop di
    pop cx
    ret

delete_file:
    pusha
    call find_file
    jc .error

    mov cx, FILE_ENTRY_SIZE
    mul cx
    mov di, file_table
    add di, ax
    
    mov cx, FILE_ENTRY_SIZE
    xor al, al
    rep stosb
    
    mov ax, 0x0301
    mov bx, file_table
    mov cx, FS_TABLE_SECTOR
    mov dx, 0x0080
    int 0x13
    jc .error
    
    clc
    jmp .exit
.error:
    mov si, file_delete_error
    call print_string
    stc
.exit:
    popa
    ret

list_files:
    pusha
    mov si, file_list_header
    call print_string
    
    mov cx, MAX_FILES
    mov di, file_table
.list_loop:
    cmp byte [di], 0
    je .next_file
    
    mov si, di
    call print_string

    mov si, file_size_prefix
    call print_string
    
    mov ax, [di+18]
    call print_hex_word
    
    call new_line
    
.next_file:
    add di, FILE_ENTRY_SIZE
    loop .list_loop
    
    popa
    ret

print_hex_word:
    pusha
    mov cx, 4
.print_digit:
    rol ax, 4 
    mov bx, ax
    and bx, 0x000F
    mov bl, [hex_chars + bx]
    mov ah, 0x0E
    int 0x10
    loop .print_digit
    popa
    ret

hex_chars db '0123456789ABCDEF'

fs_init_error      db "FS init error!", 0x0D, 0x0A, 0
file_read_error   db "File read error!", 0x0D, 0x0A, 0
file_write_error  db "File write error!", 0x0D, 0x0A, 0
file_delete_error db "File delete error!", 0x0D, 0x0A, 0
file_list_header  db "Files in root:", 0x0D, 0x0A, 0
file_size_prefix  db " - size: 0x", 0

file_data_buffer times 512 db 0