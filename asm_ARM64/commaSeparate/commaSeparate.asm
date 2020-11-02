//============================================================================
// commaSeparate.asm
// John Schwartzman, Forte Systems, Inc.
// 02/16/2020
// Linux ARM64
//============================ CONSTANT DEFINITIONS ==========================
.equ    ZERO,             0         // number 0
.equ    ONE,              1         // number 1
.equ    TEN,             10			// number 10
.equ    HUNDRED,        100			// number 100
.equ    CHAR_ZERO,       48         // "0" character
.equ    CHAR_COMMA,      44         // "," character
.equ    BUFF_SIZE,       80			// output buffer size

//=============================== DEFINE MACRO ===============================
.macro  getN    reg
    ldr     \reg, [sp, #0]
.endm
//=============================== DEFINE MACRO ===============================
.macro  saveN    reg
    str     \reg, [sp, #0]
.endm
//=============================== DEFINE MACRO ===============================
.macro  getPower    reg
	ldr		\reg, =\power
	ldr		\reg, [\reg]
.endm
//=============================== DEFINE MACRO ===============================
.macro  writePowerOfTenToThird	power
    ldr     x0, [sp, #0]			// get n
    ldr     x1, =\power             // x1 = power
    ldr     x1, [x1]
    udiv    x0, x0, x1
    mov     x7, x0                  // save number of powers
    bl      writeThreeDigits
    bl      writeComma              // write comma if bFoundFactor == ONE
    mov     x0, x7
    ldr     x1, =\power             // x1 = power
    ldr     x1, [x1]
    mul     x0, x0, x1
    ldr     x1, [sp, #0]            // get n
    sub     x1, x1, x0
    str     x1, [sp, #0]			// save what's left of n
.endm
//=============================== DEFINE MACRO ===============================
.macro  writeUnits
    ldr     x0, [sp, #0]			// get what's left of n
    bl      writeThreeDigits
.endm
//============================== CODE SECTION ================================
.section		.text				

.ifndef DEF                         //========== BUILD WITHOUT MAIN ==========

.global      commaSeparate          // tell linker about export

.else								//=========== BUILD WITH MAIN ============

.global      main                   // tell linker about exports
.extern      printf, scanf          // tell assembler/linker about externals

//============================== MAIN FUNCTION ===============================
main:
	stp		x29, x30, [sp, #-16]!   // boilerplate code - save fp and lr

    ldr     x0, =promptFormat       // 1st arg to printf
    bl      printf                  // prompt user

    ldr     x0, =scanfFormat        // 1st arg to scanf
    ldr     x1, =x                  // 2nd arg to scanf
    bl      scanf                   // get x

    adr     x0, x
    ldr     x0, [x0]                // x is the long we want to separate
    bl      commaSeparate           // return pointer to outputBuf in r0
    bl      printf
    ldr     x0, =outputFormat
    bl      printf                  // write 2 line feeds
    eor     w0, w0, w0              // return EXIT_SUCCESS = 0
	ldp		x29, x30, [sp], #16		// restore fp and lr
	ret								// return to caller 

.endif  //====================== BUILD WITH MAIN =============================     

//============================= EXPORTED FUNCTION ============================
// commaSeparate uses 2 variables on the stack:
//      n    = [sp + 0]
//      nTmp = [sp + 8]
// It uses x29 for bFoundFactor and
// it uses x27 to point to the current position in the output buffer.
//============================================================================
commaSeparate:                      // param x0 = long int
	stp		x29, x30, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
	add		sp, sp, #-16			// space for 2 local var n & nTmp on stack

    adr     x27, outputBuf          // x27 => destination buffer
    mov     x28, #ZERO              // bFoundFactor = false

    str     x0, [sp, #0]           // initialize n (number to separate)

    writePowerOfTenToThird quintillion
    writePowerOfTenToThird quadrillion
    writePowerOfTenToThird trillion
    writePowerOfTenToThird billion
    writePowerOfTenToThird million
    writePowerOfTenToThird thousand
    writeUnits
 
    adr     x0, outputBuf           // return pointer to outputBuf in x0

	add		sp, sp, #16				// free space used by local variables
    ldp     x27, x28, [sp], #16
	ldp		x29, x30, [sp], #16		// undo 1st 2 prologue instructions
	ret								// return to caller 
//============================= LOCAL FUNCTION ===============================
writeThreeDigits:                   // param: x0 = any int from 0 to 999
	stp		x29, x30, [sp, #-16]!   // we can't access n & nTmp in this func
    mov     x6, x0                  // save parameter
    mov     x1, #HUNDRED            // * hundreds *
    udiv    x0, x0, x1              // x0 = number of hundreds
    mov     x5, x0                  // save number of hundreds
    bl      writeNTmp               // write hundreds

    mul     x0, x5, x1              // x0 = num hundreds * 100
    sub     x0, x6, x0              // x0 = param - (num hundreds *100)
    mov     x6, x0                  // save this value (overwrite param)

    mov     x1, #TEN                // * tens *
    udiv    x0, x0, x1              // x0 = number of tens
    mov     x5, x0                  // save number of tens
    bl      writeNTmp               // write tens

                                    // * ones *
    mul     x0, x5, x1              // x0 = 10 * number of tens
    sub     x0, x6, x0              // x0 = param - 100 * num hundreds - 10 * num tens

    bl      writeNTmp
	ldp		x29, x30, [sp], #16		// undo 1st 2 prologue instructions
    ret
//============================= LOCAL FUNCTION ===============================
writeComma:                         // destroys w0
    cmp     w28, #ZERO
    beq     noWriteComma
    mov     w0, #CHAR_COMMA
    strb    w0, [x27], #ONE         // write comma to outputBuf and increment

noWriteComma:
    ret
//============================= LOCAL FUNCTION ===============================
writeNTmp:                          // w0 = nTmp (0-9)  - destroys w0
    cmp     w0, #ZERO               // w0 == 0 ?
    bne     writeNTmp1              // jump if no
    cmp     x28, #ONE               // bFoundFactor ?
    bne     writeFin                // don't write a '0' if ! bFoundFactor   
    
writeNTmp1:
    mov     x28, #ONE               // bFoundFactor = true
    add     w0, w0, #CHAR_ZERO      // convert w0 to char
    strb    w0, [x27], #ONE         // write char to outputBuf and increment

writeFin:
    ret
//============================= LOCAL FUNCTION ===============================
writeN:                             // w0 = n (0-9)     - destroys w0
    add     w0, w0, #CHAR_ZERO      // convert to char
    strb    w0, [x27]               // write char to outputBuf
    ret
//==============================  DATA SECTION ===============================
.section     .data
x:              .dword      0
//========================== UNINITIALIZED DATA SECTION ======================
.section		.bss
outputBuf:	.space	BUFF_SIZE
//========================= READ-ONLY DATA SECTION ===========================
.section 	.rodata	
scanfFormat:    .asciz		"%ld"
promptFormat:   .asciz      "Enter a long integer: "
outputFormat:   .asciz      "\n\n"

thousand:       .dword      1000
million:        .dword      1000000
billion:        .dword      1000000000
trillion:       .dword      1000000000000
quadrillion:    .dword      1000000000000000
quintillion:    .dword      1000000000000000000

// NOTE: SEXTILLION equ THOUSAND * QUINTILLION doesn't fit in 64 bit register
//============================================================================
