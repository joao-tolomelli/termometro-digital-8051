;================================================================================
; --- Mapeamento de Hardware ---
         rs      equ     P1.5    	;Reg Select ligado em P1.7
         rw      equ     P1.6    	;Read/Write ligado em P1.6
         en      equ     P1.7    	;Enable ligado em P1.5
         dat     equ     P2     	;Bits de dados em todo P2
	 DQ      BIT     P3.7    	;One wire
;================================================================================
; --- Constantes ---
	 WDLSB   DATA    30H 
	 WDMSB   DATA    31H 

;================================================================================
; --- Vetor de RESET ---
        org     0000h          		 ;origem no endereço 00h de memória
	
; --- Configuração da comunicação serial ---

	mov 	SCON,#01010000b
	mov	TMOD,#20h
	mov	TL1,#0FDh
	mov	TH1,#0FDh
	anl	PCON,#01111111b
	setb	TR1
	
        acall   delay500ms     		 ;aguarda 500ms para estabilizar
   
;================================================================================
; --- Programa Principal ---
inicio:

        acall   lcd_init       		 ;Chama sub rotina de inicialização
	
; --- Atualiza com display com o texto de inicialização ---
	lcall 	DSWD			;Realiza a leitura do sensor
        mov     dptr,#LCD_INIT1 	;Move mensagem para DPTR
        acall   send_lcd        	;Chama sub rotina para enviar mensagem para LCD
        acall   new_line        	;Chama sub rotina para ir para próxima linha
        mov     dptr,#LCD_INIT2 	;Move mensagem para DPTR
        acall   send_lcd        	;Chama sub rotina para enviar mensagem para LCD

        acall   delay500ms      	;aguarda 500ms
        acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms
	
	acall   lcd_home        	;Chama sub rotina para voltar ao início do lcd
	
; --- Loop das telas ---
loop:
       
        lcall 	DSWD			;Realiza a leitura do sensor
	
; --- Primeira tela ---
        mov     dptr,#LCD1      	;Move mensagem para DPTR
        acall   send_lcd        	;Chama sub rotina para enviar mensagem para LCD

        acall   new_line        	;Chama sub rotina para ir para próxima linha

        mov     dptr,#LCD2      	;Move mensagem para DPTR
        acall   send_lcd        	;Chama sub rotina para enviar mensagem para LCD

        acall   delay500ms      	;aguarda 500ms
        acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms
        acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms

        acall   lcd_home        	;Chama sub rotina para voltar ao início do lcd
	
; --- Segunda tela ---
        mov     dptr,#LCD3      	;Move mensagem para DPTR
        acall   send_lcd        	;Chama sub rotina para enviar mensagem para LCD

        acall   new_line        	;Chama sub rotina para ir para próxima linha

        mov     dptr,#LCD4      	;Move mensagem para DPTR
        acall   send_lcd_TEMP   	;Chama sub rotina para enviar mensagem para LCD

        acall   delay500ms      	;aguarda 500ms
        acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms
        acall   delay500ms      	;aguarda 500ms
	acall   delay500ms      	;aguarda 500ms

        acall   lcd_home        	;Chama sub rotina para voltar ao início do lcd
       
        ajmp    loop            	;Loop infinito

;================================================================================

lcd_init:                       	;Sub Rotina para Inicialização do Display
 
        mov      a,#60d         	;move literal 00111100b para acc
        acall    config         	;chama sub rotina config
        mov      a,#14d         	;move literal 00001110b para acc
        acall    config         	;chama sub rotina config
        mov      a,#1d          	;move literal 00000001b para acc
        acall    config         	;chama sub rotina config
        mov      a,#6d          	;move literal 00000110b para acc
        acall    config         	;chama sub rotina config
        ret                     	;retorna

;================================================================================

config:                         	;Sub Rotina de Configuração

        clr      en             	;limpa pino en
        clr      rs             	;limpa pino rs
        clr      rw             	;limpa pino rw
        acall    wait           	;aguarda 55us
        setb     en             	;aciona enable
        acall    wait           	;aguarda 55us
        mov      dat,a          	;carrega dados em Port P2
        acall    wait           	;aguarda 55us com barramento igual ao valor de acc
        clr      en             	;limpa pino en
        acall    wait           	;aguarda 55us
        ret                     	;retorna

;================================================================================
send_lcd:                       	;Sub Rotina para Enviar dados ao LCD

        mov      R0,#0d         	;Move valor 0d para R0
