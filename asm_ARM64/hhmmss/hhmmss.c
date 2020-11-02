/////////////////////////////////////////////////////////////////////////////
// hhmmss.c - A test driver for toHHMMSS().
// John Schwartzman, Forte Systems, Inc.
// 04/23/2020
/////////////////////////////////////////////////////////////////////////////
#include <time.h>
#include <stdio.h>	        // declaration of printf
#include <stdlib.h>         // defines EXIT_SUCCESS

const char* toHHMMSS(long nSeconds);   // declaration of asm function

int main(void)
{
    time_t t = time(NULL);
    struct tm lt = *localtime(&t);
    long nSeconds = lt.tm_hour * 60 * 60 + lt.tm_min * 60 + lt.tm_sec;
    const char* pSeconds = toHHMMSS(nSeconds);   // call toHHMMSS 
    printf("The current time is: %s\n\n", pSeconds);
}
