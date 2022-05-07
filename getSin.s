@ This program was made to approximate sin(x) by using a taylorSeries equation
@ R0 = Not used
@ R1 = Taylor series number (3, 5, 7)
@ R2 = Sign bit (controls whether we subtract or add)
@ R3 = Our factorial
@ R4 = Our taylor series precision (how many times we repeat the series)
@ R5 = -1
@ R6 = Copy of original taylor series value so we can increment
@ S0 = Original radian value
@ S1 = Copy of radian value for manipulation
@ S2 = Holds our division value (x^n/x!)
@ S3 = Holds our final value
@ S4 = Holds our current factorial value

.global getSin

.fpu neon-fp-armv8

getSin:
	push {R0-R6} @ Push our in-use registers onto the stack as not to lose their values
	vpush {S4}
	MOV R7,LR @ Load our link register into R7 for later branching back to prog10.s
	MOV R1,#3 @ Load our first taylor series number into R1
	MOV R6,R1 @ Copy our first taylor series number into R6
	MOV R2,#1 @ Our sign bit -1 is negative 1 is positive (duh)
	MOV R4,#6 @ Our taylor series precision
	MOV R5,#-1 @ Negative one to change our sign bit
	@LDR R0,=radVal
	@VLDR S0,[R0]
	VMOV S3,S0 @ Copy our original radian value into S3 for manipulation
start:
	MOV R1,R6 @ Move taylor series value into R1
	BL factorial @ Branch and link to our factorial module
	@LDR R0,=radVal
	@VLDR S0,[R0]
	VMOV S1,S0 @ Copy our original radian value into S1 for manipulation
	@VMOV S3,S0 @ Copy our original radian value into S3 for manipulation

getPower:
	VMUL.f32 S1,S1,S0 @ Multiply S1 by itself and save value into S1
	SUBS R1,#1 @ Subtract 1 from our number counter
	CMP R1, #1 @ Check if R1 is one
	BNE getPower @ If R1 is not one, continue multiplying our number by itself

divide:
	VDIV.f32 S2,S1,S4 @ Divide S1 by S4 and store in S2 (x/x^n)

addOrSub:
	MUL R2,R2,R5 @ Multiply R2 by -1 to switch modes
	CMP R2,#0 @ Compare R2 to zero
	BLT subtract
	BGT add

subtract:
	VSUB.f32 S3,S2 @ Subtract S2 from S3 and store it in S3
	B repeat @ Unconditional branch to repeat subroutine
add:
	VADD.f32 S3,S2 @ Add S2 to S3 and store it in S3
	B repeat @ Unconditional branch to repeat subroutine

repeat:
	ADD R6,#2 @ Add two to our taylor series number
	SUB R4,#1 @ Subtract one from our precision counter
	CMP R4,#0 @ Compare R4 to zero
	BGT start
end:
	vpop {S4}
	pop {R0-R6} @ Pop our registers off the stack
	BX R7 @ Branch and link back to our main program
	@MOV R0,#0
	@MOV R7,#1
	@SVC 0
.data

.align 4

radVal: .single 6.28319
