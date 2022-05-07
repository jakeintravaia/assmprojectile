@ R0 = Prompt loader
@ R1 = Buffer loader
@ R4 = Plane altitude
@ R5 = Plane speed
@ R6 = Angle of plane relative to target
@ R10 = Program mode
@ S0 = Fixed angle (in radians)
@ S3 = SIN or COS of our fixed angle (depending where you are in the program)
@ S4 = Distance to target (hypotenuse)
@ S5 = X distance to target
@ S6 = Time of flight
@ S7 = X prime (m)

.global main

@ Main handles the printing of our prompts and our command input

main:
	MOV R10,#0 @ Set our mode to zero

parseCmd:
@ Flush all of our GPR values for next program run
	MOV R0,#0
	MOV R1,#0
	MOV R2,#0
	MOV R3,#0
	MOV R4,#0
	MOV R5,#0
	MOV R6,#0
	MOV R7,#0
	MOV R8,#0
	LDR R0,=prmpt @ Load R0 with our prompt
	BL printf @ Branch and link to C std library puts
	LDR R0,=buff @ Load R0 with our buffer
	BL gets @ Branch and link to C std library gets
	LDR R0,=buff @ Load R0 with our buffer
	LDR R0,[R0] @ Load R0 with our input
	LDR R1,=nrml @ Load R1 with normal command buffer
	LDR R1,[R1] @ Load R1 with normal command
	CMP R0,R1 @ Compare our input to our command
	BEQ normal @ If equal, branch to normal mode
	LDR R1,=tst @ Load R1 with our test command buffer
	LDR R1,[R1] @ Load R1 with our test command
	CMP R0,R1 @ Compare our input to our command
	BEQ test @ If equal, branch to test mode
	LDR R1,=quit @ Load R1 with our quit command buffer
	LDR R1,[R1] @ Load R1 with our quit command
	CMP R0,R1 @ Compare our input to our command
	BEQ end @ If equal, branch to end
	LDR R1,=hlp @ Load R1 with our help command buffer
	LDR R1,[R1] @ Load R1 with our help command
	CMP R0,R1 @ Compare our input to our command
	BEQ helpMode @ If equal, branch to help mode
	LDR R1,=update @ Load R1 with pointer to our update command buffer
        LDR R1,[R1] @ Load R1 with update command
        CMP R0,R1 @ Compare our input to UPDATE command
	BEQ updateVals @ If equal, branch to updateVals
	B err @ If no branch is taken, assume error in input

@ Handles our normal mode

normal:
	MOV R10,#0 @ Change our program mode to normal
	LDR R0,=nrmlPrmpt @ Load R0 with our normal mode prompt
	BL puts @ Branch and link to C std library puts function
	LDR R0,=tstData @ Load R0 with our test data
	BL getInput @ Branch and link to our getInput module
	B fixAngle @ Unconditional branch to fixAngle

@ Handles our test mode

test:
	MOV R10,#1 @ Change our program mode to test
	LDR R0,=tstPrmpt @ Load R0 with our test mode prompt
	BL puts @ Branch and link to C std library puts function
	B parseCmd @ Unconditional branch to parseCmd

@ Handles updating our values

updateVals:
	CMP R10,#1 @ Check if we are in test mode
	BNE err @ If not, branch to our error handler
	LDR R0,=buff @ Load R0 with our buffer for use in our getInput module
        BL getInput @ Branch and link to our getInput module
	B fixAngle @ Unconditional branch to fixAngle

@ Handles our help mode

helpMode:
	LDR R0,=helpPage @ Load R0 with our help page
	BL puts @ Branch and link to C std library puts function
	B parseCmd @ Unconditionally branch back to main

@ Our error handler

err:
	LDR R0,=errPrmpt @ Load R0 with error prompt
	BL puts @ Branch and link to C std library puts function
	CMP R10,#1 @ Check if we are in test or normal mode
	BEQ test @ Branch to test if we are in test mode
	B parseCmd @ Unconditional branch to main otherwise

@ Fix angle subroutine fixes our angle input

fixAngle:
	SUBS R6,#90 @ Subtract 90 from our given angle to get our real angle

@ Convert our angle to radians for use in SIN conversion, as we will need to use it later on

convRad:
	VMOV S0,R6 @ Load the value of R6 into S0 
	VCVT.f32.s32 S0,S0 @ Convert S0 into correct format for use in our conversion program
	BL convert @ Convert our angle to radians

