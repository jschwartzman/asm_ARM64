//============================================================================
// gpiotest.asm - Count from 0 - 9 on a 7-segment common anode display
// John Schwartzman, Forte Systems, Inc.
// 02/26/2020
// ARM64
// gpiotest must be assembled to gpiotest.obj and linked with iomap.obj
//============================ CONSTANT DEFINITIONS ==========================
.equ	setregoffset, 28
.equ	clrregoffset, 40
.equ	gpiolev0, 	  0x34
.equ	ZERO,		   0
.equ	ONE, 		   1
.equ	FOUR,		   4
.equ	EIGHT,		   8
.equ	CLEAR_MASK,	  0b111
.equ	LOW,		  ZERO
.equ	HIGH,		  ONE
.equ	COUNT_UP,	  0
.equ	COUNT_DOWN,   1
.equ	SHUT_DOWN,    2
//================================= MACROS ===================================
.macro	zeroReg		reg
	eor		\reg, \reg, \reg
.endm

.macro	decReg	reg
	subs	\reg, \reg, #1
.endm

.macro	incReg	reg
	add		\reg, \reg, #1
.endm

.macro	nanoSleep
	ldr		x0, =timespecsec
	ldr		x1, =timespecsec
	bl		nanosleep
.endm

.macro	GPIODirectionIn	pin			// x29 = [gpiobase]
	ldr		x2, =\pin				// offset of select registser
	ldr		w2, [x2]				// load the offset to GPFSELn
	ldr		w1, [x29, x2]			// addr of register - w1 = beg content
	ldr		x3, =\pin				// addr of pin table
	add		x3, x3, #FOUR			// load amount to shift from table
	ldr		w3, [x3]				// load value of shift amount
	mov		w0,	#CLEAR_MASK			// mask to clear 3 bits
	lsl		w0, w0, w3				// shift into position
	bic		w1, w1, w0				// clear the 3 bits
	str		w1, [x29, x2]			// save it to reg 
.endm

.macro	GPIODirectionOut	pin		// x29 = [gpiobase]
	ldr		x2, =\pin				// offset of select registser
	ldr		w2, [x2]				// load the offset to GPFSELn
	ldr		w1, [x29, x2]			// addr of register - w1 = beg content
	ldr		x3, =\pin				// addr of pin table
	add		x3, x3, #FOUR			// load amount to shift from table
	ldr		w3, [x3]				// load value of shift amount
	mov		w0,	#CLEAR_MASK			// mask to clear 3 bits
	lsl		w0, w0, w3				// shift into position
	bic		w1, w1, w0				// clear the 3 bits
	mov		w0, #ONE				// 1 bit to shift into position
	lsl		w0, w0, w3				// shift by amount from table
	orr		w1, w1, w0				// set the bit
	str		w1, [x29, x2]			// save it to reg 
.endm

.macro	GPIOSetState	pin, state
	mov 	x2, x29					// addr of gpio regs
	.if	\state == HIGH				// offset to set reg
		add		x2, x2, #setregoffset	
	.elseif \state == LOW			// offset to clr reg
		add		x2, x2, #clrregoffset
	.else
		.error						// catch invalid state 
	.endif
	mov		w0, #ONE				// 1 bit to shift into position
	ldr		x3, =\pin				// base of pin info table
	add		x3, x3, #EIGHT			// add offset for shift amount
	ldr		w3, [x3]				// load shift from table
	lsl		w0, w0, w3				// do the shift
	str		w0, [x2]				// write to the register
.endm

.macro	GPIOReadPin		pin
	mov		x2, x29					// address of gpio regs
	add		x2, x2, #gpiolev0
	ldr		w2, [x2]				// x2 = contents of gpiolev0
	ldr		x3, =\pin				// base of pin info table
	add		x3, x3, #EIGHT			// add offset for shift amount
	ldr		w3, [x3]				// load shift from table
	mov		w0, #ONE				// 1 bit to shift into position
	lsl		w0, w0, w3				// do the shift
	ands	w0, w2, w0				// Z flag will be set if pin was low	 
.endm	

// Because we are using a common adode display, 
// LOW turns on a segment
// and HIGH turns off a segment.

.macro	write_0
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, LOW		// d
	GPIOSetState pin06, LOW		// e
	GPIOSetState pin16, LOW		// f
	GPIOSetState pin12, HIGH	// g
	nanoSleep
	GPIOReadPin	pin26
.endm
	
.macro	write_1	
	GPIOSetState pin20, HIGH	// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, HIGH	// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, HIGH	// f
	GPIOSetState pin12, HIGH	// g
	nanoSleep
	GPIOReadPin	pin26
.endm

.macro	write_2	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, HIGH	// c
	GPIOSetState pin13, LOW		// d
	GPIOSetState pin06, LOW		// e
	GPIOSetState pin16, HIGH	// f
	GPIOSetState pin12,	LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm

.macro	write_3	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, LOW		// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, HIGH	// f
	GPIOSetState pin12, LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm

.macro	write_4	
	GPIOSetState pin20, HIGH	// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, HIGH	// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, LOW		// f
	GPIOSetState pin12, LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm
	
.macro	write_5	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, HIGH	// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, LOW		// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, LOW		// f
	GPIOSetState pin12, LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm
	
.macro	write_6	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, HIGH	// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, LOW		// d
	GPIOSetState pin06, LOW		// e
	GPIOSetState pin16, LOW		// f
	GPIOSetState pin12, LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm
	
