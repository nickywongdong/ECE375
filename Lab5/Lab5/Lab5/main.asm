;***********************************************************
;*
;*	Lab 5
;*
;*	16 bit arithmetic operations using 8 bit registers
;*
;*	Will have 3 functions; SUB16, ADD16, and MULT16
;*
;***********************************************************
;*
;*	 Author: Nick Wong
;*	   Date: 2/13/17
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register 
.def	rlo = r0				; Low byte of MUL result
.def	rhi = r1				; High byte of MUL result
.def	zero = r2				; Zero register, set to zero in INIT, useful for calculations
.def	A = r3					; A variable
.def	B = r4					; Another variable

.def	oloop = r17				; Outer Loop Counter
.def	iloop = r18				; Inner Loop Counter


;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;-----------------------------------------------------------
; Interrupt Vectors
;-----------------------------------------------------------
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

.org	$0046					; End of Interrupt Vectors

;-----------------------------------------------------------
; Program Initialization
;-----------------------------------------------------------
INIT:							; The initialization routine
		; Initialize Stack Pointer
		LDI		mpr, low(RAMEND)
		OUT		SPL, mpr
		LDI		mpr, high(RAMEND)
		OUT		SPH, mpr

		clr		zero			; Set the zero register to zero, maintain
								; these semantics, meaning, don't
								; load anything else into it.

;-----------------------------------------------------------
; Main Program
;-----------------------------------------------------------
MAIN:							; The Main program

		; Setup the ADD16 function direct test

				; (IN SIMULATOR) Enter values 0xA2FF and 0xF477 into data
				; memory locations where ADD16 will get its inputs from
				; (see "Data Memory Allocation" section below)

				rcall ADD16; Call ADD16 function to test its correctness
				; (calculate A2FF + F477)

				; Observe result in Memory window

		; Setup the SUB16 function direct test

				; (IN SIMULATOR) Enter values 0xF08A and 0x4BCD into data
				; memory locations where SUB16 will get its inputs from

				rcall SUB16; Call SUB16 function to test its correctness
				; (calculate F08A - 4BCD)

				; Observe result in Memory window

		; Setup the MUL24 function direct test

				; (IN SIMULATOR) Enter values 0xFFFFFF and 0xFFFFFF into data
				; memory locations where MUL24 will get its inputs from

				rcall MUL24; Call MUL24 function to test its correctness
				; (calculate FFFFFF * FFFFFF)

				; Observe result in Memory window

		; Call the COMPOUND function
				rcall COMPOUND
				; Observe final result in Memory window

DONE:	rjmp	DONE			; Create an infinite while loop to signify the 
								; end of the program.

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

;-----------------------------------------------------------
; Func: ADD16
; Desc: Adds two 16-bit numbers and generates a 24-bit number
;		where the high byte of the result contains the carry
;		out bit.
;-----------------------------------------------------------
ADD16:

		; Load beginning address of first operand into X
		ldi		XL, low(ADD16_OP1)	; Load low byte of address
		ldi		XH, high(ADD16_OP1)	; Load high byte of address

		ldi		YL, low(ADD16_OP2); Load beginning address of second operand into Y
		ldi		YH, high(ADD16_OP2)
		
		ldi		ZL, low(ADD16_Result); Load beginning address of result into Z
		ldi		ZH, high(ADD16_Result)
		
		;(A2FF + F477)
		; Execute the function
		ld		A,	X+			; Get low byte of A operand & increment X
		ld		B,	Y+			; Get low byte of B operand	& increment Y
		add		A,	B			; add A and B (lower bytse)
		st		Z+, A			; store result of lower byte addition, and increment Z
		ld		A,	X			; get high byte of A operand
		ld		B,	Y			; get high byte of B operand
		adc		A,	B			; add the high bytes with carry bit
		st		Z+,	A			; store result in the Z register
		brcc	ADDCARRY
		ldi		mpr,	$01
		st		Z,	mpr
ADDCARRY:
		
			
		ret						; End a function with RET

