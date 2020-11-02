//============================================================================
// minmax.asm - demonstrates using macros for code and for local variables
// John Schwartzman, Forte Systems, Inc.
// 02/06/2020
// linux ARM64
// We create 2 variables, a and b, on the stack:
//	a = [sp, #0]
//	b = [sp, #8]
//============================== DEFINE MACRO ================================
.macro prologue						//=== prologue macro takes 0 arguments ===
	stp		x29, x30, [sp, #-16]!
	add		sp, sp, #-16			// make space for local variables on stack
	mov		x3, x0					// assume answer is a
	cmp		x0, x1					// compare a and b
	str		x0, [sp, #0]			// x0 contains a - 1st arg to min or max
	str		x1, [sp, #8]			// x1 contains b - 2nd arg to min or max
	ldr		x1, [sp, #0]			// 2nd arg to printf = a
	ldr		x2, [sp, #8]			// 3rd arg to printf = b
.endm								//========= end of prologue macro ========
//============================== DEFINE MACRO ================================
.macro epilogue						//=== epilogue macro takes 0 arguments ===
	mov		x29, x3					// save x3 in order to return it
	bl		printf					// invoke the C function
	mov		x0, x29					// x0 = return
	add		sp, sp, #16				// free space used by local variables
	ldp		x29, x30, [sp], #16		// undo 1st 2 prologue instructions
	ret								// return to caller 
.endm								//========= end of epilogue macro ========
//============================== DEFINE MACRO ================================
.macro max							//========= max macro takes 0 args =======
	bgt		1f						// if a gt b then branch
	ldr		x3, [sp, #8]			// else x3 = b					
1:
	ldr		x0, =formatStrMax		// 1st arg to printf
.endm								//============ end of max macro ==========
//============================== DEFINE MACRO ================================
.macro min							//========= min macro takes 0 args =======
	blt		1f						// if a lt b then branch
	ldr		x3, [sp, #8]			// else x3 = b
1:
	ldr		x0, =formatStrMin		// 1st arg to printf
.endm								//========== end of min macro ============
//============================== CODE SECTION ================================
.section		.text					
.global 		printMax, printMin	// tell linker about exported functions
.extern 		printf				// tell assembler/linker about externals
.align	8
printMax:							//=========== printMax function ==========
	prologue
	max
	epilogue						//======== end of printMax function ======

printMin:							//=========== printMin function ==========
	prologue
	min
	epilogue						//======== end of printMin function ======
//========================= READ-ONLY DATA SECTION ===========================
.section		.rodata	
formatStrMax:	.asciz		"max(%ld, %ld) = %ld\n\n"
formatStrMin:	.asciz		"min(%ld, %ld) = %ld\n\n"
//============================================================================
