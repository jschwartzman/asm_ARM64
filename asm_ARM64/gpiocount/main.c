/****************************************************************************
 * main.c
 * John Schwartzman
 * 03/21/2020
 * 
 * requires gpiotest.asm and iomap.asm
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#define __MAP_FAILED__		-1
#define __OPEN_FAILED__		-2

int  initialize();
void countUp();
void countDown();
void cleanUp();

extern int main(int argc, char** argv)
{
	int nRetValue = initialize();
	if (nRetValue == __OPEN_FAILED__)
	{
		printf("initialize() could not open /dev/gpiomem.\n");
		exit(nRetValue);
	}
	else if (nRetValue == __MAP_FAILED__)
	{
		printf("initialize() could not map virtual memory.\n");
		exit(nRetValue);
	}
	printf("initilize() has finished.\n");
	printf("Starting first instance of countUp().\n");
	countUp();
	printf("First instance of countUp() has finished.\n");
	printf("Starting first instance of countDown().\n");
	countDown();
	printf("First instance of countDown() has finished.\n");
	printf("Starting second instance of countUp().\n");
	countUp();
	printf("Second instance of countUp() has finished.\n");
	printf("Starting second instance of countDown().\n");
	countDown();
	printf("Second instance of countDown() has finished.\n");
	cleanUp();
	printf("cleanUp() has finished.\n");
}