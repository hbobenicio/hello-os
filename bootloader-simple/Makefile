# `?=` operator only defines a variable if it's not already defined
# (can be defined by env vars, for example)
ASM    ?= nasm
DISASM ?= ndisasm

BUILDDIR      := build
BIN           := $(BUILDDIR)/bootloader.bin
LISTING       := $(BUILDDIR)/bootloader.lst
DISASSEMBLING := $(BUILDDIR)/bootloader.dis
SRCDIR        := src

all: $(BUILDDIR) $(BIN) $(DISASSEMBLING)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BIN): src/bootloader.asm $(BUILDDIR)
	$(ASM) -f bin -I $(SRCDIR) -l $(LISTING) -o $@ $<

.PHONY: run
run: $(BIN)
	qemu-system-i386 -drive file=$(BIN),format=raw,index=0,media=disk

.PHONY: debug
debug: $(BIN)
	qemu-system-i386 -s -S -drive file=$(BIN),format=raw,index=0,media=disk


# .PHONY: install
# install: $(BIN)
# 	dd if=bootsector.bin of=/dev/sda bs=512 count=1

$(DISASSEMBLING): $(BIN)
	$(DISASM) -b16 -o7C00h $(BIN) > $(DISASSEMBLING)

.PHONY: clean
clean:
	$(RM) -r $(BUILDDIR)
