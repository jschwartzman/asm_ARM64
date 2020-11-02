#############################################################################
#	Makefile for hhmmss
# 	John Schwartzman, Forte Systems, Inc.
# 	06/12/2019
#
#	Commands:  make release, make debug, make clean
#			   make = make release
#	- OR -
#			  make release DEF=__MAIN__, make debug DEF=__MAIN__
#
#   Requires:  ../maketest.sh
#############################################################################
PROG  := hhmmss
SHELL := /bin/bash
#DEF  := __MAIN__	## DO NOT DEFINE MAIN IF YOU WANT TO LINK TO hhmmss.asm #

ifeq ($(DEF), __MAIN__)	############### STAND ALONE PROGRAM #################

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -defsym DEF=__MAIN__ -o $(PROG).obj $(PROG).asm
	gcc -no-pie $(PROG).obj -o $(PROG)

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as -g -defsym DEF=__MAIN__ -o $(PROG).obj $(PROG).asm
	gcc -g -no-pie $(PROG).obj -o $(PROG)

else	#####################################################################

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	gcc -no-pie $(PROG).c $(PROG).obj

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as -g -o $(PROG).obj $(PROG).asm
	gcc -g -no-pie $(PROG).c $(PROG).obj

endif	#####################################################################

clean:
	@rm -f $(PROG) $(PROG).obj debug release
#############################################################################
