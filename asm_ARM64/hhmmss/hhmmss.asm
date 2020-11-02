//============================================================================
// hhmmss.asm
// John Schwartzman, Forte Systems, Inc.
// 05/25/2020
// Linux ARM64
// Useful utility for converting elapsed time in seconds into HH:MM:SS
// Build without defining __MAIN__ if you wish to link into another program.
//============================ CONSTANT DEFINITIONS ==========================
.equ		ONE,		  1         // number 1
.equ		ZERO,         0         // number 0
.equ		TEN,	     10         // number 10
.equ		SIXTY,       60         // number 60
.equ		ZERO_CHAR, 	 48			// '0'
.equ		COLON_CHAR,	 58			// ':'
.equ		BUFF_SIZE,   32
//============================================================================

.section	.text					//============= CODE SECTION =============

.ifndef DEF           				//========== BUILD WITHOUT MAIN ==========

	.global      toHHMMSS           // tell linker about export

.else                               //=========== BUILD WITH MAIN ============	

.global      main                   // tell linker about exports
.extern      printf, scanf          // tell assembler/linker about externals

//============================== MAIN FUNCTION ===============================
main:
	stp		x29, x30, [sp, #-16]!	// push fp and lr - boilerplate

	ldr     x0, =promptFormat	    // 1st (and only) arg to printf
	bl 		printf                  // prompt user

	ldr     x0, =scanfFormat	    // 1st arg to scanf
	ldr     x1, =x                	// 2nd arg to scanf
	bl    	scanf                   // get x

	ldr     x0, =x	                // x is the long we want in hh:mm:ss fmt
	ldr     x0, [x0]                // x is the total number of seconds
	bl	    toHHMMSS                // return pointer to outputBuf in x0
	bl    	printf
	ldr     x0, =outputFormat
	bl    	printf                 	// write 2 line feeds

	ldp		x29, x30, [sp], #16		// pop fp and lr - boilerplate
	ret

.endif  //==================== BUILD WITHOUT MAIN ============================     

//============================= EXPORTED FUNCTION ============================
toHHMMSS:                           // param x0 = long int (number of seconds)
	stp		x29, x30, [sp, #-16]!	// push fp and lr - boilerplate
	ldr     x18, =outputBuf        	// x18 => destination buffer
	mov		x4, x0					// save param

	mov     x2, #(SIXTY * SIXTY)	// * hours *
	udiv    x0, x4, x2              // get num hours in x0
	mov		x3, x0					// save num hours in x3
	bl		writeTwoDigits
	bl		writeColon

	mul		x0, x3, x2				// num hours in seconds
	sub		x4, x4, x0				// x4 = param - hours

	mov		x2, #SIXTY				// * minutes *
	udiv	x0, x4, x2				// get num minutes in x3
	mov		x3, x0					// save num minutes in x3
	bl 		writeTwoDigits
	bl		writeColon

	mul		x0, x3, x2				// * seconds *
	sub		x0, x4, x0				// x0 = remaining number of seconds
	bl		writeTwoDigits
	bl		writeEOL

	ldr     x0, =outputBuf        	// return pointer to outputBuf in x0

	ldp		x29, x30, [sp], #16		// pop fp and lr - boilerplate
	ret
//============================= LOCAL FUNCTION ===============================
writeTwoDigits:                   	// param: x0 = any int from 0 to 99
	stp		x29, x30, [sp, #-16]!	// push fp and lr - boilerplate
	mov		x7, x2					// preserves x2, destroys x1
	mov		x2, x0                  // save parameter

	mov     x1, #TEN                // * tens *
	udiv    x0, x0, x1              // x0 = number of tens
	bl      writeDigit              // write tens (x0 is preserved)

									// * ones *
	mul     x0, x0, x1             	// x0 = 10 * number of tens
	sub     x0, x2, x0              // x0 = param - 10 * num tens

	bl      writeDigit				// write ones
	mov		x2, x7
	ldp		x29, x30, [sp], #16		// pop fp and lr - boilerplate
	ret
//============================= LOCAL FUNCTION ===============================
writeColon:							// destroys x0
	mov     x0, #COLON_CHAR
	strb	w0, [x18], #ONE			// write to outputBuf and inc outputBuf
	ret
//============================= LOCAL FUNCTION ===============================
writeDigit:                         // x0 (0-9) -- preserves x0
	mov		x6, x0 
	add     w0, w0, #ZERO_CHAR      // convert to char
	strb	w0, [x18], #ONE			// write to outputBuf and inc outputBuf
	mov		x0, x6
	ret
//============================= LOCAL FUNCTION ===============================
writeEOL:
	mov     w0, #ZERO
	strb	w0, [x18]				// write EOL to outputBuf
	ret
//==============================  DATA SECTION ===============================
.section     .data
x:		.word     0
//========================== UNINITIALIZED DATA SECTION ======================
.section		.bss
outputBuf:	.space	BUFF_SIZE
//========================= READ-ONLY DATA SECTION ===========================
.section 	.rodata	
scanfFormat:	.asciz		"%lu"
promptFormat:   .asciz      "Enter an integer >= 0: "
outputFormat:   .asciz      "\n\n"
//============================================================================
