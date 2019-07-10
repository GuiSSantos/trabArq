.equ SWI_SETSEG8, 0x200 @display on 8 Segment
.equ SWI_SETLED, 0x201 @LEDs on/off
.equ SWI_CheckBlack, 0x202 @check Black button
.equ SWI_CheckBlue, 0x203 @check press Blue button
.equ SWI_DRAW_STRING, 0x204 @display a string on LCD  R2
.equ SWI_DRAW_INT, 0x205 @display an int on LCD  R2
.equ SWI_CLEAR_DISPLAY,0x206 @clear LCD
.equ SWI_DRAW_CHAR, 0x207 @display a char on LCD
.equ SWI_CLEAR_LINE, 0x208 @clear a line on LCD
.equ SWI_EXIT, 0x11 @terminate program
.equ SWI_GetTicks, 0x6d @get current time
.equ SEG_A, 0x80 @ patterns for 8 segment display
.equ SEG_B, 0x40 @byte values for each segment
.equ SEG_C, 0x20 @of the 8 segment display
.equ SEG_D, 0x08
.equ SEG_E, 0x04
.equ SEG_F, 0x02
.equ SEG_G, 0x01
.equ SEG_P, 0x10
.equ LEFT_LED, 0x02 @bit patterns for LED lights
.equ RIGHT_LED, 0x01
.equ LEFT_BLACK_BUTTON,0x02 @bit patterns for black buttons
.equ RIGHT_BLACK_BUTTON,0x01 @and for blue buttons
.equ BLUE_KEY_00, 0x01 @button(0)
.equ BLUE_KEY_01, 0x02 @button(1)
.equ BLUE_KEY_02, 0x04 @button(2)
.equ BLUE_KEY_03, 0x08 @button(3)
.equ BLUE_KEY_04, 0x10 @button(4)
.equ BLUE_KEY_05, 0x20 @button(5)
.equ BLUE_KEY_06, 0x40 @button(6)
.equ BLUE_KEY_07, 0x80 @button(7)
.equ BLUE_KEY_08, 1<<8 @button(8) 
.equ BLUE_KEY_09, 1<<9 @button(9)
.equ BLUE_KEY_10, 1<<10 @button(10)
.equ BLUE_KEY_11, 1<<11 @button(11)
.equ BLUE_KEY_12, 1<<12 @button(12)
.equ BLUE_KEY_13, 1<<13 @button(13)
.equ BLUE_KEY_14, 1<<14 @button(14)
.equ BLUE_KEY_15, 1<<15 @button(15)
				
	
	mov r8, #0  @Contador das RODADAS
	mov r9, #0  @Cronometro

Rodadas:
	add r8, r8, #1
	cmp r8, #7
	beq Vencedor
@Clear the board, clear the LCD screen
	swi SWI_CLEAR_DISPLAY
@8-segment blank
	mov r0,#0
	swi SWI_SETSEG8
@draw a message to the lcd screen on line#1, column 4
	mov r0,#4 @ column number
	mov r1,#1 @ row number
	ldr r2,=TextoRodadas @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen
	mov r0,#12 @ column number
	mov r1,#1 @ row number
	mov r2,r8 
	swi SWI_DRAW_INT
	swi SWI_GetTicks
	mov r9, r0
	mov r0,#12 @ column number
	mov r1,#5 @ row number
	mov r2,r9 
	swi SWI_DRAW_INT
	mov r0,#22 @ column number
	mov r1,#5 @ row number
	ldr r2,=Ms @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen


Begin:
@draw a message to inform user to press a black button
@8-segment blank
	mov r0,#0
	swi SWI_SETSEG8
	mov r0,#6 @ column number
	mov r1,#3 @ row number
	ldr r2,=PressBlackL @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen
@wait for user to press a black button
	mov r0,#0
LB1:
	swi SWI_CheckBlack @get button press into R0
	cmp r0,#0
	beq LB1 @ if zero, no button pressed
	cmp r0,#RIGHT_BLACK_BUTTON
	bne LD1 @ bne -> branch if not equal
	@ldr r0,=SEG_B|SEG_C|SEG_F @right button, show -|
	@swi SWI_SETSEG8
	mov r0,#RIGHT_LED @turn on right led
	swi SWI_SETLED
	bal RandomNum
