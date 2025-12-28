; Stage-0 Boot Loader
;
; ## Steps
;
; - [X] Disable Interrupts
; - [ ] Canonize CS:EIP
; - [ ] Load Segment Registers
; - [X] Set Stack Pointer
; - [ ] Enable Interrupts
; - [ ] Reset Floppy Disk Controller
; - [ ] Read Stage-1 Bootloader sectors from Floppy to Memory
; - [ ] Jump to Stage-1 Bootloader

; At bootloading time, the BIOS puts the CPU in 16-bit real mode for compatibility reasons.
bits 16 ; tells the assembler to emit 16-bit code

%include "ascii.inc.asm"

%define START_ADDR 0x7C00

%define BIOS_INT_VIDEO_SVC        0x10
%define BIOS_VIDEO_SVC_WRITE_CHAR 0x0E

%define EOL ASCII_CF,ASCII_LF

; Define all absolute addresses to be offsets from this
org START_ADDR

; Entrypoint
_start:
    cli              ; Clear (Disable) Interrupt Flag
    jmp 0:.beginning ; Canonicalize CS:EIP
.beginning:
    ; Setting Segment Registers to predictable values
    xor ax, ax  ; we can't write to ds/es directly
    mov ds, ax  ; Data Segment
    mov es, ax  ; Extra Segment
    mov fs, ax  ; General Purpose Segment
    mov gs, ax  ; General Purpose Segment
    mov ss, ax  ; Stack Segment

    ; Define the stack to grow down from the starting address
    mov sp, START_ADDR

    ;  Set (Enable) Interrupt Flag
    sti

    mov al, 0x03
    call videosvc_set_video_mode

    mov si, title
    call cstr_print

    ; Writes a string from `hello` label to the screen using 0x10 video interruption with 0xe write char function
    mov si, hello
    call cstr_print

    ;mov al, 0x13
    ;call videosvc_set_video_mode
    ;call test_plot_pixel

    ; Halt the Program
    cli    ; Clear Interrup Flag
    hlt    ; `hlt` stops the CPU from executing (it can be resumed by an interrupt though).
    jmp $  ; In certain cases, the cpu can start running again... so we infinite-loop it just-in-case

; @description Sets the Video Mode
; @param AL The Video Mode to be set
;        0x03: 80x25    16-bit Color Text Mode
;        0x13: 320x200 (256-bit?) Color Graphics Mode
videosvc_set_video_mode:
    ; calls Video Services BIOS Interruption (int 0x10)
    ; (This will also clear the screen)
    xor ah, ah              ; Video Services Param: AH==0x00: Set Video Mode Operation
    ;al                     ; Video Services Param: AL (argument): Video Mode
    int BIOS_INT_VIDEO_SVC  ; calls the Video Services interruption
    ret

test_plot_pixel:
    ; Test: ploting a pixel
    mov ah, 0x0C ; pixel
    mov al, 0xA  ; color
    mov cx, 0x10 ; coord x
    mov dx, 0x10 ; coord y
    int BIOS_INT_VIDEO_SVC
    ret

; @description Writes a (NUL-Terminated) C-String using BIOS Video Services Interruption.
; @param si Address of nul-terminated string to be printed
cstr_print:
.write_char:
    ; Interruption Arg 1: AL: The ascii character to be printed
    lodsb                ; Loads a byte from ds:si into al and increment si by 1
    cmp al, 0            ; If we load a NUL byte, then...
    je .write_char_done  ; ...stop printing chars.

    ;TODO check AH = 0x13 (Display String)
    mov ah, BIOS_VIDEO_SVC_WRITE_CHAR ; Interruption Arg 2: Interrupt Vector: Video Services
    xor bh, bh                        ; Interruption Arg 3: Page Number (Text Mode)
    xor bl, bl                        ; Interruption Arg 4: Foreground Pixel Color (Graphics Mode)
    int BIOS_INT_VIDEO_SVC

    jmp .write_char
.write_char_done:
    ret

title: db '=== HBMO OS :: Bootloader :: Stage 0', EOL, EOL, 0
hello: db 'Loading the Kernel... Please Wait.', EOL, 0

; The program needs to be 512 bytes long and end with the byte sequence 0x55,0xAA.
; This will calculate how much zeros we need to fill as padding to reach the size of 512 bytes
; - `$$` refer to the start address of the currenct section
; - `$` refer to the address of the current instruction
; - `$-$$` gives us the length of this code
times 510-($-$$) db 0

; BIOS expects the last 2 bytes of the first sector to be this
db 0x55, 0xAA  ; or if you prefer (which I don't): dw 0xAA55
; db 0xCA, 0xFE,

