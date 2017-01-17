;Cristian Silva
;ID:006283655
; Assembly language LED Drive file...
; EECE 237 Fall 2015
;
;This is a template on which codes are to be added to complete the work.
;The template as is not final and expects revisions.
;Examin the structure of the program before adding codes.
;The area where student works are to be added is marked below.
 
	AREA   LED_Drive, CODE, READONLY
	ENTRY
	EXPORT   __main
__main  B  start
         
RCC_BASE 			EQU   	0x40021000	;This may change later
RCC_AHBENR_OFF  	EQU  	0x14
RCC_AHBENR_GPIOEEN  EQU  	0X220000
GPIOE_BASE			EQU		0X48001000     ;This may change later.
GPIOA_BASE			EQU		0x48000000		;AHB2PERIPH_BASE + PERIPH_BASE + 0X0000  
MODER_OFFSET 		EQU		0x00			
OTYPER_OFFSET		EQU		0x04	
OSPEEDR_OFFSET		EQU		0x08	
PUPDR_OFFSET		EQU		0x0C	
IDR_OFFSET		EQU		0x10	
ODR_OFFSET		EQU		0x14
BSRR_OFFSET		EQU		0x18	
AFRL_OFFSET		EQU		0x20 
AFRH_OFFSET		EQU		0x24 
BRR_OFFSET		EQU 	0x28	
Note_Length		EQU		0x00000008
Note_A			EQU		0x000FAA78 ; this is the pitch of this note
Note_Bs			EQU		0x0004AA78
Note_C			EQU		0x0003AA78
Note_D			EQU		0x0007AA78
Note_E			EQU		0x0009AA78

start
	BL	  config_rcc
	BL	  config_gpioa
	BL    config_gpioe	;Configure LED port
	
            
main_loop
	BL	  push_button
	BL 	  song
	B	 main_loop	;Infinite loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;config_gpioe
config_rcc	
; Enable RCC GPIO Clock
	LDR   R0, =RCC_BASE ; load base address for RCC
	LDR   R1, =RCC_AHBENR_OFF ; load offset for AHBENR
	LDR   R2, =RCC_AHBENR_GPIOEEN ; load value for GPIO PortE enable
	LDR   R3, [R0, R1] ; Read current AHBENR value
	ORR   R2, R2, R3  ; Modify AHBENR value to enable E
	STR   R2, [R0, R1] ; Write new AHBENR value to register