;-----------------------------------------------------------
; Func: SUB16
; Desc: Subtracts two 16-bit numbers and generates a 16-bit
;		result.
;-----------------------------------------------------------
SUB16:

		push 	A				; Save A register
		push	B				; Save B register
		push	rhi				; Save rhi register
		push	rlo				; Save rlo register
		push	zero			; Save zero register
		push	XH				; Save X-ptr
		push	XL
		push	YH				; Save Y-ptr
		push	YL				
		push	ZH				; Save Z-ptr
		push	ZL
		push	oloop			; Save counters
		push	iloop				

	; (calculate F08A - 4BCD)

		; Load beginning address of first operand into X
		ldi		XL, low(SUB16_OP1)	; Load low byte of address
		ldi		XH, high(SUB16_OP1)	; Load high byte of address

		ldi		YL, low(SUB16_OP2); Load beginning address of second operand into Y
		ldi		YH, high(SUB16_OP2)
		
		ldi		ZL, low(SUB16_Result); Load beginning address of result into Z
		ldi		ZH, high(SUB16_Result)
		
		; Execute the function
		ld		A,	X+			; Get low byte of A operand & increment X
		ld		B,	Y+			; Get low byte of B operand	& increment Y
		sub		A,	B			; A <-- A - B (low byte)
		st		Z+, A			; store result of lower byte subtraction, and increment Z
		ld		A,	X			; get high byte of A operand
		ld		B,	Y			; get high byte of B operand
		sbc		A,	B			; subtract B from A again (upper byte)
		st		Z+, A			; store result in the Z register
		brcc	SUBCARRY
		ldi		mpr,	$01
		st		Z,	mpr
SUBCARRY:


		 		
		pop		iloop			; Restore all registers in reverves order
		pop		oloop
		pop		ZL				
		pop		ZH
		pop		YL
		pop		YH
		pop		XL
		pop		XH
		pop		zero
		pop		rlo
		pop		rhi
		pop		B
		pop		A

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: MUL24
; Desc: Multiplies two 24-bit numbers and generates a 48-bit 
;		result.
;-----------------------------------------------------------
MUL24:
		clr		zero			; Maintain zero semantics

		; Set Y to beginning address of B
		ldi		YL, low(MUL24_OP1)	; Load low byte
		ldi		YH, high(MUL24_OP1)	; Load high byte

		; Set Z to begginning address of resulting Product
		ldi		ZL, low(MUL24_Result)	; Load low byte
		ldi		ZH, high(MUL24_Result); Load high byte

		; Begin outer for loop
		ldi		oloop, 3		; Load counter
MUL24_OLOOP:
		; Set X to beginning address of A
		ldi		XL, low(MUL24_OP2)	; Load low byte
		ldi		XH, high(MUL24_OP2)	; Load high byte

		; Begin inner for loop
		ldi		iloop, 3		; Load counter
