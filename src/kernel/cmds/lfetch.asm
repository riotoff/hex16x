; hex16x/src/cmds/lfetch.asm

lfetch_cmd db "lfetch", 0

lfetch_title db "               lfetch", 0x0D, 0x0A, 0
lfetch_separator db "               -------", 0x0D, 0x0A, 0
lfetch_host db "               Host: HexPC", 0x0D, 0x0A, 0
lfetch_os db "               OS: Hex16x", 0x0D, 0x0A, 0
lfetch_cpuu db "               CPU: HexCore", 0x0D, 0x0A, 0
lfetch_memory db "               Memory: ?/? MB", 0x0D, 0x0A, 0

lfetch:
    pusha
    mov si, lfetch_title
    call print_string
    mov si, lfetch_separator
    call print_string
    mov si, lfetch_host
    call print_string
    mov si, lfetch_os
    call print_string
    mov si, lfetch_cpuu
    call print_string
    mov si, lfetch_memory
    call print_string
    popa
    ret