@ This file was created to get the total time of our projectile fall and store it in S6
@ R0 = Gravity value pointer
@ S0 = Value of 2 to multiply by
@ S1 = Gravity value
@ S4 = Plane altitude
@ S6 = Final time

.global getTime

.fpu neon-fp-armv8

getTime:
	PUSH {R0}
	VPUSH {S0-S5} @ Push our registers onto the stack
	@MOV R1,#100 @ Test altitude
	@VMOV S4,R1 @ Load S4 with test altitude
	@VCVT.f32.s32 S4,S4
	VMOV S0,#2 @ Load 2 into S0
	VMUL.f32 S6,S4,S0 @ Multiply Plane altitude by 2
	LDR R0,=gravity @ Load R0 with our gravity value
	VLDR S1,[R0] @ Load S1 with gravity value
	VDIV.f32 S6,S6,S1 @ Divide S6 by gravity value
	VSQRT.f32 S6,S6 @ Get sqrt of S6

end:
	VPOP {S0-S5}
	POP {R0}
	BX LR @ Branch back to main program
.data

gravity: .single 9.81