send:
        mov      a,R0           	;Move conteúdo de R0 para acc
        inc      R0             	;Incrementa acc
        movc     a,@a+dptr      	;Move o byte relativo de dptr somado
					;com o valor de acc para acc
        acall    w_dat          	;chama sub rotina para escrita de dados
        cjne     R0,#16d,send   	;compara R0 com valor de colunas e desvia se for diferente
	
        ret                     	;retorna
;================================================================================

send_lcd_TEMP:                      	;Sub Rotina para Enviar dados de temperatura ao LCD 
	mov      R0,#0d         	;Move valor 0d para R0
send_TEMP1:
        mov      a,R0           	;Move conteúdo de R0 para acc
        inc      R0            	 	;Incrementa acc
        movc     a,@a+dptr      	;Move o byte relativo de dptr somado
					;com o valor de acc para acc
        acall    w_dat          	;chama sub rotina para escrita de dados
        cjne     R0,#6d,send_TEMP1   	;compara R0 com valor de colunas e desvia se for diferente
	
	mov	 A,42H
        orl 	 A,#30H
	mov	 42H,A
        acall    w_dat
	
        mov	 A,43H
        orl 	 A,#30H
	mov	 43H,A
        acall    w_dat
	
; --- Envio dos dados via Bluetooth ---
        mov	 A,42H
	lcall	 send_byte_BT
	mov	 A,43H
	lcall	 send_byte_BT
	mov	 A,#3Bh
	lcall	 send_byte_BT
	
send_TEMP2:
        mov      a,R0           	;Move conteúdo de R0 para acc
        inc      R0             	;Incrementa acc
        movc     a,@a+dptr     	 	;Move o byte relativo de dptr somado
					;com o valor de acc para acc
        acall    w_dat          	;chama sub rotina para escrita de dados
        cjne     R0,#14d,send_TEMP2   	;compara R0 com valor de colunas e desvia se for diferente
	
        ret                     	;retorna

;================================================================================
w_dat:                          	;Sub Rotina para preparar para escrita de mensagem

        clr      en             	;limpa enable
        setb     rs             	;seta rs
        clr      rw             	;limpa rw (escrita)
        acall    wait           	;aguarda 55us
        setb     en             	;seta enable
        acall    wait           	;aguarda 55us
        mov      dat,a          	;carrega mensagem
        acall    wait           	;aguarda 55us
        clr      en             	;limpa enable
        acall    wait           	;aguarda 55us
        ret                     	;retorna
	
;================================================================================
wait:                           	;Sub Rotina para atraso de 55us

        mov     R5,#055d        	;Carrega 55d em R5
aux0:           
        djnz    R5,aux0         	;Decrementa R5. R5 igual a zero? Não, desvia para aux
        ret                     	;Sim, retorna

;================================================================================
new_line:                       	;Sub Rotina para ir para nova linha

        mov      a,#0C0h        	;Carrega 192d em acc
        acall    config         	;chama sub rotina config
        ret                     	;retorna

;================================================================================
lcd_home:                       	;Sub Rotina para ir para o início do LCD

        mov      a,#02d         	;Carrega 2d em acc
        acall    config         	;chama sub rotina config
        ret                     	;retorna

;================================================================================

delay500ms:                     	;Sub Rotina para atraso de 500ms
					; 2       | ciclos de máquina do mnemônico call
        mov     R1,#0fah        	; 1       | move o valor 250 decimal para o registrador R1
 
aux1:
        mov     R2,#0f9h        	; 1 x 250 | move o valor 249 decimal para o registrador R2
        nop                     	; 1 x 250
        nop                     	; 1 x 250
        nop                     	; 1 x 250
        nop                     	; 1 x 250
        nop                     	; 1 x 250

aux2:
        nop                     	; 1 x 250 x 249 = 62250
        nop                     	; 1 x 250 x 249 = 62250
        nop                     	; 1 x 250 x 249 = 62250
        nop                     	; 1 x 250 x 249 = 62250
        nop                     	; 1 x 250 x 249 = 62250
        nop                     	; 1 x 250 x 249 = 62250

        djnz    R2,aux2         	; 2 x 250 x 249 = 124500     | decrementa o R2 até chegar a zero
        djnz    R1,aux1         	; 2 x 250                    | decrementa o R1 até chegar a zero

        ret                     	; 2                          | retorna para a função main
					;------------------------------------
					; Total = 500005 us ~~ 500 ms = 0,5 seg 


