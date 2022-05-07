@ This program is simply meant to output ascii values to our screen
.global v_asc

v_asc:
	MOV R0,#1 @ Code for stdout
	MOV R7,#4 @ Linux service command to write string
	SVC 0 @ Issue command to display
	BX LR @ Branch back to main program
