@ This program is meant to convert a binary value in a register to a decimal value and then print it
@ Most of this program is derived from Robert Dunnes' textbook - it is not mine nor do I claim it to be
@ The program is slightly edited down for practical use with this specific program assignment

.global getDecVal

getDecVal:
	push {R0-R7} @ Save contents of registers R0 through R7
	mov R3,R0 @ Copy R0 value into R3
	mov R2,#1 @ Number of characters to be displayed
	mov R0,#1 @ Code for stdout
	mov R7,#4 @ Linux service command code to write string
	cmp R3,#0 @ Check if R3 is negative
	bge absval @ If not, jump to absval

absval:
	cmp R3,#10 @ Check if sum is only 1 digit
	blt onecol @ Go output final column of display
	ldr R6,=pow10+8 @ Point to hundreds column of power of ten table

high10:
	ldr R5,[R6],#4 @ Load next power of ten
	cmp R3, R5 @ Test if we've reached the highest power of ten needed
	bge high10 @ Continue to search for power of ten that is greater
	sub R6,#8 @ We stepped two integers too far

nxtdec: ldr R1,=dig-1 @ Point to 1 byte before "0123456789" string
	ldr R5,[R6],#-4 @ Load next lower power of 10

mod10:
	add R1,#1 @ Set R1 pointing to the next digit
	subs R3,R5 @ Do a count down to find the correct digit
	bge mod10 @ Keep subtracting current decimal column value
	addlt R3,R5 @ We counted one too many (went negative)
	svc 0 @ Write the next digit to display
	cmp R5,#10 @ Test if we've gone all the way to the one's column
	bgt nxtdec @ If 1's column, go output rightmost digit and return

onecol:
	ldr R1,=dig @ Pointer to "0123456789"
	add R1,R3 @ Generate offset into "0123456789" for one's digit
	svc 0 @ Write out final digit
	pop {R0-R7}
	bx LR

.data

pow10:
	.word 1
	.word 10
	.word 100
	.word 1000
	.word 10000
	.word 100000
	.word 1000000
	.word 10000000

dig: .ascii "0123456789"
newline: .ascii "\n"

.end
