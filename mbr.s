;主啟動程式
;----------
;初始化區段暫存器
SECTION MBR vstart=0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00

;清除螢幕
;-----------
    mov ax,0x600
    mov bx,0x0700
    mov cx,0        ;左上角(0,0)
    mov dx,0x184f   ;左下角(80,25)
    int 0x10

;取得游標位置
;-----------
    mov ah,3
    mov bh,0
    int 0x10

;列印字串
;-----------
    mov ax,message
    mov bp,ax       ;es=cs

    mov cx,5
    mov ax,0x1301   ;使用BIOS 10號中斷 AH=13子功能:AL=01:顯示字元
    
    mov bx,0x2

    int 0x10

;

    jmp $           ;程式停留在此

    
    message db "1 MBR"
    times 510-($-$$) db 0
    db 0x55,0xaa



