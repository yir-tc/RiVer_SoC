#ifndef RAM_H
#define RAM_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define _RAM_DEBUG_FILL  1
#define _RAM_DEBUG_READ  1
#define _RAM_DEBUG_WRITE 1

extern int*** ram[256];

int read_mem(unsigned int addr);
int write_mem(unsigned int addr, int data, unsigned int strobe, unsigned int time);

#endif