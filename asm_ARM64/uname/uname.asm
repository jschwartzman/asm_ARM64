//============================================================================
// uname.asm - retrieves uname info from the kernel and prints it
// John Schwartzman, Forte Systems, Inc.
// 10/27/2020
// Linux ARM64
//============================ CONSTANT DEFINITIONS ==========================
.equ	STDOUT,           1          // file descriptor for terminal
.equ	SYS_EXIT,        93          // Linux service ID for SYS_EXIT
.equ	SYS_WRITE,       64          // Linux service ID for SYS_WRITE
.equ	SYS_UNAME,      160          // Linux service ID for SYS_UNAME
.equ	UTSNAME_SIZE,    65          // number of bytes in each *_res entry
.equ	HEADER_SIZE,     11          // size of each header
.equ	WRITELINE_SIZE,   1          // num bytes to write for linefeed
.equ	ZERO,		 	  0          // the number 0
//============================== CODE SECTION ================================
.global      _start                  // ld expects to find the label _start
.section	.text

_start:				    	         // beginning of program
	mov	    x8, #SYS_UNAME           // pxepaxe to call SYS_UNAME
	ldr 	x0, =sysname_res      	 // x0 points to address of structure
	svc 	0                     	 // call SYS_UNAME to populate .bss sect
	cmp 	x0, #ZERO	         	 // did sys_uname fail?
	bne 	exit                     // exit if error getting SYS_UNAME

	bl	    writeNewLine             // write a blank line to stdout
	
	ldr 	x1, =sysname	         // SYS_WRITE 2nd arg
	bl	 	writeHeader              // call local method - print w/o linefeed
	ldr 	x1, =sysname_res         // SYS_WRITE 2nd arg
	bl	 	writeData                // call local method - print with linefeed
	
	ldr 	x1, =nodename         	 // print nodename header
	bl		writeHeader
	ldr 	x1, =nodename_res        // print nodename data
	bl 		writeData

	ldr 	x1, =release	         // print release header
	bl	 	writeHeader
	ldr 	x1, =release_res         // print release data
	bl 		writeData

	ldr 	x1, =version             // print version header
	bl	 	writeHeader
	ldr		x1, =version_res         // print version data
	bl		writeData

	ldr 	x1, =domain		         // print domain header
	bl	 	writeHeader
	ldr 	x1, =domain_res          // print domain data
   	bl	 	writeData

	bl    	writeNewLine             // write a blank line to stdout
	eor 	x0, x0, x0     		     // w0 = EXIT_SUCCESS = 0

exit:						       
	mov 	x8, #SYS_EXIT		     // exit program - 1st arg w0 = exit code
	svc 	0                     	 // invoke kernel and we're gone

writeHeader:    //===== local method - caller sets SYS_WRITE 2nd param =====
	mov 	x7, #SYS_WRITE		     // Linux service ID
	mov 	x0, #STDOUT			     // SYS_WRITE 1st arg
	mov 	x2, #HEADER_SIZE         // SYS_WRITE 3rd arg
	svc 	0					     // invoke kernel
	ret							     //====== end of writeHeader method =====

writeData:      //===== local method - caller sets SYS_WRITE 2nd param =====
	mov 	x8, #SYS_WRITE		     // Linux service ID
	mov 	x0, #STDOUT              // SYS_WRITE 1st arg
	mov 	x2, #UTSNAME_SIZE        // SYS_WRITE 3rd arg 
	svc 	0					     // invoke kernel & fall into writeNewLine

writeNewLine:				         //============ local method ============
	mov 	x8, #SYS_WRITE		     // Linux service ID
	mov 	x0, #STDOUT              // SYS_WRITE 1st arg
	ldr 	x1, =linefeed	         // SYS_WRITE 2nd arg
	mov 	x2, #WRITELINE_SIZE      // SYS_WRITE 3rd arg
	svc 	0                        // invoke kernel
	ret
//========================= READ-ONLY DATA SECTION ===========================
.section 	.rodata
sysname:    .ascii      "OS name:   "	// len = HEADER_SIZE
nodename:   .ascii      "node name: "	// len = HEADER_SIZE
release:    .ascii      "release:   "	// len = HEADER_SIZE
version:    .ascii      "version:   "	// len = HEADER_SIZE
domain:     .ascii    	"machine:   "	// len = HEADER_SIZE
linefeed:   .ascii      "\n"            // ASCII LF (len = WRITELINE_SIZE)
//========================== UNINITIALIZED DATA SECTION ======================
.section	.bss
sysname_res:    .space 	  UTSNAME_SIZE
nodename_res:   .space    UTSNAME_SIZE
release_res:    .space    UTSNAME_SIZE
version_res:    .space    UTSNAME_SIZE
domain_res:     .space    UTSNAME_SIZE
//============================================================================
