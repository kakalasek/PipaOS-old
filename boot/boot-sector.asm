;
; BOOT SECTOR
;
[org 0x7c00] ; Tells the assembler where this code will be loaded
KERNEL_OFFSET equ 0x1000    ; This is the memory offset to which we will load our kernel

mov [BOOT_DRIVE], dl    ; BIOS stores our boot drive in DL, so is's
                        ; best to remember this for later

mov bp, 0x9000 ; Set-up the stack
mov sp, bp

mov bx, REAL_MSG
call print_string

call load_kernel ; Load our kernel

call switch_to_pm ; Note the we never return from here

jmp $ ; Hang

; Includes
%include 'utils/print_string.asm'
%include 'utils/print_string_pm.asm'
%include 'utils/print_hex.asm'
%include 'utils/disk_load.asm'
%include 'utils/gdt.asm'
%include 'utils/switch_to_pm.asm'

[bits 16]
load_kernel:

    mov bx, KERNEL_OFFSET ; Set-up parameters for our disk_load routine, so
    mov dh, 9             ; that we load the first 16 sectors (excluding
    mov dl, [BOOT_DRIVE]  ; the boot sector) from the boot disk (i. e. our
    call disk_load        ; kernel code) to adress KERNEL_OFFSET

    ret

; This is where we arrive after switching to and initialising protected mode
[bits 32]
BEGIN_PM:
    mov ebx, PROTECTED_MSG
    call print_string_pm

    call KERNEL_OFFSET

    jmp $

; Global variables
REAL_MSG db 'Booting to 16 bit real mode', 0
PROTECTED_MSG db 'Booting to 32 bit protected mode', 0
BOOT_DRIVE db 0

; Padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55