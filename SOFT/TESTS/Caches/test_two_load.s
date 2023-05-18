.section .text
.global _start

_start:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    la x3, _tab
    lw x4, 0(x3)
    lw x5, 4(x3)
    add x6,x4,x5
    li x2, 13
    beq x6,x2,_good
    j _bad
    nop




.section .data

_tab: 
.align 4
.word 6,7