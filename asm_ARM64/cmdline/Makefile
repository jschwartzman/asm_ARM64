#############################################################################
#	Makefile for cmdline
#	John Schwartzman, Forte Systems, Inc.
#	10/31/2020
#
#	Commands:  make release, make debug, make clean
#			   make = make release
#   Requires:  ../maketest.sh
#############################################################################
PROG  := cmdline
SHELL := /bin/bash

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	gcc $(PROG).obj -o $(PROG)
	gcc $(PROG).c

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as  -g -o $(PROG).obj $(PROG).asm
	gcc -g $(PROG).obj -o $(PROG)
	gcc -g $(PROG).c

clean:
	@rm -f $(PROG) $(PROG).obj a.out debug release

#############################################################################