;configure GPIO_A (User Button PA0)	
config_gpioa

	LDR	R8, =GPIOA_BASE				;
	LDR	R1,[R8,#MODER_OFFSET]				;0x55550000
	;STR	R1, [R0, #MODER_OFFSET]		;STORE MODER=0X10
	BIC R1,R1,#0x03
	STR R1, [R8,#MODER_OFFSET]

config_gpioe
	; Configure GPIO_E port (LED port)
	LDR	R0, =GPIOE_BASE				;
	LDR	R1, =0x55550000				;0x00000000
	STR	R1, [R0, #MODER_OFFSET]		;STORE MODER=0X10
	LDR	R1, =0x0000
	STR	R1, [R0, #OTYPER_OFFSET]	; STORE OTYPER =0X00
	LDR	R1, =0x0000
	STR	R1, [R0, #OSPEEDR_OFFSET]	; STORE OSPEEDR=0X00
	LDR	R1, =0x0000
	STR	R1, [R0, #PUPDR_OFFSET]		; STORE PUPDR=0X00
	LDR	R1, =0x0000
	STR	R1, [R0, #BSRR_OFFSET]		; STORE BSRR=0X00
	LDR	R1, =0x0000
	STR	R1, [R0, #AFRH_OFFSET]		; STORE AFRH=-X00
	LDR	R1, =0x0000
	STR	R1, [R0, #AFRL_OFFSET]		; STORE AFRL=0X00
	

	B    song
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;           


 
push_button
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;loads the push_button with the gpioa

;loops back into this to WAIT for the button to be pressed
wait
	LDR R1, [R8, #IDR_OFFSET] ;first must read idr
	ANDS R1, R1, #0x00000001 ;and it with the last bit/compare that only 0001 is active when button is pressed
;	EQU R5,#0x00000001
	BEQ wait ;wait for the button to be pressed 
	BX LR
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
A
	MOV R6,	LR
	LDR R1, =Note_Length
length_loop_A
;Create a pattern and load the output register
	SUBS R1, R1, #1 ;how many times it loops
	LDR R2, =0XAA00
	STR R2, [R0,#ODR_OFFSET]
	BL	pitch_A
	CMP  R1, #0
	BNE flash_A

	BX	R6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flash_A
	LDR R2, =0X0000
	STR R2, [R0,#ODR_OFFSET]
	BL pitch_A  ;delay
	;pitch returns here
	B  length_loop_A
		
pitch_A
	LDR R9, =Note_A	;speed aka frequency
pitch_loop_A
	SUBS R9, R9, #1 ;how many times it loops
	CMP  R9, #0
	BNE  pitch_loop_A
	
	BX	LR
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bs
	MOV R6,	LR
	LDR R1, =Note_Length
length_loop_B
;Create a pattern and load the output register
	SUBS R1, R1, #1 ;how many times it loops
	LDR R2, =0XAA00
	STR R2, [R0,#ODR_OFFSET]
	BL	pitch_B
	CMP  R1, #0
	BNE flash_bs
	BX	R6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flash_bs
	LDR R2, =0X0000
	STR R2, [R0,#ODR_OFFSET]
	BL pitch_B  ;delay
	;pitch returns here
	B  length_loop_B
pitch_B
	LDR R9, =Note_Bs	;speed aka frequency
pitch_loop_B
	SUBS R9, R9, #1 ;how many times it loops
	CMP  R9, #0
	BNE  pitch_loop_B
	
	BX	LR
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

C
	MOV R6,	LR
	LDR R1, =Note_Length
length_loop_C
;Create a pattern and load the output register
	SUBS R1, R1, #1 ;how many times it loops
	LDR R2, =0XAA00
	STR R2, [R0,#ODR_OFFSET]
	BL	pitch_C
	CMP  R1, #0
	BNE flash_C

	BX	R6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flash_C
	LDR R2, =0X0000
	STR R2, [R0,#ODR_OFFSET]
	BL pitch_C  ;delay
	;pitch returns here
	B  length_loop_C
		
pitch_C
	LDR R9, =Note_C	;speed aka frequency
pitch_loop_C
	SUBS R9, R9, #1 ;how many times it loops
	CMP  R9, #0
	BNE  pitch_loop_C
	
	BX	LR
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
D
	MOV R6,	LR
	LDR R1, =Note_Length
length_loop_D
;Create a pattern and load the output register
	SUBS R1, R1, #1 ;how many times it loops
	LDR R2, =0XAA00
	STR R2, [R0,#ODR_OFFSET]
	BL	pitch_D
	CMP  R1, #0
	BNE flash_D

	BX	R6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flash_D
	LDR R2, =0X0000
	STR R2, [R0,#ODR_OFFSET]
	BL pitch_D  ;delay
	;pitch returns here
	B  length_loop_D
		
pitch_D
	LDR R9, =Note_D	;speed aka frequency
pitch_loop_D
	SUBS R9, R9, #1 ;how many times it loops
	CMP  R9, #0
	BNE  pitch_loop_D
	
	BX	LR
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
E
	MOV R6,	LR
	LDR R1, =Note_Length
length_loop_E
;Create a pattern and load the output register
	SUBS R1, R1, #1 ;how many times it loops
	LDR R2, =0XAA00
	STR R2, [R0,#ODR_OFFSET]
	BL	pitch_E
	CMP  R1, #0
	BNE flash_E

	BX	R6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flash_E
	LDR R2, =0X0000
	STR R2, [R0,#ODR_OFFSET]
	BL pitch_E  ;delay
	;pitch returns here
	B  length_loop_E
		
pitch_E
	LDR R9, =Note_E	;speed aka frequency
pitch_loop_E
	SUBS R9, R9, #1 ;how many times it loops
	CMP  R9, #0
	BNE  pitch_loop_E
	
	BX	LR
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

song
	BL push_button
	BL 	  A
	BL	  Bs
	BL    A
	BL    D
	BL	  E
	BL	  E
	BL	  E
	BL    D
	BL    D
	BL    D
	BL    C
	BL    C
	BL    C
	BL 	  A
	BL	  Bs
	BL    C
	BL    D
	BL	  E
	BL	  E
	BL	  E
	BL 	  E
	BL	  D
	BL	  D
	BL    E
	BL    D
	BL    C


;;;;;;Student work ends here  ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
exit
	BL song         ; return


	NOP
	END 


