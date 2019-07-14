.equ SWI_SETSEG8, 0x200 @display de 8 segmentos
.equ SWI_SETLED, 0x201 @LEDs on/off
.equ SWI_CheckBlack, 0x202 @check botão Preto
.equ SWI_CheckBlue, 0x203 @check botão Azul
.equ SWI_DRAW_STRING, 0x204 @Desenha string no LCD  R2
.equ SWI_DRAW_INT, 0x205 @desenha um inteiro no LCD  R2
.equ SWI_CLEAR_DISPLAY,0x206 @limpa LCD
.equ SWI_CLEAR_LINE, 0x208 @limpa uma linha no LCD
.equ SWI_EXIT, 0x11 @termina um programa
.equ SWI_GetTicks, 0x6d @pega o tempo atual
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
	mov r3, #0  @Auxiliar Timer
	
Rodadas:
	add r8, r8, #1 @Incrementa ao contador de rodadas
	cmp r8, #7	   @Compara o número de rodadas 
	beq Vencedor
@Limpa o LCD
	swi SWI_CLEAR_DISPLAY
@Limpa o display de 8 segmentos
	mov r0,#0
	swi SWI_SETSEG8
@Escreve uma mensagem 
	mov r0,#4 @ column number
	mov r1,#1 @ row number
	ldr r2,=TextoRodadas 
	swi SWI_DRAW_STRING 
@Escreve um inteiro
	mov r0,#12 @ column number
	mov r1,#1 @ row number
	mov r2,r8 
	swi SWI_DRAW_INT

Begin:
	mov r0,#0
	swi SWI_SETSEG8
@Escreve instrução para apertar o botão preto
	mov r0,#6 @ column number
	mov r1,#3 @ row number
	ldr r2,=PressBlackL 
	swi SWI_DRAW_STRING 
@espera o usuário apertar o botão preto
	mov r0,#0
LB1:
	swi SWI_CheckBlack @Valor do botão preto recebido em R0
	cmp r0,#0
	beq LB1 @ se for 0, botão não apertado
	cmp r0,#RIGHT_BLACK_BUTTON
	bne LD1 @Se não foi apertado o botão direito, pula para o esquerdo
	swi SWI_CLEAR_DISPLAY
	bal RandomNum
LD1: @botão esquerdo foi apertado
	swi SWI_CLEAR_DISPLAY

RandomNum:	
	
	stmfd sp!, {r0-r9,lr}
	swi SWI_GetTicks
	mov r9, r0 @ R9: início Timer 

	mov r0,#20 @ coluna
	mov r1,#5 @ linha
	ldr r2,=Ms 
	swi SWI_DRAW_STRING 

@ usa o valor do “tick” do relógio interno do simulador e utilizar os 4 bits menos
@ significativos como valor aleatório
	mov r4, #15	 @recebe 15, para dividir entre 0 e f			
	SWI SWI_GetTicks
	and r1, r0, r4  @Faz uma comparação para pegar os últimos 4 bits, totalizando 16 valores
	mov r6, r1 @guarda valor de r1 em r6
	ldr r0, =Digits
	ldr r0, [r0,r1,lsl#2]  @r0 recebe Digits na posição r1
	SWI SWI_SETSEG8
	mov r4,#16

BLUELOOP: 
@loop de verificação do botão Azul
	mov r0,#0
BB1:
	
	swi SWI_GetTicks
	subs r0, r0, r9 @ R0: Tempo desde o início do Timer
	rsblt r0, r0, #0 @ Diferença entre tempo de inicial e atual
	mov r4, r0

	@função wait cycle para 50 ms
	Wait:
		stmfd sp!, {r0-r1,lr}
		swi SWI_GetTicks
		mov r1, r0 
	WaitLoop:
		swi SWI_GetTicks
		subs r0, r0, r1
		rsblt r0, r0, #0 
		cmp r0, #50
		blt WaitLoop

	@desenha o tempo na tela
	mov r0,#12 
	mov r1,#5 
	mov r2,r4 
	swi SWI_DRAW_INT

	mov r0, #0
	swi SWI_CheckBlue @verifica se o botao Azul foi apertado e o valor vai para r0
	cmp r0,#0
	beq BB1 @ se for igual a 0, botão não foi apertado, volta pra BB1

	mov r5, #1 @Pra comparar se e zero
	mov r7, #0 @r7 Vai ser o Contador

@verifica se o apertou o botão certo
Comparador:

	cmp r0, r5
	bne Part1
	add r3, r3, r4   @o tempo que o usuário levou para apertar o botão, somado a cada rodada
	cmp r6, r7
	beq Rodadas
	cmp r6, r7
	bne GameOver
@r0 recebe 2 elevado ao "número" do botão apertado, então os bits são deslocados para a direita para achar o "número"
Part1:
	movs r0, r0, LSR #1
	add r7, r7, #1
	b Comparador

@escreve mensagem quando o jogador perde
GameOver:
	swi SWI_CLEAR_DISPLAY
	mov r0,#0
	swi SWI_SETSEG8
	mov r0,#4 
	mov r1,#1 
	ldr r2,=Perdeu @ pointer to string
	swi SWI_DRAW_STRING @ draw to the LCD screen
	b Fim

@escreve mensagem quando o jogador vence
Vencedor:
	swi SWI_CLEAR_DISPLAY
	mov r0,#0
	swi SWI_SETSEG8
	mov r0,#4 
	mov r1,#1 
	ldr r2,=Ganhou 
	swi SWI_DRAW_STRING 

@escreve mensagem indicando o final do jogo e tempo acumulado de todas as rodadas jogadas
Fim:

	mov r0,#28 
	mov r1,#1 
	mov r2, r3 
	swi SWI_DRAW_INT
	mov r0,#4 
	mov r1,#3 
	ldr r2,=Final 
	swi SWI_DRAW_STRING 	
	swi SWI_EXIT

	.data
TextoRodadas: .asciz "Rodada "
Ms: .asciz "ms"
Final: .asciz "FIM"
PressBlackL: .asciz "Pressione um botao Preto"
Perdeu: .asciz "Voce perdeu!  Tempo :            ms"
Ganhou: .asciz "Voce venceu!  Tempo :            ms"
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
	.word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C|SEG_E @a
	.word SEG_F|SEG_G|SEG_C|SEG_E|SEG_D @b
	.word SEG_A|SEG_G|SEG_E|SEG_D @c
	.word SEG_B|SEG_F|SEG_D|SEG_C|SEG_E @d
	.word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D @e
	.word SEG_A|SEG_G|SEG_F|SEG_E @f
	.word 0 @Blank display

	.end