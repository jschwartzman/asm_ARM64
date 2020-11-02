//============================================================================
// cmdline.asm - retrieves cmdline info from the OS and prints it
// John Schwartzman, Forte Systems, Inc.
// 10/18/2020
// Linux ARM64
// as  -g -o cmdline.obj cmdline.asm
// gcc -g cmdline.obj -o cmdline
//============================ CONSTANT DEFINITIONS ==========================
.equ	ONE, 		1				// the number 1
.equ	THREE,		3				// the number 3
.equ	ARG_SIZE, 	8				// size of argv vector for 64-bit
//============================== CODE SECTION ================================
.global	main						// gcc linker expects main, not _start
.extern	printf						// tell assembler/linker about externals
.section	.text

main:								// program starts here
	stp		x20, x21, [sp, #-16]!	// callee saved regs - we're called by C
	stp		x29, x30, [sp, #-16]!	// push fp and lr - boilerplate
	
	mov		x20, x0					// x20 = argc 	   - save argc
	mov		x21, x1					// [x21] => argv[0] - save argv addr vector
									
	bl		printNewLine			// print blank line
									// print argc
	ldr		x0, =formatc			// 1st arg to printf - formatc string
	mov		x1, x20					// 2nd arg to printf - argc
	bl		print					// printf argc

	eor		x29, x29, x29			// x29 = index var i = 0
	
argvLoop:							// print each argv[i] - do-while loop
	ldr		x0, =formatv			// 1st arg to printf - formatv string
	mov		x1, x29					// 2nd arg to printf - index i
	mov		x2, x21					// [x2] => argv[0] 
	add		x2, x2, x29, lsl #THREE	// [x2] => argv[0] + ARG_SIZE * i
	ldr		x2, [x2]				// 3rd arg to printf - [x2] => argv[i]
	bl		print					// print i and argv[i]

	add		x29, x29, #ONE			// i++
	cmp		x29, x20				// i == argc?
	bne		argvLoop				//    jump if no - print more argv[]

	bl		printNewLine			// print blank line
	
	eor		x0, x0, x0				// w0=EXIT_SUCCESS - fall through to finish

finish:								// ==== this is the end of the program ===
	ldp		x29, x30, [sp], #16		// pop fp and lr - boilerplate
	ldp		x20, x21, [sp], #16		// restore callee saved registers
	ret								// return from main with retCode in w0
//============================== LOCAL METHODS ===============================
printNewLine:						// local method (alt entry to print)
	ldr		x0, =newLine			// fall through to print

print:								// [x0] => what to print
	str		x30, [sp, #-16]!		// push lr
	bl		printf					// call within a call - lr must be saved
	ldr		x30, [sp], #16			// pop lr
	ret								// return from print / printNewLine
//=========================== READ-ONLY DATA SECTION =========================
.section	.rodata
formatc:	.asciz  	"argc    = %d\n"
formatv:	.asciz  	"argv[%d] = %s\n"
newLine:	.asciz		"\n"
//============================================================================
