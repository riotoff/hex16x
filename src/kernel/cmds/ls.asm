; hex16x/src/kernel/cmds/ls.asm

ls_cmd       db "ls", 0

do_ls:
    pusha
    call list_files
    popa
    ret