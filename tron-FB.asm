Code	Segment
	assume CS:Code, DS:Data, SS:Stack

Start:
	mov	ax, Code
	mov	DS, AX
	
	;Clear
	mov ax, 03h
	int 10h
	
Menu:
	
	mov dx, offset MenuTxt
	mov ah, 09h
	int 21h
	
	;Line break
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	int 21h
	
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h
	
	mov dx, offset MenuStart
	mov ah, 09h
	int 21h
	
	;Line break
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	int 21h
	
	mov dx, offset MenuStartAdv
	mov ah, 09h
	int 21h
	
	;Line break
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	int 21h
	
	mov dx, offset MenuEnd
	mov ah, 09h
	int 21h
	
Menu_Input:
	;Wait
	xor ax, ax
	int 16h
	
	;ENTER?
	cmp al, 13
	jz Init
	
	;TAB?
	cmp al, 9
	jz InitAdv
	
	;ESC?
	cmp al, 27
	jz Jmp_Island111	;Program_End
	
	jmp Menu_Input
	
Init:
;Initialise
	;Starting coordinates
	mov ax, 100		;P1 X
	mov bx, 100		;P1 Y
	
	mov cx, 200		;P2 X
	mov dx, 100		;P2 Y
	
	push ax			;P1 X
	push bx			;P1 Y
	
	push cx			;P2 X
	push dx			;P2 Y
	
	;Starting direction (input)
	mov ax, "w"		;Up for P1
	push ax
	
	mov ax, 72		;Up for P2
	push ax
	
	;Default (0) previous 1D coordinate (for different line colour)
	mov ax, 0
	push ax			;P1
	push ax			;P2
	
	;Delta T Easy
	mov ax, 2
	push ax
	
	;Starting time (0)
	xor dx, dx
	push dx
	
	jmp Begin
	
InitAdv:
;Initialise
	;Starting coordinates
	mov ax, 100		;P1 X
	mov bx, 100		;P1 Y
	
	mov cx, 200		;P2 X
	mov dx, 100		;P2 Y
	
	push ax			;P1 X
	push bx			;P1 Y
	
	push cx			;P2 X
	push dx			;P2 Y
	
	;Starting direction (input)
	mov ax, "w"		;Up for P1
	push ax
	
	mov ax, 72		;Up for P2
	push ax
	
	;Default (0) previous 1D coordinate (for different line colour)
	mov ax, 0
	push ax			;P1
	push ax			;P2
	
	;Delta T Hard
	mov ax, 1
	push ax
	
	;Starting time (0)
	xor dx, dx
	push dx
	
Begin:
	
;Change to VGA
	mov ax, 13h
	int 10h
	
	;JUMP ISLAND -> Program_End
	jmp Jmp111_Skip
	Jmp_Island111:
	jmp Program_End
	Jmp111_Skip:

;Set display memory
	mov ax, 0a000h		;video adress start
	mov ES, ax			;Extra segment
	
;Border
mov cx, 319		;length of row
Border_Top:
	mov di, cx
	mov al, 10
	mov ES:[di], al
	loop Border_Top
	
mov cx, 319
Border_Bottom:
	mov ax, 199		;bottom row (Y)
	mov bx, 320
	mul bx
	add ax, cx		;1D coordinate calculation
	
	mov di, ax
	mov al, 10
	mov ES:[di], al
	loop Border_Bottom
	
mov cx, 199
Border_Left:
	mov ax, cx		;Y
	mov bx, 320
	mul bx
	
	mov di, ax
	mov al, 10
	mov ES:[di], al
	loop Border_Left
	
mov cx, 199
Border_Right:
	mov ax, cx		;Y
	mov bx, 320
	mul bx
	add ax, 319		;add X
	
	mov di, ax
	mov al, 10
	mov ES:[di], al
	loop Border_Right
	
	;JUMP ISLAND -> Program_End
	jmp Jmp1_Skip
	Jmp_Island1:
	jmp Program_End
	Jmp1_Skip:
	
;Border top left corner
	mov di, 0
	mov al, 10
	mov ES:[di], al

;Start of game loop
Game:

;Recolour previous position for P1
Prev_P1:
	mov bp, sp			;Set BasePointer to StackPointer (1st element in Stack)
	mov bx, [bp+6]		;Get previous 1D position
	cmp bx, 0
	jz Pixel_P1			;Do not recolor if it is the 1st frame
	
	mov di, bx			;1D coordinate
	mov al, 9			;line colour
	mov ES:[di], al		;pixel colour to video memory

