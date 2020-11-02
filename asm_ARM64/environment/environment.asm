//============================================================================
// environment.asm - demonstrates invoking getenv, printf and strncpy 
// environment.asm is called by environment.c (environment.c has main())
// environment.asm does not have a main. It exports the function with the 
// declaration: int printenv(const char* dateStr);
// John Schwartzman, Forte Systems, Inc.
// 10/18/2020
// Linux ARM64
// as -g -o environment.obj environment.asm
// gcc -g environment.c environment.obj -o environment
//============================ CONSTANT DEFINITIONS ==========================
.equ	BUFF_SIZE, 128			// number of bytes in buffer
.equ	ZERO, 		 0			// the number 0
//============================= MACRO DEFINITION =============================
.MACRO getSaveEnv	src, dest		//===== getSaveEnv macro takes 1 arg =====
	ldr		x0, =\src				// env%1 = ASCIIZ env var name
	bl		getenv					// getenv will return with [x0] => ASCIIZ

	mov		x1, x0					// x1 - 2nd arg strncpy			
	ldr 	x0, =\dest				// [x0] = env var dest - 1st arg strncpy
	mov		x2, #(BUFF_SIZE - 1)	// x2 = max # to copy  - 3rd arg strncpy
	cmp		x1, #ZERO				// did getenv fail? (# bytes written)
	bne		1f						// jump forward to label 1 if getenv ok
	ldr		x1, =nullLine			// otherwise print "(null)
1:	
	bl		strncpy					// call C library function to save env var
.ENDM								//======== end of getSaveEnv macro =======
//============================== CODE SECTION ================================
.section	.text
.global 	printenv				// tell linker we're exporting printenv
.extern 	getenv, printf, strncpy	// tell assembler/linker about externals
									// this module doesn't have _start or main
//============================= EXPORTED FUNCTION ============================
printenv:
	stp		x29, x30, [sp, #-16]!	// push fp and lr - boilerplate
	str		x21, [sp, #-16]!		// callee saved reg - must be preserved
	mov		x21, x0					// save printenv's argument (dateStr)
	
	// get and save these environment variables
	getSaveEnv envHOME, 	bufHOME
	getSaveEnv envHOSTNAME, bufHOSTNAME
	getSaveEnv envHOSTTYPE, bufHOSTTYPE
	getSaveEnv envCPU,		bufCPU
	getSaveEnv envPWD,		bufPWD
	getSaveEnv envTERM,		bufTERM
	getSaveEnv envPATH,		bufPATH
	getSaveEnv envSHELL,	bufSHELL
	getSaveEnv envEDITOR,	bufEDITOR
	getSaveEnv envMAIL,		bufMAIL
	getSaveEnv envLANG,		bufLANG
	getSaveEnv envPS1,		bufPS1
	getSaveEnv envHISTFILE, bufHISTFILE

	// call printf with many, many arguments
	// pass args in x0 - x7 with remaining args on stack
	ldr		x0, =formatString		//  1st printf arg
	mov		x1, x21					//  restore dateStr - 2nd printf arg
	ldr		x2, =bufHOME			//  3rd printf arg
	ldr		x3, =bufHOSTNAME		//  4th printf arg
	ldr		x4, =bufHOSTTYPE		//  5th printf arg
	ldr		x5, =bufCPU				//  6th printf arg
	ldr		x6, =bufPWD				//  7th printf arg
	ldr		x7, =bufTERM			//  8th printf arg
	// we've used all 8 argument passing registers - push remaining args
	// NOTE: pushes performed in reverse order because
	// 		args are read from top of stack. The stack grows downward!

	add		sp, sp, #-64			// reserve space for 7 8-byte pointers	
									// round up to 64 bytes
	ldr		x21, =bufHISTFILE		// 15th printf arg
	str		x21, [sp, #48]
	ldr		x21, =bufPS1			// 14th printf arg
	str		x21, [sp, #40]	
	ldr		x21, =bufLANG			// 13th printf arg
	str		x21, [sp, #32]
	ldr		x21, =bufMAIL			// 12th printf arg
	str		x21, [sp, #24]
	ldr		x21, =bufEDITOR			// 11th printf arg
	str		x21, [sp, #16]
	ldr		x21, =bufSHELL			// 10th printf arg
	str		x21, [sp, #8]
	ldr		x21, =bufPATH			//  9th printf arg
	str		x21, [sp]
	
	bl		printf					// invoke the C printf function
	add		sp, sp, #64				// caller must remove items pushed

	eor		x0, x0, x0				// return EXIT_SUCCESS = 0

	ldr		x21, [sp], #16			// restore callee saved register
	ldp		x29, x30, [sp], #16		// pop fp and lr
	ret								// return to caller
//========================= READ-ONLY DATA SECTION ===========================
.section		.rodata
formatString:	.ascii "\nEnvironment Variables on %s:\n"
				.ascii "\tHOME     = %s\n"					
				.ascii "\tHOSTNAME = %s\n"
				.ascii "\tHOSTTYPE = %s\n"
				.ascii "\tCPU      = %s\n"
				.ascii "\tPWD      = %s\n"
				.ascii "\tTERM     = %s\n"
				.ascii "\tPATH     = %s\n"
				.ascii "\tSHELL    = %s\n"
				.ascii "\tEDITOR   = %s\n"
				.ascii "\tMAIL     = %s\n"
				.ascii "\tLANG     = %s\n"
				.ascii "\tPS1      = %s\n"
				.asciz "\tHISTFILE = %s\n\n"

envHOME:		.asciz "HOME"
envHOSTNAME:	.asciz "HOSTNAME"
envHOSTTYPE:	.asciz "HOSTTYPE"
envCPU:			.asciz "CPU"
envPWD:			.asciz "PWD"
envTERM:		.asciz "TERM"
envPATH:		.asciz "PATH"
envSHELL:		.asciz "SHELL"
envEDITOR:		.asciz "EDITOR"
envMAIL:		.asciz "MAIL"
envLANG:		.asciz "LANG"
envPS1:			.asciz "PS1"
envHISTFILE:	.asciz "HISTFILE"

nullLine:		.asciz "(null)"
//========================== UNINITIALIZED DATA SECTION ======================
.section		.bss
bufHOME:		.space	BUFF_SIZE
bufHOSTNAME:	.space	BUFF_SIZE
bufHOSTTYPE:	.space	BUFF_SIZE
bufCPU:			.space	BUFF_SIZE
bufPWD:			.space	BUFF_SIZE
bufTERM:		.space	BUFF_SIZE
bufPATH:		.space	BUFF_SIZE
bufSHELL:		.space	BUFF_SIZE
bufEDITOR:		.space	BUFF_SIZE
bufMAIL:		.space	BUFF_SIZE
bufLANG:		.space	BUFF_SIZE
bufPS1:			.space	BUFF_SIZE
bufHISTFILE:	.space	BUFF_SIZE
//============================================================================
