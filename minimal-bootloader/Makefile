all: os.bin

os.bin: os.asm
	nasm -f bin -o os.bin os.asm

.PHONY: run
run: os.bin
	qemu-system-i386 -drive file=os.bin,format=raw,index=0,media=disk

.PHONY: clean
clean:
	$(RM) os.bin

