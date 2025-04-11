nasm -f bin src/bootloader/bootloader.asm -o build/bootloader.bin
nasm -f bin src/kernel/main.asm -o build/kernel.bin
dd if=/dev/zero of=build/hex16x.img bs=512 count=2880
dd if=build/bootloader.bin of=build/hex16x.img conv=notrunc
dd if=build/kernel.bin of=build/hex16x.img bs=512 seek=1 conv=notrunc
