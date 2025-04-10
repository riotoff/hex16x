; hex16x/src/cmds/clear.asm

clear_cmd db "clear", 0

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