;Calculate P1 pixel (1D coordinate) at Y * 320 + X
Pixel_P1:
	mov ax, [bp+16]		;P1 Y out
	mov cx, [bp+18]		;P1 X out
	mov bx, 320
	mul bx				;Y * 320 to AX
	add ax, cx			;AX + X
	
	mov bx, ax			;Save 1D coordinate
	
	mov [bp+6], bx		;Save coordinate for previous
	
;Detect Collision P1
;If the colour of the next coordinate is not black, then it is a collision
Collision_P1:
	mov di, bx			;1D coordinate
	mov al, 0			;Colour - black
	cmp ES:[di], al		;get pixel colour from video memory
	jnz Jmp_Island2 ;Lose_P1
	
;Draw P1 pixel
Draw_P1:
	mov di, bx			;1D coordinate
	mov al, 11			;pixel colour
	mov ES:[di], al		;pixel colour to video memory
	
;Recolour previous position for P1
Prev_P2:
	mov bp, sp			;Set BasePointer to StackPointer (1st element in Stack)
	mov bx, [bp+4]      ;Get previous 1D position
	cmp bx, 0
	jz Pixel_P2			;Do not recolor if it is the 1st frame
	
	mov di, bx			;1D coordinate
	mov al, 4			;line colour
	mov ES:[di], al		;pixel colour to video memory
	
;Calculate P1 pixel (1D coordinate) at Y * 320 + X
Pixel_P2:
	mov ax, [bp+12]		;P2 Y out
	mov cx, [bp+14]		;P2 X out
	mov bx, 320
	mul bx				;Y * 320 to AX
	add ax, cx			;AX + X
	
	mov bx, ax			;Save 1D coordinate
	
	mov [bp+4], bx		;Save coordinate for previous
	
;Detect Collision P2
Collision_P2:
	mov di, bx			;1D coordinate
	mov al, 0			;Colour - black
	cmp ES:[di], al		;get pixel colour from video memory
	jnz Jmp_Island3 ;Lose_P3
	
;Draw P2 pixel
Draw_P2:
	mov di, bx			;1D coordinate
	mov al, 42			;pixel colour
	mov ES:[di], al		;pixel colour to video memory
	
;Async input check
Input:
	xor ax, ax
	
	mov ah, 01h
	int 16h
	jz nokey ;Input_P2
	mov ah, 00h
	int 16h
	
	cmp al, "w"
	jz	Store_P1
	
	cmp al, "a"
	jz Store_P1
	
	cmp al, "s"
	jz Store_P1
	
	cmp al, "d"
	jz Store_P1
	
	cmp ah, 72
	jz	Store_P2
	
	cmp ah, 80
	jz Store_P2
	
	cmp ah, 75
	jz Store_P2
	
	cmp ah, 77
	jz Store_P2;
	
	cmp al, 27
	jz Jmp_Island11 ;Program_End
	
	jmp nokey

		;JUMP ISLAND -> Lose_P1
		jmp Jmp2_Skip
		Jmp_Island2:
		jmp Lose_P1
		Jmp2_Skip:
		
		;JUMP ISLAND -> Jmp_Island1 -> Program_End
		jmp Jmp11_Skip
		Jmp_Island11:
		jmp Program_End
		Jmp11_Skip:
		
		;JUMP ISLAND -> Lose_P2
		jmp Jmp3_Skip
		Jmp_Island3:
		jmp Lose_P2
		Jmp3_Skip:
		
;Store selected input for P1
Store_P1:
	xor ah, ah		;reset AH so AX with the input value can go on the Stack
	mov [bp+10], ax	;overwrite P1 direction with new value
	jmp Skip_Store_P2
	
;Store selected input for P2
Store_P2:
	mov al, ah
	xor ah, ah		;reset AH so AX with the input value can go on the Stack
	mov [bp+8], ax	;overwrite P2 direction with new value
Skip_Store_P2:
	
nokey:
;Get time
	xor ah, ah
	int 1ah		;get time in CX:DX
	
;Calculate time passed(T-passed)
	mov cx, [bp]	;get T-old from Stack
	mov ax, dx		;move T-current from DX to AX
	sub dx, cx		;T-passed = T-current - T-old into DX
	mov cx, ax		;copx AX to CX so I can save it later

	
