@ R0 = Our buffer
@ R1 = Our number pointer
@ R2 = Our current selected digit
@ R3 = Our number length
@ R6 = Our multiplier
@ R8 = Final output
.global getNum

getNum:
	PUSH {R0-R7} @ Push R0-R7 onto stack
	MOV R8,#0 @ Set R8 to zero
	SUB R1,R3 @ Reset our pointer to the first character of our number
	CMP R3,#3 @ Check if our num length is 3
	BEQ tripleDigit @ If so, branch to our three digit subroutine
	CMP R3,#2 @ Check if our num length is 2
	BEQ doubleDigit @ If so, branch to our two digit subroutine
	CMP R3,#1 @ Check if our num length is 1
	BEQ singleDigit @ If so, branch to our single digit subroutine

singleDigit:
	LDRB R2,[R0,R1] @ Select our first digit
	SUB R2,#0x30 @ Subtract 30 to get our decimal value
	MOV R8,R2 @ Move final value into R5
	B end @ Unconditionally branch to end

doubleDigit:
	LDRB R2,[R0,R1] @ Select our first digit
	SUB R2,#0x30 @ Subtract 30 to get decimal value
	MOV R6,#10 @ Load R6 with our mulitplier value
	MUL R2,R6 @ Multiply our first digit by 10
	ADD R8,R2 @ Add to our final value
	ADD R1,#1 @ Add one to our digit pointer
	LDRB R2,[R0,R1] @ Select our next digit
	SUB R2,#0x30 @ Subtract 30 to get decimal value
	ADD R8,R2 @ Add to our final value
	B end @ Unconditionally branch to end

tripleDigit:
	LDRB R2,[R0,R1] @ Select our first digit
	SUB R2,#0x30 @ Subtract 30 to get decimal value
	MOV R6,#100 @ Set our multiplier to 100
	MUL R2,R6 @ Multiply R2 by 100
	ADD R8,R2 @ Add R2 to our final value
	ADD R1,#1 @ Add one to our digit pointer
	LDRB R2,[R0,R1] @ Select our next digit
	SUB R2,#0x30 @ Subtract 30 to get decimal value
	MOV R6,#10 @ Set our multiplier to 10
	MUL R2,R6 @ Multiply R2 by 10
	ADD R8,R2 @ Add R2 to final value
	ADD R1,#1 @ Add one to our digit pointer
	LDRB R2,[R0,R1] @ Select our next digit
	SUB R2,#0x30 @ Subtract 30 to get decimal value
	ADD R8,R2 @ Add R2 to final value

end:
	POP {R0-R7} @ Pop R0-R7 off the stack
	BX LR @ Branch and link back to main program