LD1: @left black pressed
	@ldr r0,=SEG_G|SEG_E|SEG_F @display |- on 8segment
	@swi SWI_SETSEG8
	mov r0,#LEFT_LED @turn on LEFT led
	swi SWI_SETLED


RandomNum:
	mov r4, #15
	SWI SWI_GetTicks
	and r1, r0, r4
	cmp r1, #0
	beq RandomNumContinua
	sub r1, r1, #1
	cmp r1, #0
	beq RandomNumContinua
	sub r1, r1, #1
	cmp r1, #0
	beq RandomNumContinua
	sub r1, r1, #1
	cmp r1, #0
	beq RandomNumContinua
	sub r1, r1, #1
	cmp r1, #0
	beq RandomNumContinua
	sub r1, r1, #1
	cmp r1, #0
	beq RandomNumContinua
	sub r1, r1, #1
RandomNumContinua:
	mov r6, r1 @guarda valor de r1 em r6
	ldr r0, =Digits
	ldr r0, [r0,r1,lsl#2]  @R0 <= Digits [R1]
	SWI SWI_SETSEG8
@Draw a message to inform user to press a blue button
	mov r0,#2 @clear previous line 2
	swi SWI_CLEAR_DISPLAY
	mov r0,#6 @ column number
	mov r1,#2 @ row number
	ldr r2,=PressBlue @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen
	mov r4,#16
BLUELOOP:
@wait for user to press blue button
	mov r0,#0
BB1:
	swi SWI_CheckBlue @get button press into R0
	cmp r0,#0
	beq BB1 @ if zero, no button pressed
	mov r5, #1 @Pra comparar se e zero
	mov r7, #0 @r7 Vai ser o Contador
Comparador:
	cmp r0, r5
	bne Part1
	cmp r6, r7
	beq Rodadas
	cmp r6, r7
	bne GameOver
Part1:
	movs r0, r0, LSR #1
	add r7, r7, #1
	b Comparador





GameOver:
@Clear the board, clear the LCD screen
	swi SWI_CLEAR_DISPLAY
@8-segment blank
	mov r0,#0
	swi SWI_SETSEG8
	@draw a message to the lcd screen on line#1, column 4
	mov r0,#4 @ column number
	mov r1,#1 @ row number
	ldr r2,=Perdeu @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen


Vencedor:
@Clear the board, clear the LCD screen
	swi SWI_CLEAR_DISPLAY
@8-segment blank
	mov r0,#0
	swi SWI_SETSEG8
	@draw a message to the lcd screen on line#1, column 4
	mov r0,#4 @ column number
	mov r1,#1 @ row number
	ldr r2,=Ganhou @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen



	.data
TextoRodadas: .asciz "Rodada "
Ms: .asciz "ms"
LeftLED: .asciz "LEFT light"
RightLED: .asciz "RIGHT light"
PressBlackL: .asciz "Pressione um botao Preto"
Perdeu: .asciz "PERDEU SEU RUIM"
Ganhou: .asciz "Voce venceu!  Tempo :            ms"
Bye: .asciz "Bye for now."
Blank: .asciz " "
Digits:
	.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G @0
	.word SEG_B|SEG_C @1
	.word SEG_A|SEG_B|SEG_F|SEG_E|SEG_D @2
	.word SEG_A|SEG_B|SEG_F|SEG_C|SEG_D @3
	.word SEG_G|SEG_F|SEG_B|SEG_C @4
	.word SEG_A|SEG_G|SEG_F|SEG_C|SEG_D @5
	.word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C @6
	.word SEG_A|SEG_B|SEG_C @7
	.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
	.word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C @9
	.word 0 @Blank display
PressBlue: .asciz "Pressione o botao AZUL BURRO"
InvBlue: .asciz "Invalid blue button - try again"
TestBlue: .asciz "Tests ="
	.end