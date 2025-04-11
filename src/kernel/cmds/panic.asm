; hex16x/src/cmds/panic.asm

panic_cmd db "panic", 0
panic_msg db 0x0D, 0x0A, "Kernel Panic!", 0x0D, 0x0A, 0

kernel_panic:
    pusha
    call clear_screen
    mov si, panic_msg
    call print_string
    cli
    hlt
    popa
    ret