@ Gets distance to our target

getDist:
	BL getCos @ Get the cosine of our angle and store it into S3
	VMOV S4,R4 @ Load the value of R4 into S4
	VCVT.f32.s32 S4,S4 @ Convert integer value to single precision float
	VDIV.f32 S4,S4,S3 @ Divide our altitude by the cosine of our angle and store it in S4

@ Gets x distance to target

getXdist:
	BL getSin @ Get the sin value of our angle and store it into S3
	VMUL.f32 S5,S4,S3 @ Multiply our distance by the sin value of our angle to get x distance

@ Gets total drop time

getFlightTime:
	VMOV S4,R4 @ Load the value of our altitude into S4
	VCVT.f32.s32 S4,S4 @ Convert integer value into single precision float
	BL getTime @ Branch and link to our getTime module and stores our time into S6

@ Get x prime distance

getXPrime:
	VMOV S4,R5 @ Load our speed into S4
	VCVT.f32.s32 S4,S4 @ Convert integer value into single precision float
	VMUL.f32 S7,S4,S6 @ Multiply our time by our speed and store in S7

@ Get our final drop time

getDropTime:
	MOV R7,#-1 @ Move -1 into R7 to store in S0
	VMOV S0,R7 @ Store R7 in S0
	VCVT.f32.s32 S0,S0 @ Convert integer to single precision float
	@MOV R8,#0 @ Move zero into R8 to store in S1
	@VMOV S1,R8 @ Store R8 in S1
	@VCVT.f32.s32 S1,S1 @ Convert integer to single precision float
	@VCMP.f32 S5,S1 @ Compare S5 to zero
	VMUL.f32 S5,S0 @ Multiply S5 by -1 to convert it to a positive number
	VSUB.f32 S8,S5,S7 @ Subtract our x distance by x prime and store in S8
	VDIV.f32 S8,S8,S4 @ Divide our x - x_prime by speed for final answer
	VMOV S9,S8 @ Move S8 into S9 for negative check
	VCVT.s32.f32 S9,S9 @ Convert S9 into integer for use in GPRs
	VMOV R8,S9 @ Move S9 into R8
	CMP R8,#0 @ Compare R8 to zero to check if our drop time is negative
	BLT printAbort @ Branch to printAbort if less than zero

printSolution:
	LDR R0,=dropOp @ Load R0 with our drop solution output
	BL printf @ Branch and link to c std library printf
	VMOV R0,S8 @ Move S8 into R0 for printout
	BL v_flt @ Branch and link to our v_flt module
	LDR R0,=postfix @ Load R0 with our postfix
	BL printf @ Branch and link to c std library printf
        B main @ Unconditional branch to main otherwise

printAbort:
	LDR R0,=abort @ Load R0 with our abort output
	BL printf @ Branch and link to c std library printf
        B main @ Unconditional branch to main otherwise

end:
	MOV R0,#0 @ Service code for normal execution
	MOV R7,#1 @ Linux service call for terminating a program
	SVC 0 @ Terminate program

.data

.align 4

fmtIn: .string "%d"
buff: .space 100
prmpt: .asciz "STARK INDUSTRIES> "
nrmlPrmpt: .asciz "\n====================\nMODE SET TO NORMAL\n====================\n"
tstPrmpt: .asciz "\n====================\nMODE SET TO TEST\n====================\n"
errPrmpt: .asciz "ERROR: UNKNOWN COMMAND"
nrml: .asciz "NORMAL"
tst: .asciz "TEST"
update: .asciz "UPDATE"
quit: .asciz "QUIT"
hlp: .asciz "HELP"
helpPage: .asciz "\n====================\nHELP PAGE 1/1 \n====================\nHELP => Displays this help page\nNORMAL => Changes program mode to normal\nTEST => Changes program mode to test\nUPDATE A1: XXX DEGREES, Y: XXX METERS, VX: XXX M/S => Updates test values for weapons system\nQUIT => Terminates program\n====================\n"
dropOp: .asciz "SOLUTION: DROP IN\n"
postfix: .asciz "SECONDS\n"
abort: .asciz "SOLUTION: ABORT\n"
tstData: .asciz "UPDATE A1: 30 DEGREES, Y: 100 METERS, VX: 10 M/S"
