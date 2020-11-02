// --------------------------------------------------------------------------
// mapgpio.asm
// 04/28/2020
// ARM64
//
// IO_init maps gpio into the user program's memory space.
// Pointers to the devices are stored in global variables.
// The user program can use those pointers to access the device registers
//
// IO_close unmaps the devices.
//
// At this time we are only opening/closing GPIO_BASE
// --------------------------------------------------------------------------
.equ	GPIO_BASE, 	0x3F200000

.equ	OPEN_FAILED,	-2	
.equ	MAP_FAILED, 	-1
.equ	MAP_SHARED,		 1
.equ	PROT_READ, 		 1
.equ	PROT_WRITE,		 2

.equ	O_RDWR,		00000002
.equ	O_SYNC,		00010000

.equ	BLOCK_SIZE,	(4*1024)

.equ	ZERO,				0
.equ	ONE,				1
.equ	NUM_POINTERS,		1	// 4
.equ	EIGHT,				8
.equ	ALIGNMENT_MASK,	0xFFF

.data
.global	gpiobase	// , pwmbase, uart0base, clkbase

gpiobase:	.dword	0
memdev_fd:	.word	0

.section .rodata
memdev:			.asciz	"/dev/gpiomem"

.text
.global	mapOpen, mapClose
.extern mmap, munmap, open, close

// --------------------------------------------------------------------------
// IO_init() maps devices into memory space and
// stores their addresses in gloval variables.
// int mapOpen(void);
// returns 0 = success, -1 = could not map memory, -2 = could not open file
// --------------------------------------------------------------------------
mapOpen:
	stp		x29, x30, [sp, #-16]!		// push FP and LR

	// try to open /dev/gpiomem
	ldr		x0, =memdev
	mov		w1, #(O_RDWR + O_SYNC)
	bl		open
	cmp		w0, #ZERO					// check fd
	bgt		openOk
	mov		w0, #OPEN_FAILED
	b		init_exit

openOk:
	adr		x3, memdev_fd				// save fd
	str		w0, [x3]

	mov		x1, GPIO_BASE
	mov		x6, x1						// copy address to x6
	mov		x7, #ALIGNMENT_MASK			// set up mask
	and		x29, x6, x7					// get offset from page boundry
	bic		x5, x6, x7					// align phys addr to page boundry
	mov		x4, x0						// FD to x4
	mov		x3, #MAP_SHARED
	mov		x2, #(PROT_READ + PROT_WRITE)
	mov		x1, #BLOCK_SIZE
	mov		x0, x6						// request offset as virtual address
	bl		mmap
	cmp		x0, #MAP_FAILED
	beq		init_exit

	add		x0, x0, x29				// add offset from page boundry
	adr		x1, gpiobase			// x1 => gpiobase
	str		x0, [x1]				// write x0 to gpiobase

	adr		x0, memdev_fd
	ldr		w0, [x0]
	bl		close
	eor		w0, w0, w0				// w0 = exit success

init_exit:
	ldp		x29, x30, [sp], #16		// pop fb and lr
	ret		// return from IO_init

// --------------------------------------------------------------------------
// IO_close unmaps all of the devices
// void mapClose(void);
// --------------------------------------------------------------------------
mapClose:
	stp		x29,x30,[sp, #-16]!		// push fb and lr

	adr		x0, gpiobase
	ldr		x0, [x0]
	cmp		x0, #ZERO				// was it ever mapped?
	beq		closed					//   branch if no

	mov		x1, #BLOCK_SIZE
	bl		munmap					// unmap it

closed:
	ldp		x29, x30, [sp], #16		// pop fb and lr
	ret
// --------------------------------------------------------------------------











