#############################################################################
#	Makefile for environment
# 	John Schwartzman, Forte Systems, Inc.
# 	01/12/2020
#
#	Commands:  make release, make debug, make clean
#			   make = make release
#   Requires:  ../maketest.sh
#############################################################################
PROG  := environment
SHELL := /bin/bash

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst
	gcc $(PROG).c $(PROG).obj -o $(PROG)

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as -g -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst
	gcc -g $(PROG).c $(PROG).obj -o $(PROG)

clean:
	@rm -f $(PROG) $(PROG).obj $(PROG).lst a.out debug release
#############################################################################
