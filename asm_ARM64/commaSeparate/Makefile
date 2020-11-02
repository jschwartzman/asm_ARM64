#############################################################################
#	Makefile for commaSeparate ARM64
# 	John Schwartzman, Forte Systems, Inc.
# 	02/13/2020
#
#	Commands:  make release, make debug, make clean
#			   make = make release
#	- OR -
#			  make release DEF=__MAIN__
#
#   Requires:  ../maketest.sh
#############################################################################
PROG  := commaSeparate
SHELL := /bin/bash
# DEF   := __MAIN__	

##### BUILD WITHOUT DEFINING __MAIN__ IN ORDER TO LINK WITH factorial. ######
################## BUILD THIS BEFORE BUILDING factorial. ####################

ifeq ($(DEF), __MAIN__)	############### STAND ALONE PROGRAM #################

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -defsym DEF=__MAIN__ -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst
	gcc -no-pie $(PROG).obj -o $(PROG)

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as -g -defsym DEF=__MAIN__ -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst
	gcc -g -no-pie $(PROG).obj -o $(PROG)

else	#####################################################################

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as -g -o $(PROG).obj $(PROG).asm
	objdump -d $(PROG).obj > $(PROG).lst

endif	#####################################################################

clean:
	@rm -f $(PROG) $(PROG).obj $(PROG).lst debug release
#############################################################################
