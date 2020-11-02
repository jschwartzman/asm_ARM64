//============================================================================
// hello.asm - prints "Hello World" on the command line
// John Schwartzman, Forte Systems, Inc.
// 10/27/2020
// Linux ARM64
//============================= CONSTANT DEFINITIONS =========================
.equ  	EXIT_SUCCESS,  0			// Linux apps return 0 to indicate success
.equ	STDOUT,        1			// destination for SYS_WRITE
.equ	SYS_WRITE,    64			// kernel SYS_WRITE service number
.equ	SYS_EXIT,     93			// kernel SYS_EXIT service number
//================================ CODE SECTION ==============================
.global 	_start
.section	.text

_start:
	mov		x8, #SYS_WRITE			// prepare to call SYS_WRITE 
	mov		x0, #STDOUT				// 1st arg to SYS_WRITE - X0 = STDOUT
	ldr		x1, =msg				// 2nd arg to SYS_WRITE - [X1] => msg
	mov		x2, #MSG_LENGTH			// 3rd arg to SYS_WRITE - X2 = MSG_LENGTH
	svc		0						// invoke Linux kernel SYS_WRITE service
    
	mov 	x8, #SYS_EXIT			// prepare to call SYS_EXIT
	eor		x0, x0, x0				// place 0 (return code) in w0
	svc		0						// invoke Linux kernel SYS_EXIT service
//========================== READ-ONLY DATA SECTION ==========================
.section .rodata
    msg: 	.ascii	"\nHello, world!\n\n"
    .equ	MSG_LENGTH, . - msg
//============================================================================
