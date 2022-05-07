@ This program is NOT mine, nor do I claim it to be
@ Some modifications were made to work with the specified assignment
@ All rights reserved to Robert Dunne, as it is his code - just repurposed
.global v_flt

v_flt:
	push {R0-R8,LR} @ Save contents of registers R0-R8, LR
	LDR R1,=minus @ Negative sign character "message"
	MOV R2,#1 @ Number of characters in message
	MOVS R6,R0,lsl #1 @ Move sign bit into "C" flag
	BLCS v_asc @ Display the "-" if sigb bit was set
	
	MOV R3,R0,LSL #8 @ Left justify normalized mantissa to R3
	ORR R3,#0x80000000 @ Set the assumed high order bit
	MOV R0,#0 @ Whole part = 0 (Number <0.9999...)
	CMP R6,#0 @ Test if both mantissa and exp = 0
	BEQ disp @ Go display 0.0 if significant and exp = 0
	
	MOV R6,R6,LSR #24 @ Right justify biased exponent
	SUBS R6,#126 @ Remove exponent bits
	BEQ disp @ If exponent = 0, need no shifting
	BLT shiftr @ Values <.5 must be shifted right

	RSB R5,R6,#32 @ Convert left shift to right shift count
	MOV R0,R3,LSR R5 @ Get the whole number portion of the number
	LSL R3,R6 @ Get the fractional part of the number
	B disp @ Go display both whole number and fraction

shiftr:
	RSB R6,R6,#0 @ Calculate positive shift count to right
	LSR R3,R6 @ Divide by 2 for each bit shifted

disp:
	BL getDecVal @ Display the number in R0 in decimal digits
	
	LDR R1,=point @ Pointer to decimal point
	BL v_asc @ Put decimal point into display

	MOV R4,#10 @ Base 10 used to shift over each digit
	LDR R5,=dig @ Set R5 pointing to "0123456789" string
	
nxtdfd:
	UMULL R3,R1,R4,R3 @ Shift next decimal digit into R1
	ADD R1,R5 @ Set pointer to digit in number string
	BL v_asc @ Write out next digit
	CMP R3,#0 @ Set Z flag if mantissa is now zero
	BNE nxtdfd @ Go display next decimal digit
	LDR R1,=newLine @ Load R1 with newline character
	BL v_asc @ Display newline character
	pop {R0-R8,LR} @ Restore saved register contents
	BX LR @ Return to calling program

.data

dig: .ascii "0123456789"
minus: .ascii "-"
point: .ascii "."
newLine: .ascii "\n"
