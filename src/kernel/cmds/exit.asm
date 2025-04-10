; hex16x/src/cmds/exit.asm

exit_cmd db "exit", 0
shutdown_msg db "Shutting down...", 0x0D, 0x0A, 0

do_exit:
    mov si, shutdown_msg
    call print_string
    
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