MUL24_ILOOP:
		ld		A, X+			; Get byte of A operand
		ld		B, Y			; Get byte of B operand
		mul		A, B			; Multiply A and B
		ld		A, Z+			; Get a result byte from memory
		ld		B, Z+			; Get the next result byte from memory

		add		rlo, A			; rlo <= rlo + A
		adc		rhi, B			; rhi <= rhi + B + carry

		ld		A, Z+			; Get a third byte from the result
		ld		B, Z			; Get 4th byte from result

		adc		A, zero			; Add carry to A
		adc		B, zero
		
		st		Z, B			; store 4th byte to memory
		st		-Z, A			; Store third byte to memory
		st		-Z, rhi			; Store second byte to memory
		st		-Z, rlo			; Store third byte to memory

		adiw	ZH:ZL, 1		; Z <= Z + 1
		dec		iloop			; Decrement counter
		brne	MUL24_ILOOP		; Loop if iLoop != 0
		; End inner for loop

		sbiw	ZH:ZL, 2		; Z <= Z - 2
		adiw	YH:YL, 1		; Y <= Y + 1
		dec		oloop			; Decrement counter
		brne	MUL24_OLOOP		; Loop if oLoop != 0
		; End outer for loop

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: COMPOUND
; Desc: Computes the compound expression ((D - E) + F)^2
;		by making use of SUB16, ADD16, and MUL24.
;
;		D, E, and F are declared in program memory, and must
;		be moved into data memory for use as input operands.
;
;		All result bytes should be cleared before beginning.
;-----------------------------------------------------------
COMPOUND:

		push 	A				; Save A register
		push	B				; Save B register
		push	rhi				; Save rhi register
		push	rlo				; Save rlo register
		push	zero			; Save zero register
		push	XH				; Save X-ptr
		push	XL
		push	YH				; Save Y-ptr
		push	YL				
		push	ZH				; Save Z-ptr
		push	ZL
		push	oloop			; Save counters
		push	iloop		


		;  Setup SUB16 with operands D and E
		ldi		XH, high(SUB16_OP1)		; have X point to OP1
		ldi		XL, low(SUB16_OP1)

		ldi		YH, high(SUB16_OP2)		; have Y point to OP2
		ldi		YL, low(SUB16_OP2)

		ldi		mpr, 0x51		; move OperandD into X
		st		X+, mpr
		ldi		mpr, 0xFD
		st		X, mpr

		ldi		mpr, 0xFF		; move OperandE into Y
		st		Y+, mpr
		ldi		mpr, 0x1E
		st		Y, mpr

		rcall SUB16; Perform subtraction to calculate D - E
		
		; Setup the ADD16 function with SUB16 result and operand F
		ldi		XH, high(ADD16_OP1)
		ldi		XL, low(ADD16_OP1)
		
		ldi		YH,	high(ADD16_OP2)
		ldi		YL, low(ADD16_OP2)

		ldi		ZL, low(SUB16_RESULT)	; move result of SUB16 into Z
		ldi		ZH, high(SUB16_RESULT)
		
		ld		mpr, Z+				; move Z into mpr
		st		X+, mpr				; and move mpr into Add operand 1
		ld		mpr, Z
		st		X, mpr


		ldi		mpr, 0xFF		; move OperandF into Add Operand 2
		st		Y+, mpr
		ldi		mpr, 0xFF
		st		Y, mpr

		rcall ADD16			; Perform addition next to calculate (D - E) + F

		; Setup the MUL24 function with ADD16 result as both operands
		ldi		XH, high(MUL24_OP1)
		ldi		XL, low(MUL24_OP1)		; have X point to Mul24 operand 1
		
		ldi		YH,	high(MUL24_OP2)
		ldi		YL, low(MUL24_OP2)		; have Y point to MUL24 operand 2

		; store ADD16_result into Operand1
		ldi		ZL, low(ADD16_RESULT)	;  Have Z point to result of ADD
		ldi		ZH, high(ADD16_RESULT)

		ld		mpr, Z+				; move Z into mpr
		st		X+, mpr				; and move mpr into Add operand 1
		ld		mpr, Z+
		st		X+, mpr
		ld		mpr, Z
		st		X, mpr

		; restore Z
		ldi		ZL, low(ADD16_RESULT)	;  Have Z point to result of ADD
		ldi		ZH, high(ADD16_RESULT)
		; store ADD16_result into Operand 2
		ld		mpr, Z+				; move Z into mpr
		st		Y+, mpr				; and move mpr into Add operand 2
		ld		mpr, Z+
		st		Y+, mpr
		ld		mpr, Z
		st		Y, mpr

		; Perform multiplication to calculate ((D - E) + F)^2
		rcall MUL24


		pop		iloop			; Restore all registers in reverves order
		pop		oloop
		pop		ZL				
		pop		ZH
		pop		YL
		pop		YH
		pop		XL
		pop		XH
		pop		zero
		pop		rlo
		pop		rhi
		pop		B
		pop		A

		ret						; End a function with RET

;-----------------------------------------------------------
; Func: MUL16
; Desc: An example function that multiplies two 16-bit numbers
;			A - Operand A is gathered from address $0101:$0100
;			B - Operand B is gathered from address $0103:$0102
;			Res - Result is stored in address 
;					$0107:$0106:$0105:$0104
;		You will need to make sure that Res is cleared before
;		calling this function.
;-----------------------------------------------------------
MUL16:
		push 	A				; Save A register
		push	B				; Save B register
		push	rhi				; Save rhi register
		push	rlo				; Save rlo register
		push	zero			; Save zero register
		push	XH				; Save X-ptr
		push	XL
		push	YH				; Save Y-ptr
		push	YL				
		push	ZH				; Save Z-ptr
		push	ZL
		push	oloop			; Save counters
		push	iloop				

		clr		zero			; Maintain zero semantics

		; Set Y to beginning address of B
		ldi		YL, low(addrB)	; Load low byte
		ldi		YH, high(addrB)	; Load high byte

		; Set Z to begginning address of resulting Product
		ldi		ZL, low(LAddrP)	; Load low byte
		ldi		ZH, high(LAddrP); Load high byte

		; Begin outer for loop
		ldi		oloop, 2		; Load counter
