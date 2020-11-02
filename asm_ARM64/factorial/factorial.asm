//============================================================================
// factorial.asm
// John Schwartzman, Forte Systems, Inc.
// 02/15/2020
// Linux ARM64
//============================ CONSTANT DEFINITIONS ==========================
.equ        ONE,            1       // number 1
.equ        ZERO,           0       // number 0
.equ        MAX_INPUT,     20       // max size input (to fit in 64-bit long)
.equ        EXIT_SUCCESS,	0		// return 0 to indicate success
.equ        EXIT_FAILURE,  -1       // return -1 to indicate failure

//============================== CODE SECTION ================================
.section		.text
.global 		main                // tell linker about export
.extern 		scanf, printf       // tell assembler/linker about externals

.ifndef DEF                         //========== use commaSeparate ==========
    .extern      commaSeparate      // tell linker we need this function
.endif                              //=======================================

main:
	stp		x29, x30, [sp, #-16]!   // boilerplate code - save fp and lr

getInput:
    ldr     x0, =promptFormat       // 1st arg to printf
    bl      printf                  // prompt user

    ldr     x0, =scanfFormat        // 1st arg to scanf
    adr     x1, x                   // 2nd arg to scanf = address of x
    bl      scanf
    cmp     x0, #ONE                // we should have read one item
    bne     badInput
    adr     x0, x                   // loading x is a 2 step process - get addr
    ldr     x0, [x0]                //    then load x
    cmp     x0, #MAX_INPUT          //   if it's too big
    bgt     badInput                //      branch to badInput
    cmp     x0, #ZERO               // if x > 0
    bgt     continue                //   branch to continue

badInput:                           // report bad input and try again
    ldr     x0, =wrongInputStr
    bl      printf
    b       getInput

continue:                           // we have valid input
    adr     x0, x
    ldr     x0, [x0]                // get x
    bl      factorial

.ifndef DEF                         //========== BUILD STANDALONE ============

    mov     x2, x0                  // 3rd arg to printf -- print result
    ldr     x0, =outputFormat       // 1st arg to printf
    ldr     x1, =x
    ldr     x1, [x1]                // 2nd arg to printf
    bl      printf                  // print result (x! = .......)

.else                               // == DISPLAY RESULT with commaSeparate ==

    bl      commaSeparate           // x0 contains the result of call to factorial
    mov     x29, x0                 // save the commaSeparate's output

    ldr     x0, =outputFormatComma  // print "x! ="
    ldr     x1, =x
    ldr     x1, [x1]
    bl      printf

    mov     x0, x29                 // restore commaSeparate's output 
    bl      printf                  // print commaSeparate output buf (x0 has addr)
    ldr     x0, =outputLF
    bl      printf                  // print 2 linefeeds

.endif                              // == DISPLAY RESULT with commaSeparate ==

    eor     w0, w0, w0              // return EXIT_SUCCESS

fin:
	ldp		x29, x30, [sp], #16		// boilerplate - restore fp and lr
	ret								// return to caller 

//============================= EXPORTED FUNCTION ============================
factorial:  // each invocation of factorial has its own stack with its own n
	stp		x29, x30, [sp, #-16]!
	add		sp, sp, #-16            // make space for local var n on stack

    cmp     x0, ONE                 // base case?
    bgt     greater                 //    branch if no
    mov     x0, ONE                 // the answer to the base case

	add		sp, sp, #16				// free space used by local variables
	ldp		x29, x30, [sp], #16		// undo 1st 2 prologue instructions
	ret								// return to caller 

greater:
    str     x0, [sp]                // save n
    sub     x0, x0, #ONE            // call factorial with n - 1
    bl      factorial               // recursive call to factorial

    ldr     x1, [sp]                // restore n
    mul     x0, x0, x1              // multiply factorial(n - 1) * n

	add		sp, sp, #16				// free space used by local variables
	ldp		x29, x30, [sp], #16		// undo 1st 2 prologue instructions
	ret								// return to caller 
//==============================  DATA SECTION ===============================
.section     .data
x:           .dword     0           // main's variable x
//========================= READ-ONLY DATA SECTION ===========================
.section 	.rodata	
scanfFormat:	    .asciz		"%ld"
promptFormat:       .asciz      "Enter an integer from 1 to 20: "
outputFormat:       .asciz		"%ld! = %ld\n\n"
outputFormatComma:  .asciz      "%ld! = "
wrongInputStr:      .asciz      "You have entered an invalid number.\n\n"
outputLF:           .asciz      "\n\n"
//============================================================================
