			GLOBAL	user_code
			AREA	usercode,CODE,READONLY
user_code

PINSEL0 	EQU 0xE002C000
PINSEL1 	EQU 0xE002C004
T0IR		EQU 0xE0004000
IO0DIR      EQU 0xE0028008	
IO1DIR      EQU 0xE0028018
	
IO0SET		EQU	0xE0028004
IO0CLR		EQU	0xE002800C
	

	
			LDR R3,=PINSEL0
			LDR R1,=0x3000000 ;Set P0.12 GPIO
			LDR R2,[R3]
			BIC R2,R1
			STR R2,[R3]
			
			LDR R3,=PINSEL1
			LDR R1,=0xC00    ;Set P0.21 GPIO
			LDR R2,[R3]
			BIC R2,R1
			STR R2,[R3]
	
			LDR R0,=IO0DIR
			LDR R1,=0x201000	;P0.12,P0.21 Output
			LDR R2,[R0]
			ORR R2,R2,R1
			STR R2,[R0]
			
			B task2
;======================Task 1=================================
ploop		LDR R4,=T0IR 
MR0			LDR R1,[R4]
			CMP R1,#1    ;Check MR0
			BEQ MR0match
MR1			LDR R1,[R4]
			CMP R1,#2    ;Check MR1
			BEQ MR1match
MR2			LDR R1,[R4]
			CMP R1,#4    ;Check MR2
			BEQ MR2match
MR3			LDR R1,[R4]
			CMP R1,#8    ;Check MR3
			BEQ MR3match
			B   ploop

MR0match    LDR R2,=0x1
			STR R2,[R4]	
			
			LDR R0,=IO0SET
			LDR R1,=0x1000	;P12 set
			STR R1,[R0]

			B   MR1
			
MR1match    LDR R2,=0x2 ;Clear Flag
			STR R2,[R4]	
			
			LDR R0,=IO0SET 
			LDR R1,=0x200000  ;P21 set
			STR R1,[R0]
			
			B   MR2

MR2match    LDR R2,=0x4 ;Clear Flag
			STR R2,[R4]	
			
			LDR R0,=IO0CLR
			LDR R1,=0x1000	;P12 Clear
			STR R1,[R0]

			B   MR3

MR3match    LDR R2,=0x8;Clear Flag
			STR R2,[R4]	
			
			LDR R0,=IO0CLR 
			LDR R1,=0x200000  ;P21 Clear
			STR R1,[R0]
			
			B   MR0
;=======================================================

task2

;======================Task 2=================================


stop    	B 		 stop
			END