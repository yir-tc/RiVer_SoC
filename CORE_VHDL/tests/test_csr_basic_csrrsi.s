.section .text
.global _start

_start:
    addi x4,x0,0x5
    csrrwi x0,0x300,0x0
    csrrwi x3, 0x300, 0x4 #x3 = 0; 0x300 = 0x5
    csrrsi x3, 0x300, 0x1 # x3 = 0x5; 0x300 = 0x5 or 0x1
    nop
    nop
    csrrwi x3, 0x300, 0 #x3 = 0x6; 
    nop
    nop
    beq x3,x4, _good
    j _bad
    nop
    nop


