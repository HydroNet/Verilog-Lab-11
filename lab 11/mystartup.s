Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F
	
I_Bit           EQU     0x80           
F_Bit           EQU     0x40           
	
IRQ_Stack_Size  EQU     0x00000100
FIQ_Stack_Size  EQU     0x00000100
SVC_Stack_Size  EQU     0x00000100
USR_Stack_Size  EQU     0x00000100
	
SRAM_Base		EQU		0x40000000
Stack_Top		EQU		SRAM_Base+USR_Stack_Size
	
MAMCR			EQU		0xE01FC000
MAMTIM			EQU		0xE01FC004
	
				AREA	RESET,CODE,Readonly
ENTRY			
				IMPORT	user_code
				

VECTORS 
				LDR		PC,Reset_Addr
				LDR		PC,Undef_Addr
				LDR		PC,SWI_Addr
				LDR		PC,PAbt_Addr 
				LDR		PC,DAbt_Addr
				NOP
				LDR		PC,IRQ_Addr
				LDR		PC,FIQ_Addr

Reset_Addr		DCD		ResetHandler
Undef_Addr		DCD		UndefHandler
SWI_Addr		DCD		SWIHandler
PAbt_Addr		DCD		PAbtHandler
DAbt_Addr		DCD		DAbtHandler
				DCD		0
IRQ_Addr		DCD		IRQHandler   
FIQ_Addr 		DCD		FIQHandler
	

	
ResetHandler
;MAM setup
				LDR		r1,=MAMCR
				MOV		r0,#0x0
				STR		r0,[r1]
				LDR		r2,=MAMTIM
				MOV		r0,#0x1
				STR		r0,[r2]
				MOV		r0,#0x2
				STR		r0,[r1]
;=============================================================================	

;--------Timer Setup--------------
T0PR  	EQU 0xE000400C
T0TCR 	EQU 0xE0004004
T0CTCR	EQU	0xE0004070

T0MR0   EQU 0xE0004018
T0MR1   EQU 0xE000401C
T0MR2   EQU 0xE0004020
T0MR3   EQU 0xE0004024
	
T0MCR	EQU 0xE0004014
T0EMR	EQU 0xE000403C
T0IR	EQU 0xE0004000
;*************************	
T1PR  	EQU 0xE000800C
T1TCR 	EQU 0xE0008004
T1CTCR	EQU	0xE0008070

T1MR0   EQU 0xE0008018
T1MR1   EQU 0xE000801C
T1MR2   EQU 0xE0008020
T1MR3   EQU 0xE0008024
	
T1MCR	EQU 0xE0008014
T1EMR	EQU 0xE000803C

T1IR	EQU 0xE0008000
;-------------------------------------
PINSEL0 EQU 0xE002C000
PINSEL1 EQU 0xE002C004
	
IO0SET		EQU	0xE0028004
IO0CLR		EQU	0xE002800C
	
		
		

		
;-------------------------------------------------------------------
;VIC			
VICIntSelect    EQU		0xFFFFF00C
VICIntEnable    EQU		0xFFFFF010	
VICIntEnClear   EQU     0xFFFFF014
VICVectCntl0    EQU     0xFFFFF200	
VICVectAddr0    EQU 	0xFFFFF100
	
				LDR		r0,=VICIntSelect
				LDR		r2,= 0x10 ;TIMER0 IRQ
				LDR		r1,[r0]
				BIC		r3,r1,r2
				STR		r3,[r0]

				LDR		r0,=VICIntEnable
				LDR		r2,= 0x10 ;TIMER0 Source Enable
				LDR		r1,[r0]
				ORR		r3,r2,r1
				STR		r3,[r0]	

				LDR		r0,=VICVectCntl0
				LDR		r2,=0x20
				LDR		r1,[r0]
				ORR		r3,r2,r1
				STR		r3,[r0]	
				
				LDR		r0,=VICVectAddr0
				LDR		r2,= 0x20
				LDR		r1,[r0]
				ORR		r3,r2,r1
				STR		r3,[r0]	


;==============================================================================				
				
;Stack Setup
				LDR 	R0,= Stack_Top
;Enter Supervisor Mode and set Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                ADD     R0, R0, #SVC_Stack_Size
				
;Enter IRQ Mode and set Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                ADD     R0, R0, #IRQ_Stack_Size
;Enter FIQ Mode and set Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                ADD     R0, R0, #FIQ_Stack_Size
;Enter User Mode enable interrupts
				MOV		R14, #Mode_USR
				BIC 	R14,R14,#(I_Bit + F_Bit)
				MSR		CPSR_c,R14
				MOV		SP,r0
				
				
				LDR R0,= T0PR         ;Prescale Register
				LDR R1,= 0x2710       ;Prescale value
				STR	R1,[R0]	          ;Store Prescale
		
				LDR R0,= T0MR0 ;Match Register 0
				LDR R1,= 0x5   ;CP to match
				STR	R1,[R0]	   ;Store Match Value
		
				LDR R0,= T0MR1 ;Match Register 1
				LDR R1,= 0xA   ;CP to match
				STR	R1,[R0]	   ;Store Match Value
		
				LDR R0,= T0MR2 ;Match Register 2
				LDR R1,= 0xF   ;CP to match
				STR	R1,[R0]	   ;Store Match Value
		
				LDR R0,= T0MR3 ;Match Register 3
				LDR R1,= 0x14  ;CP to match
				STR	R1,[R0]	   ;Store Match Value
		
				LDR R0,= T0MCR ;Match Control Register 
				LDR R1,= 0x649 ;All MR will interrupt, MR3 reset
				STR	R1,[R0]	   ;
		
				LDR R0,= T0CTCR      ;Timer Mode Register
				LDR R1,=0x00000011   ;Every Rising PCLK
				LDR R2,[R0]
				BIC	R2,R1
				STR	R2,[R0]
		
				LDR R0,=T0IR
				LDR R1,=0xF
				LDR R2,[R0]
				ORR R2,R1
				STR R2,[R0]
				
				LDR R0,= T0TCR      ;Timer Control Register
				LDR R1,=0x00000001	;Counter Enable
				LDR R2,[R0]
				ORR	R2,R1
				STR	R2,[R0]
				
				
				
				LDR		PC,=user_code

SWIHandler   B	  SWIHandler	
PAbtHandler  B    PAbtHandler  
DAbtHandler  B    DAbtHandler  
IRQHandler   
			STMDB		SP!,{R0-R12,LR} 
			
			LDR R0,=T0IR
			LDR R1,[R0]		;Clear Flag
			STR R1,[R0]
			

			CMP R1,#0x1
			LDREQ R0,=IO0SET
			LDREQ R1,=0x1000	;P12 set
			STREQ R1,[R0]
			BEQ   EXIT
			
			CMP R1,#0x2
			LDREQ  R0,=IO0SET 
			LDREQ  R1,=0x200000  ;P21 set
			STREQ  R1,[R0]
			BEQ   EXIT

			CMP R1,#0x4
			LDREQ R0,=IO0CLR
			LDREQ R1,=0x1000	;P12 Clear
			STREQ R1,[R0]
			BEQ   EXIT

       		CMP R1,#0x8	
			LDREQ R0,=IO0CLR 
			LDREQ R1,=0x200000  ;P21 Clear
			STREQ R1,[R0]
			BEQ   EXIT
			
EXIT		
			
			
			LDMIA		SP!,{R0-R12,LR}
			SUBS  		pc, lr, #4    ;copy lr - 4 to PC
FIQHandler   B	  FIQHandler
UndefHandler B    UndefHandler 		


stop			B		stop
				END