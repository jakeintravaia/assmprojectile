@ R0 = Test data buffer
@ R1 = Character pointer
@ R2 = Current character
@ R3 = Number length
@ R4 = Plane altitude
@ R5 = Plane speed
@ R6 = Angle of plane relative to target
@ R7 = Number count
@ R8 = Converted decimal number
.global getInput

getInput:
	PUSH {R1-R3} @ Push R0-R3 onto the stack
	MOV R9,LR @ Save our link to our main file in R9
	@LDR R0,=tstData @ Load R0 with our test data
	MOV R1,#0 @ Set our character pointer to zero

start:
	ADD R7,#1 @ Add one to our number count so we know when to end
	MOV R3,#0 @ Set our number length to zero

getPos:
	LDRB R2,[R0,R1] @ Get next character
	CMP R2,#0x3A @ Check if our character is a colon
	BEQ skipSpace @ If so, get our number
	ADD R1,#1 @ Add one to our character pointer
	B getPos @ Repeat until we break the loop

skipSpace:
	ADD R1,#2 @ Skip the space

getLen:
	LDRB R2,[R0,R1] @ Get next character
	CMP R2,#0x20 @ Check if our character is a space
	BEQ getNxt @ If equal, branch to our getNxt subroutine
	ADD R1,#1 @ Add one to our character pointer
	ADD R3,#1 @ If not, add one to our number length
	B getLen @ Repeat until we break the loop

getNxt:
	BL getNum @ Branch and link to our getNum module
	CMP R7,#1 @ Check if we're on our first number
	BEQ firstNum @ Branch to our firstNum subroutine if so
	CMP R7,#2 @ Check if we're on our second number
	BEQ secondNum @ Branch to our secondNum subroutine if so
	CMP R7,#3 @ Check if we're on our third number
	BEQ thirdNum @ Branch to our thirdNum subroutine if so

firstNum:
	MOV R6,R8 @ Move R8 into R6
	B start

secondNum:
	MOV R4,R8 @ Move R8 into R6
	B start

thirdNum:
	MOV R5,R8 @ Move R8 into R7

end:
	POP {R0-R3} @ Pop R0-R3 off the stack
	BX R9 @ Branch and link to our main program

.data

.align 4

tstData: .asciz "UPDATE A1: 30 DEGREES, Y: 100 METERS, VX: 10 M/S"