MUL16_OLOOP:
		; Set X to beginning address of A
		ldi		XL, low(addrA)	; Load low byte
		ldi		XH, high(addrA)	; Load high byte

		; Begin inner for loop
		ldi		iloop, 2		; Load counter
MUL16_ILOOP:
		ld		A, X+			; Get byte of A operand
		ld		B, Y			; Get byte of B operand
		mul		A,B				; Multiply A and B
		ld		A, Z+			; Get a result byte from memory
		ld		B, Z+			; Get the next result byte from memory
		add		rlo, A			; rlo <= rlo + A
		adc		rhi, B			; rhi <= rhi + B + carry
		ld		A, Z			; Get a third byte from the result
		adc		A, zero			; Add carry to A
		st		Z, A			; Store third byte to memory
		st		-Z, rhi			; Store second byte to memory
		st		-Z, rlo			; Store third byte to memory
		adiw	ZH:ZL, 1		; Z <= Z + 1			
		dec		iloop			; Decrement counter
		brne	MUL16_ILOOP		; Loop if iLoop != 0
		; End inner for loop

		sbiw	ZH:ZL, 1		; Z <= Z - 1
		adiw	YH:YL, 1		; Y <= Y + 1
		dec		oloop			; Decrement counter
		brne	MUL16_OLOOP		; Loop if oLoop != 0
		; End outer for loop
		 		
		pop		iloop			; Restore all registers in reverves order
		pop		oloop
		pop		ZL				
		pop		ZH
		pop		YL
		pop		YH
		pop		XL
		pop		XH
		pop		zero
		pop		rlo
		pop		rhi
		pop		B
		pop		A
		ret						; End a function with RET

;-----------------------------------------------------------
; Func: Template function header
; Desc: Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
FUNC:							; Begin a function with a label
		; Save variable by pushing them to the stack

		; Execute the function here
		
		; Restore variable by popping them from the stack in reverse order
		ret						; End a function with RET


;***********************************************************
;*	Stored Program Data
;***********************************************************

; Enter any stored data you might need here

OperandD:
	.DW	0xFD51				; test value for operand D
OperandE:
	.DW	0x1EFF				; test value for operand E
OperandF:
	.DW	0xFFFF				; test value for operand F

;***********************************************************
;*	Data Memory Allocation
;***********************************************************

.dseg
.org	$0100				; data memory allocation for MUL16 example
addrA:	.byte 2
addrB:	.byte 2
LAddrP:	.byte 4

; Below is an example of data memory allocation for ADD16.
; Consider using something similar for SUB16 and MUL24.

.org	$0110				; data memory allocation for operands
ADD16_OP1:
		.byte 2				; allocate two bytes for first operand of ADD16
ADD16_OP2:
		.byte 2				; allocate two bytes for second operand of ADD16

.org	$0120				; data memory allocation for results
ADD16_Result:
		.byte 3				; allocate three bytes for ADD16 result

; Data memory allocation for SUB16

.org	$0130				
SUB16_OP1:
		.byte 2				; allocate two bytes for first operand of SUB16
SUB16_OP2:
		.byte 2				; allocate two bytes for second operand of SUB16

.org	$0140				; data memory allocation for results
SUB16_Result:
		.byte 3				; allocate three bytes for SUB16 result


; Data memory allocation for MUL24

.org	$0150				
MUL24_OP1:
		.byte 3				; allocate three bytes for first operand of MUL24
MUL24_OP2:
		.byte 3				; allocate three bytes for second operand of MUL24

.org	$0160				; data memory allocation for results
MUL24_Result:
		.byte 6				; allocate six bytes for MUL24 result (results up to 48 bits - 6 bytes)

;***********************************************************
;*	Additional Program Includes
;***********************************************************
; There are no additional file includes for this program