.macro	write_7	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, HIGH	// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, HIGH	// f
	GPIOSetState pin12, HIGH	// g
	nanoSleep
	GPIOReadPin	pin26
.endm
	
.macro	write_8	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, LOW		// d
	GPIOSetState pin06, LOW		// e
	GPIOSetState pin16, LOW		// f
	GPIOSetState pin12, LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm
	
.macro	write_9	
	GPIOSetState pin20, LOW		// a
	GPIOSetState pin21, LOW		// b
	GPIOSetState pin19, LOW		// c
	GPIOSetState pin13, HIGH	// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, LOW		// f
	GPIOSetState pin12, LOW		// g
	nanoSleep
	GPIOReadPin	pin26
.endm

.macro clearNum
	GPIOSetState pin20, HIGH	// a
	GPIOSetState pin21, HIGH	// b
	GPIOSetState pin19, HIGH	// c
	GPIOSetState pin13, HIGH	// d
	GPIOSetState pin06, HIGH	// e
	GPIOSetState pin16, HIGH	// f
	GPIOSetState pin12, HIGH	// g
	GPIOSetState pin26, HIGH	// db
.endm

//============================== CODE SECTION ================================
.text
.global	initialize, countUp, countDown, cleanUp	
.extern mapOpen, mapClose, nanosleep 	// tell assembler/linker about externals
.align 4

//----------------------------------------------------------------------------
initialize:								// program starts here
	stp		x29, x30, [sp, #-16]!		// push fp and lr

	bl		mapOpen						// map the memory
	cmp		w0, #ZERO					// success?
	bne		fin							// branch if no

	adr		x29, gpiobase
	ldr		x29, [x29]

	GPIODirectionIn	  pin17				// input pin used for switch input
	GPIODirectionOut  pin20				// segment a
    GPIODirectionOut  pin21				// segment b
    GPIODirectionOut  pin22				// segment b
    GPIODirectionOut  pin19				// segment c
    GPIODirectionOut  pin13				// segment d
    GPIODirectionOut  pin06				// segment e
    GPIODirectionOut  pin16				// segment f
    GPIODirectionOut  pin12				// segment g
    GPIODirectionOut  pin26				// segment dp
	clearNum 							// seting direction leaves the pins LOW

fin:
	ldp		x29, x30, [sp], #16			// pop fb and lr
	ret
//----------------------------------------------------------------------------

countUp:
	stp		x29, x30, [sp, #-16]!		// push fp and lr

	adr		x29, gpiobase
	ldr		x29, [x29]					// x29 = gpiobase

countUpTop:
	write_0
	beq		endCountUp

	write_1
	beq		endCountUp

	write_2
	beq		endCountUp

	write_3
	beq		endCountUp

	write_4
	beq		endCountUp

	write_5
	beq		endCountUp

	write_6
	beq		endCountUp

	write_7
	beq		endCountUp

	write_8
	beq		endCountUp

	write_9
	bne		countUpTop

endCountUp:
	clearNum
	ldp		x29, x30, [sp], #16		// pop fb and lr
	ret
//----------------------------------------------------------------------------

countDown:
	stp		x29, x30, [sp, #-16]!	// push fp and lr

	adr		x29, gpiobase
	ldr		x29, [x29]				// x29 = gpiobase

countDownTop:
	write_9
	beq		endCountDown

	write_8
	beq		endCountDown

	write_7
	beq		endCountDown

	write_6
	beq		endCountDown

	write_5
	beq		endCountDown

	write_4
	beq		endCountDown

	write_3
	beq		endCountDown

	write_2
	beq		endCountDown

	write_1
	beq		endCountDown

	write_0
	bne		countDownTop

endCountDown:
	clearNum
	ldp		x29, x30, [sp], #16		// pop fb and lr
	ret
//----------------------------------------------------------------------------

cleanUp:	
	stp		x29, x30, [sp, #-16]!	// push fp and lr - save lr - using bl 
	bl		mapClose				// unmap the memory
 	zeroReg	w0						// Use 0 return code
	ldp		x29, x30, [sp], #16		// pop fb and lr
	ret

//====================== READ-ONLY DATA SECTION ==========================
.section	.rodata
.align 4
timespecsec:	.dword	1	// 0
timespecnano:	.dword	0	// 500000000

// 7-segment display look up table
pin06:	.word	 0					// seg e - ofset to select register
		.word	18					// bit offset in select reg
		.word	 6					// bit offset in set & clr reg
pin12:	.word	 4					// seg g	- offset to reg
		.word	 6					//			- pins 6 - 8
		.word	12					//			- pin number
pin13:	.word	 4					// seg d
		.word	 9
		.word	13
pin16:	.word	 4					// seg f
		.word	18
		.word	16
pin17:	.word	 4					// switch input - ofset to select reg
		.word   21					// bit offset in select reg
		.word	17					// bit offset in set & clr reg
pin19:	.word	 4					// seg c
		.word	27
		.word	19
pin20:	.word	 8					// seg a
		.word    0
		.word	20
pin21:	.word 	 8					// seg b
		.word	 3
		.word	21
pin22:	.word	 8					// seg a - offset to select register
		.word    6					// bit offset in select reg
		.word	22					// bit offset in set & clr reg
pin26:	.word	 8					// seg dp -ofset to select register
		.word   18					// bit offset in select reg
		.word	26					// bit offset in set & clr reg

//========================= READ-WRITE DATA SECTION ==========================
.section	.data
.align 4
//============================================================================
