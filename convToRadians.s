@ This file was made to convert a degree value provided from prog8.s into a radian value
@ R1 = PI value pointer
@ R2 = Degree value pointer
@ S0 = User input (degree) and final radian value
@ S1 = PI
@ S2 = 180

.global convert

.fpu neon-fp-armv8

convert:
	LDR R1,=pi @ Load pointer to PI value into R1
	LDR R2,=deg @ Load pointer to our degree value into R2
	VLDR S1,[R1] @ Load PI into S1
	VLDR S2,[R2] @ Load 180 into S2
	VMUL.f32 S0,S1 @ Multiply user input angle by pi
	VDIV.f32 S0,S0,S2 @ Divide our product by 180 to get final radian value
	BX LR @ Return back to our main program
.data

.align 4

input: .single 90
pi: .single 3.14159265
deg: .single 180
