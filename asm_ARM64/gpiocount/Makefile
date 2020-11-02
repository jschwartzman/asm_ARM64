#############################################################################
#	Makefile for gpiomem - 7-segment display client code
# 	John Schwartzman, Forte Systems, Inc.
# 	04/28/2020
#	ARM64
#	Commands:  make release, make debug, make clean
#			   make = make release
#   Requires:  ../maketest.sh 
#############################################################################
PROG := mapgpio
PROG2 := gpiocount
PROG3 := main
SHELL := /bin/bash

release: $(PROG).asm $(PROG2).asm $(PROG3).c Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	as -o $(PROG2).obj $(PROG2).asm
	gcc -no-pie $(PROG3).c $(PROG).obj $(PROG2).obj -o $(PROG2)

debug: $(PROG).asm $(PROG2).asm $(PROG3).c Makefile
	@source ../maketest.sh && test debug release
	as -g -o $(PROG).obj $(PROG).asm
	as -g -o $(PROG2).obj $(PROG2).asm
	gcc -g -no-pie $(PROG3).c $(PROG).obj $(PROG2).obj -o $(PROG2)

clean:
	@rm -f $(PROG2) $(PROG).obj $(PROG2).obj debug release
#############################################################################