;================================================================================

DSWD:					; Lê a temperatura do DS18B20
	LCALL 	RSTSNR      		; Inicializa o sensor
        JNB   	F0,KEND     
        MOV   	R0,#0CCH
        LCALL 	SEND_BYTE    
        MOV   	R0,#44H     
        LCALL 	SEND_BYTE   		; Send a Convert Command   
        SETB  	EA
        MOV   	48H,#1      
SS2: 
        MOV   	49H,#255
SS1:
        MOV   	4AH,#255
SS0: 
        DJNZ  	4AH,SS0
        DJNZ  	49H,SS1
        DJNZ  	48H,SS2
        CLR   	EA
        LCALL 	RSTSNR
        JNB   	F0,KEND
        MOV   	R0,#0CCH       
        LCALL 	SEND_BYTE
        MOV   	R0,#0BEH         
        LCALL 	SEND_BYTE      		; Send Read Scratchpad command 
        LCALL 	READ_BYTE      		; Read the low byte from scratchpad 
        MOV   	WDLSB,A        		; Save the temperature (low byte)
        LCALL 	READ_BYTE      		; Read the high byte from scratchpad
        MOV   	WDMSB,A        		; Save the temperature (high byte)
        LCALL 	TRANS12
KEND:    
        SETB  	EA
        RET
;================================================================================
;
TRANS12:
         MOV   A,30H
         ANL   A,#0F0H
         MOV   3AH,A
         MOV   A,31H
         ANL   A,#0FH
         ORL   A,3AH
         SWAP  A
         MOV   B,#10
         DIV   AB
         MOV   43H,B 
         MOV   b,#10
         DIV   ab
         MOV   42H,B
         MOV   41H,A
         RET
;================================================================================
; Send a byte to the 1 wire line
SEND_BYTE: ;
         MOV   A,R0
         MOV   R5,#8
SEN3:    CLR   C
         RRC   A
         JC    SEN1
         LCALL WRITE_0
         SJMP  SEN2
SEN1:    LCALL WRITE_1
SEN2:    DJNZ  R5,SEN3 ; 
         RET
;================================================================================
; Read a byte from the 1 wire line
READ_BYTE: 
         MOV   R5,#8
READ1:   LCALL READ
         RRC   A
         DJNZ  R5,READ1 ; 
         MOV   R0,A
         RET
;================================================================================
; Reset 1 wire line
RSTSNR:  SETB  DQ
         NOP
         NOP
         CLR   DQ
         MOV   R6,#250 ;
         DJNZ  R6,$
         MOV   R6,#50
         DJNZ  R6,$
         SETB  DQ ;
	 
         MOV   R6,#15
         DJNZ  R6,$
         CALL  CHCK ;
         MOV   R6,#60
         DJNZ  R6,$
         SETB  DQ
         RET


;================================================================================
; low level subroutines
CHCK:    MOV   C,DQ
         JC    RST0
         SETB  F0 ;
         SJMP  CHCK0
RST0:    CLR   F0 ;
CHCK0:   RET

;================================================================================
WRITE_0: 
         CLR   DQ
         MOV   R6,#30
         DJNZ  R6,$
         SETB  DQ
         RET
;================================================================================
WRITE_1: 
         CLR   DQ 
         NOP
         NOP
         NOP
         NOP
         NOP
         SETB  DQ
         MOV   R6,#30
         DJNZ  R6,$
         RET

;================================================================================
READ:    SETB  DQ
         NOP
         NOP
         CLR   DQ
         NOP
         NOP
         SETB  DQ
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         MOV   C,DQ
         MOV   R6,#23
         DJNZ  R6,$
         RET

;================================================================================
DELAY10: MOV   R4,#20
D2:      MOV   R5,#30
         DJNZ  R5,$
         DJNZ  R4,D2
         RET
;================================================================================
send_byte_BT:
	 mov	SBUF,A
	 jnb	TI,$
	 clr	TI
	 ret
;==========================================================================
; Definição de Mensagens para Enviar ao LCD
LCD1:
        db    '     BRASIL     '

LCD2:
        db    ' FORTALEZA - CE '

LCD3:
        db    '   TEMPERATURA  '
	
LCD4:
        db    '      ',11011111b,'C      '
LCD_INIT1:
	db    '  INICIALIZANDO '
	
LCD_INIT2:
	db    '       ...      '
	
        end                     ;Final do programa
	