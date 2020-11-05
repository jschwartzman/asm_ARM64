#############################################################################
#	Makefile for minmax
# 	John Schwartzman, Forte Systems, Inc.
# 	02/06/2020
#
#	Commands:  make release, make debug, make clean
#			   make = make release
#   Requires:  ../maketest.sh
#
#	Builds both versions of minmax.c:  a.out  - c only
#									   minmax - c and assembly
#############################################################################
PROG  := minmax
SHELL := /bin/bash

release: $(PROG).asm $(PROG).c Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst
	gcc $(PROG).c $(PROG).obj -o $(PROG)
	gcc -D c_version $(PROG).c

debug: $(PROG).asm $(PROG).c Makefile
	@source ../maketest.sh && test debug release
	as -g -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst
	gcc -g $(PROG).c $(PROG).obj -o $(PROG)
	gcc -g -D c_version $(PROG).c

clean:
	@rm -f $(PROG) $(PROG).obj $(PROG).lst a.out debug release
#############################################################################
