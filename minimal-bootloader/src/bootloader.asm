; At bootloading time, the BIOS puts the CPU in 16-bit real mode for compatibility reasons.
bits 16 ; tells the assembler to emit 16-bit code

%define START_ADDR 0X7C00

%define BIOS_INT_VIDEO_SVC        0x10
%define BIOS_VIDEO_SVC_WRITE_CHAR 0x0E

%define ASCII_LF 0xA
%define ASCII_CF 0xD
%define EOL ASCII_CF,ASCII_LF

; Define all absolute addresses to be offsets from this
org START_ADDR

_start:
    ; Setup data segments
    xor ax, ax ; can't write to ds/es directly
    mov ds, ax
    mov es, ax

    ; Setup stack segment
    mov ss, ax
    mov sp, START_ADDR ; stack grows downwards from address bellow our program

    call set_video_mode

    ; Writes a string from `hello` label to the screen using 0x10 video interruption with 0xe write char function
    mov si, hello
    call cstr_print

    ; Halt the Program
    cli    ; Clear Interrup Flag
    hlt    ; `hlt` stops the CPU from executing (it can be resumed by an interrupt though).
    jmp $  ; In certain cases, the cpu can start running again... so we infinite-loop it just-in-case

; Sets the Video Mode
set_video_mode:
    xor ah, ah              ; Set Video Mode
    mov al, 0x03            ; 80x25 16 color text
    int BIOS_INT_VIDEO_SVC  ; Interruption Video Services
    ; This will also clear the screen
    ret

; Writes a (NUL-Terminated) C-String using BIOS Video Services Interruption.
; @param si Address of nul-terminated string to be printed
cstr_print:
.write_char:
    ; Interruption Arg 1: AL: The ascii character to be printed
    lodsb                ; Loads a byte from ds:si into al and increment si by 1
    cmp al, 0            ; If we load a NUL byte, then...
    je .write_char_done  ; ...stop printing chars.

    mov ah, BIOS_VIDEO_SVC_WRITE_CHAR ; Interruption Arg 2: Interrupt Vector: Video Services
    xor bh, bh                        ; Interruption Arg 3: Page Number (Text Mode)
    xor bl, bl                        ; Interruption Arg 4: Foreground Pixel Color (Graphics Mode)
    int BIOS_INT_VIDEO_SVC

    jmp .write_char
.write_char_done:
    ret

hello: db 'Hello, World!',EOL,0

; The program needs to be 512 bytes long and end with the byte sequence 0x55,0xAA.
; This will calculate how much zeros we need to fill as padding to reach the size of 512 bytes
; - `$$` refer to the start address of the currenct section
; - `$` refer to the address of the current instruction
; - `$-$$` gives us the length of this code
times 510-($-$$) db 0

; BIOS expects the last 2 bytes of the first sector to be this
db 0x55, 0xAA  ; or if you prefer (which I don't): dw 0xAA55
