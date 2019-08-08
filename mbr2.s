;主啟動程式
;----------
%include "boot.inc"
SECTION MBR vstart=0x7c00
;初始化區段暫存器
;----------------
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
	mov ax,0xb800
	mov gs, ax
	
;清除螢幕
;--------
    mov ax,0x600
    mov bx,0x0700
    mov cx,0        ;左上角(0,0)
    mov dx,0x184f   ;左下角(79,24)
    int 0x10

;直接寫入字元到螢幕緩衝區
;------------------------
	mov byte [gs:0x00],'1'
	mov byte [gs:0x01],0xA4

	mov byte [gs:0x02],' '
	mov byte [gs:0x03],0xA4

	mov byte [gs:0x04],'M'
	mov byte [gs:0x05],0xA4

	mov byte [gs:0x06],'B'
	mov byte [gs:0x07],0xA4

	mov byte [gs:0x08],'R'
	mov byte [gs:0x09],0xA4
	
;讀取啟動磁區
	mov eax,LOADER_START_SECTOR ;啟動磁區位址LBA
	mov bx,LOADER_BASE_ADDR		;寫入記憶體位址
	mov cx,4
	call rd_disk_m_16
	jmp LOADER_BASE_ADDR			;執行啟動程式

;讀取硬磁n個磁區
;eax = LBA位址
;bx  = 寫入記憶體位址
;cx  = 讀取的磁區數
;---------------
rd_disk_m_16:
	mov esi,eax ;備份eax
	mov di,cx	;備份cx
	
;1.設定讀取的磁區數	
	mov dx,0x1f2 ;寫入primary通道sector count暫存器
	mov al,cl
	out dx,al
	
	mov eax,esi ;還原eax
	
;2.將LBA存到0x1f3~0x1f6	
	mov dx,0x1f3;寫入LBA暫存器1f3 : 7~0
	out dx,al
	
	mov cl,8	;寫入LBA暫存器1f4 : 15~8
	shr eax,cl
	mov dx,0x1f4
	out dx,al
	
	shr eax,cl  ;寫入LBA暫存器1f5 : 16~23
	mov dx,0x1f5
	out dx,al
	
	shr eax,cl  ;寫入misc 1f6     : 24~27
	and al,0x0f
	#or al,0xe0  ;設定7~4位元1110,表示LBA模式
	mov dx,0x1f6
	out dx,al

;3.將0x1f7設為0x20, 表示為讀取動作
	mov dx,0x1f7
	mov al,0x20
	out dx,al

;4.檢測硬碟狀態 : 讀取0x1f7
.not_ready:
	nop
	in al,dx
	and al,0x88 ;bit 3 = 1表示硬磁已準備好資料傳輸, bit 7 = 1表示硬碟忙碌中
	cmp al,0x08 
	jnz .not_ready
	
;5.從0x1f0讀取資料 : di=要讀取的磁區數, 一個磁區512bytes, 一次一個word, 所以需要256次
	mov ax,di
	mov dx,256
	mul dx
	mov cx,ax
	mov dx,0x1f0

.go_on_ready:
	in ax,dx
	mov [bx],ax
	add bx,2
	loop .go_on_ready
	ret
	
    times 510-($-$$) db 0
    db 0x55,0xaa



