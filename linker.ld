ENTRY(start)
SECTIONS
{
    . = 0x7C00;
    .bootloader : {
        *(.bootloader)
    }

    . = 0x1000;
    .kernel : {
        *(.kernel)
    }
}