@ This program was made to factorialize an integer
@ R1 = Integer to factorialize
@ R2 = Our decrementing counter
@ R3 = Final output for use in taylorSeries module

.global factorial

factorial:
	push {R1,R2}
	@MOV R1, #5 @ The number we want to factorialize
	MOV R2,R1 @ Load a copy of our number as a counter into R2
	SUBS R2,#1 @ Subtract one from our counter to begin factorializing

factorialize:
	MUL R1,R1,R2 @ Multiply R1 by R2 and store it in R3
	SUBS R2,#1 @ Subtract one from our counter
	CMP R2,#0 @ Compare R2 to zero
	BNE factorialize
	MOV R3,R1 @ Copy the value of R1 into R3 for use in our taylorSeries module
	VMOV S4,R3
	VCVT.f32.s32 S4,S4
	pop {R1,R2}
	BX LR @ Branch back to main program if equal to zero
