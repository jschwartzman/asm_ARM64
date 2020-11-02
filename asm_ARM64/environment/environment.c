// environment.c
// John Schwartzman, Forte Systems, Inc.
// 01/12/2020
// x86_64
// assemble: as -g -o environment.obj environment.asm
// compile and link: gcc -g environment.c environment.obj -o environment
// to execute: ./environment

#include <time.h>       // declaration of time; definition of time_t
#include <string.h>     // declaration of strtok

int printenv(const char* timestr);   // declaration of asm function

int main(void)
{
    time_t  now;

    time(&now);
    char* strTime = strtok(ctime(&now), "\n");  // remove newline from ctime
    return printenv(strTime);   // call printenv function with strTime arg
}
   