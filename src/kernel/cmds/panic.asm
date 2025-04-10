; hex16x/src/cmds/panic.asm

panic_cmd db "panic", 0
panic_msg db 0x0D, 0x0A, "KERNEL PANIC! System will shutdown in 3 seconds...", 0x0D, 0x0A, 0

kernel_panic:
    pusha
    mov si, panic_msg
    call print_string
    call delay_3s
    call do_exit
    popa
    ret

delay_3s:
    pusha
    mov cx, 0x2D
    mov dx, 0xFFFF
    mov ah, 0x86
    int 0x15
    popa
    ret