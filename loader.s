%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

GDT_BASE: dd   0x00000000
          dd   0x00000000

CODE_DESC: dd  0x0000FFFF
           dd  DESC_CODE_HIGH4

DATA_STACK_DESC: dd  0x0000FFFF
                 dd  DESC_DATA_HIGH4

VIDEO_DESC: dd  0x80000007  ; limit=(0xbffff-0xb8000) / 4k=0x7
            dd  DESC_VIDEO_HIGH4 ; 此時DPL為0

GDT_SIZE   equ  $ - GDT_BASE
GDT_LIMIT  equ  GDT_SIZE - 1
times 60 dq 0 ;留60個描述符號的位置

SELECTOR_CODE  equ  (0x0001<<3) + TI_GDT + RPL0
SELECTOR_DATA  equ  (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO equ  (0x0003<<3) + TI_GDT + RPL0

;gdt指標
gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

loadermsg db '2 loader in real'

loader_start:

;直接寫入字元到螢幕緩衝區
; "2 LOADER"
;------------------------
	mov byte [gs:0x00],'2'
	mov byte [gs:0x01],0xA4

	mov byte [gs:0x02],' '
	mov byte [gs:0x03],0xA4

	mov byte [gs:0x04],'L'
	mov byte [gs:0x05],0xA4

	mov byte [gs:0x06],'O'
	mov byte [gs:0x07],0xA4

	mov byte [gs:0x08],'A'
	mov byte [gs:0x09],0xA4

	mov byte [gs:0x0a],'D'
	mov byte [gs:0x0b],0xA4

	mov byte [gs:0x0c],'E'
	mov byte [gs:0x0d],0xA4

	mov byte [gs:0x0e],'R'
	mov byte [gs:0x0f],0xA4
	
jmp $
