#############################################################################
#	Makefile for factorial
# 	John Schwartzman, Forte Systems, Inc.
# 	02/15/2020
#
#	Commands:  make release, make debug, make clean
#			   make = make release
#	- OR -
#			  make release DEF=__COMMA__
#			  make debug DEF=__COMMA__
#
#   Requires:  ../maketest.sh
#############################################################################
PROG  := factorial
SHELL := /bin/bash
EXT	  := ../commaSeparate/commaSeparate
#DEF  := __COMMA__	#### USE THIS OPTION TO LINK WITH commaSeparate.asm #####

ifeq ($(DEF), __COMMA__)	############### use commaSeparate ###############

release: $(PROG).asm Makefile $(EXT).obj
	@source ../maketest.sh && test release debug
	as -defsym DEF=__COMMA__ -o $(PROG).obj $(PROG).asm
	gcc -no-pie $(PROG).obj $(EXT).obj -o $(PROG)

debug: $(PROG).asm Makefile $(EXT).obj
	@source ../maketest.sh && test debug release
	as -D -defsym DEF=__COMMA__ -g -o $(PROG).obj $(PROG).asm
	gcc -g -no-pie $(PROG).obj $(EXT).obj -o $(PROG)

else

release: $(PROG).asm Makefile
	@source ../maketest.sh && test release debug
	as -o $(PROG).obj $(PROG).asm
	gcc -no-pie $(PROG).obj -o $(PROG)

debug: $(PROG).asm Makefile
	@source ../maketest.sh && test debug release
	as -g -o $(PROG).obj $(PROG).asm
	gcc -g -no-pie $(PROG).obj -o $(PROG)

endif	######################## use commaSeparate ##########################

clean:
	@rm -f $(PROG) $(PROG).obj $(PROG).lst debug release
#############################################################################
