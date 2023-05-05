
#include "ram.h"

int*** ram[256];

void init_mem(unsigned int addr1, unsigned int addr2, unsigned int addr3) {
    if (!ram[addr1]) 
        ram[addr1] = calloc(256, sizeof(int*));
    if (!ram[addr1][addr2]) 
        ram[addr1][addr2] = calloc(256, sizeof(int*));
    if (!ram[addr1][addr2][addr3]) {
        ram[addr1][addr2][addr3] = calloc(256, sizeof(int));
        #ifdef _RAM_DEBUG_FILL
            memset(ram[addr1][addr2][addr3], 'A', 256);
        #endif
    }
}

int read_mem(unsigned int addr) {
    unsigned int addr1, addr2, addr3, addr4;
    addr = addr >> 2;
    
    addr1 = addr & 0xFF; 
    addr2 = (addr >> 8) & 0xFF; 
    addr3 = (addr >> 16) & 0xFF; 
    addr4 = (addr >> 24) & 0xFF; 
    if(!ram[addr1] || !ram[addr1][addr2] || !ram[addr1][addr2][addr3]) {
        init_mem(addr1, addr2, addr3);
    }

    #ifdef _RAM_DEBUG_READ
        printf("[read mem] : at @ %x data %x\n", addr, ram[addr1][addr2][addr3][addr4]);
    #endif
    return ram[addr1][addr2][addr3][addr4];
}

int write_mem(unsigned int addr, int data, int byt_sel, int time) {
    unsigned int addr1, addr2, addr3, addr4;
    int tmp = 0; 
    int mask = 0;
    int dataw; 

    addr = addr >> 2; 
    addr1 = addr & 0xFF; 
    addr2 = (addr >> 8) & 0xFF; 
    addr3 = (addr >> 16) & 0xFF; 
    addr4 = (addr >> 24) & 0xFF;
    if(!ram[addr1] || !ram[addr1][addr2] || !ram[addr1][addr2][addr3]) {
        init_mem(addr1, addr2, addr3);
    }

    switch(byt_sel) {
        // store byte
        case 1:     dataw = data            & ~(0xFFFFFF00);    break;
        case 2:     dataw = (data << 8)     & ~(0xFFFF00FF);    break;
        case 4:     dataw = (data << 16)    & ~(0xFF00FFFF);    break;
        case 8:     dataw = (data << 24)    & ~(0x00FFFFFF);    break;
        // store half word 
        case 3:     dataw = data            & ~(0xFFFF0000);    break;
        case 12:    dataw = (data << 16)    & ~(0x0000FFFF);    break;
        // store word
        case 15:    dataw = data;                               break;

        default:    dataw = 0;                                  break; 
    }

    if(byt_sel & 0x1) 
        mask |= 0xFF; 
    if(byt_sel & 0x2)
        mask |= 0xFF00;
    if(byt_sel & 0x4)
        mask |= 0xFF0000;
    if(byt_sel & 0x8)
        mask |= 0xFF000000;

    tmp = ram[addr1][addr2][addr3][addr4];
    tmp &= ~mask; 
    tmp |= dataw; 
    ram[addr1][addr2][addr3][addr4] = tmp;

    #ifdef _RAM_DEBUG_WRITE
        printf("%d ns [write mem] : at @ %x writting %x\n", time, addr, dataw);
    #endif

    return 0; 
}   
