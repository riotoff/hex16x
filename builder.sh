nasm -f bin src/bootloader.asm -o build/bootloader.bin
nasm -f bin src/kernel.asm -o build/kernel.bin
dd if=/dev/zero of=build/hex16x.img bs=512 count=2880
dd if=build/bootloader.bin of=build/hex16x.img conv=notrunc
dd if=build/kernel.bin of=build/hex16x.img bs=512 seek=1 conv=notrunc
qemu-system-x86_64 -drive file=build/hex16x.img,format=raw,if=floppy