;delta-T
	mov ax, [bp+2]
	
;Time passed?
Set:
	cmp dx, ax	;DX holds T-passed, AL is the delay (delta-T) as far as I understand
	
	;If time has not passed yet, go back to Input (delay)
	jc Input
	
	mov [bp], cx	;Save T-current to Stack (this will be T-old in the next iteration)
	
;Move Players
Check_P1:
	;P1 UP
	mov bx, [bp+10]
	cmp bx, "w"
	jz P1_Up
	
	;P1 DOWN
	mov bx, [bp+10]
	cmp bx, "s"
	jz P1_Down
	
	;P1 LEFT
	mov bx, [bp+10]
	cmp bx, "a"
	jz P1_Left
	
	;P1 RIGHT
	mov bx, [bp+10]
	cmp bx, "d"
	jz P1_Right
	
	;Decreasing P1 Y (move P1 up)
	P1_Up:
	mov ax, [bp+16]
	dec ax
	mov [bp+16], ax
	jmp Check_P2
	
	;Increasing P1 Y (move P1 down)
	P1_Down:
	mov ax, [bp+16]
	inc ax
	mov [bp+16], ax
	jmp Check_P2
	
	;Decreasing P1 X (move P1 left)
	P1_Left:
	mov ax, [bp+18]
	dec ax
	mov [bp+18], ax
	jmp Check_P2
	
	;Increasing P1 X (move P1 right)
	P1_Right:
	mov ax, [bp+18]
	inc ax
	mov [bp+18], ax
	jmp Check_P2
	
Check_P2:
	;P2 UP
	mov bx, [bp+8]
	cmp bx, 72
	jz P2_Up
	
	;P2 DOWN
	mov bx, [bp+8]
	cmp bx, 80
	jz P2_Down
	
	;P2 LEFT
	mov bx, [bp+8]
	cmp bx, 75
	jz P2_Left
	
	;P2 RIGHT
	mov bx, [bp+8]
	cmp bx, 77
	jz P2_Right
	
	;Decreasing P2 Y (move P2 up)
	P2_Up:
	mov ax, [bp+12]
	dec ax
	mov [bp+12], ax
	jmp Escape
	
	;Increasing P2 Y (move P2 down)
	P2_Down:
	mov ax, [bp+12]
	inc ax
	mov [bp+12], ax
	jmp Escape
	
	;Decreasing P2 X (move P2 left)
	P2_Left:
	mov ax, [bp+14]
	dec ax
	mov [bp+14], ax
	jmp Escape
	
	;Increasing P2 X (move P2 right)
	P2_Right:
	mov ax, [bp+14]
	inc ax
	mov [bp+14], ax
	jmp Escape
	
	Escape:
	mov bx, [bp+8]
	cmp bx, 27
	jz Program_End
	
	jmp Game

;End of game if P1 loses
Lose_P1:
	;Change to Console
	mov ax, 03h
	int 10h
	
	mov dx, offset P1lost
	mov ah, 09h
	int 21h
	
	;Line break
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	int 21h
	
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h
	
	jmp Menu
	
;End of game if P2 loses
Lose_P2:
	;Change to Console
	mov ax, 03h
	int 10h
	
	mov dx, offset P2lost
	mov ah, 09h
	int 21h
	
	;Line break
	mov dl, 10
	mov ah, 02h
	int 21h
	mov dl, 13
	int 21h
	
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h
	
	jmp Menu

Program_End:
	;Change to Console
	mov ax, 03h
	int 10h
	
	;Empty Stack
	pop ax  ;T
	pop ax  ;deltaT
	pop ax	;P2pre
	pop ax	;P1pre
	pop ax	;P2input
	pop ax	;P1input
	pop ax	;P2Y
	pop ax	;P2X
	pop ax	;P1Y
	pop ax	;P1X

	mov	ax, 4c00h
	int	21h
	
MenuTxt:
	db "TRON GAME - bczz3o$"
	
MenuStart:
	db "ENTER - Start new beginner game$"
	
MenuStartAdv:
	db "TAB   - Start new advanced game$"

MenuEnd:
	db "ESC   - Exit$"
	
P1lost:
	db "Player 2 (red) has won.$"
	
P2lost:
	db "Player 1 (blue) has won.$"

Code	Ends

Data	Segment

Data	Ends

Stack	Segment

Stack	Ends
	End	Start

