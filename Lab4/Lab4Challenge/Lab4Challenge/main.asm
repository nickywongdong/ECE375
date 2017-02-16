
;***********************************************************
;*
;*	ECE375: Computer Organization and Assembly Language Programming
;*
;*	Description
;*
;*	Lab 4 – Data Manipulation & the LCD CHALLENGE
;*	Continuation of lab4, make the characters daaance
;***********************************************************
;*
;*	 Author: Nicholas Wong
;*	   Date: 2/2/17
;*
;***********************************************************

.include "m128def.inc"			; Include definition file


;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register is
								; required for LCD Driver

;.def	i	= r20				;set as our counter
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp INIT				; Reset interrupt

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine

		LDI		mpr, low(RAMEND)	; Initialize Stack Pointer
		OUT		SPL, mpr
		LDI		mpr, high(RAMEND)
		OUT		SPH, mpr


		rcall	LCDInit					; Initialize LCD Display
		
		; Move strings from Program Memory to Data Memory
		ldi		ZH, high(myName<<1)		; load Z pointer with test string
		ldi		ZL, low(myName<<1)
		ldi		Yl, low(LCDLn1Addr)		; init Y pointer
		ldi		YH, high(LCDLn1Addr)
		ldi		count, 12				; store length of myName in count register (defined in driver)

		rcall	LINE1
		rcall	LINE2
		
		; NOTE that there is no RET or RJMP from INIT, this
		; is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:							; The Main program
		; Display the strings on the LCD Display
		;rcall	LINE1		
		;rcall	LINE2
		rcall	LCDWrite			;call the write function in Driver to write strings to ATMega128

		rjmp	MAIN			; jump back to main and create an infinite
								; while loop.  Generally, every main program is an
								; infinite while loop, never let the main program
								; just run off

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: LINE1
; Desc: Loop to store name string from program memory
;		to data memory
;-----------------------------------------------------------
LINE1:
		lpm		mpr, Z+				; Load constant from Program
		st		Y+, mpr
		dec		count				; Decrement Read Counter
		brne	LINE1
		
		; Prepare line 2, move from program memory to data memory
		ldi		ZH, high(myText<<1)	; Z points to myText - "hello world"
		ldi		ZL, low(myText<<1)

		ldi		YL, low(LCDLn2Addr)	; initialize Y pointer
		ldi		YH, high(LCDLn2Addr)

		ldi		count, 12

		ret

;-----------------------------------------------------------
; Func: LINE2
; Desc: Loop to store hello world string from program memory
;		to data memory
;-----------------------------------------------------------

LINE2:
		lpm		mpr, Z+			; Load constant from Program
		st		Y+, mpr
		dec		count			; Decrement Read Counter	
		brne	LINE2
		
		ret

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; My strings stored in program data tobe moved to data mem
;-----------------------------------------------------------
myTest:
.DB		"My Test String"		; Declaring data in ProgMem

myName:
.DB		"Nick & Riley"			; 1st line (12 chars)

myText:
.DB		"Hello World", 0		; 2nd Line (11 chars + null)


;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver


;Hi Nick.doc= Hello Forever. 21 into the sky you and i. when your at the end of the road 
