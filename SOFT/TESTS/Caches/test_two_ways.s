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
    la x3, _tab
    la x4, _tab2
    lw x5, 0(x3)
    lw x6, 0(x4)
    add x7,x5,x6
    lw x5, 4(x3)
    lw x6, 4(x4)
    add x8, x5,x6
    add x7,x7,x8
    li x2, 12 + 14
    beq x7,x2,_good
    j _bad
    nop




.section .data

_tab: 
.align 11
.word 6, 7
.align 11
_tab2:
.word 6,7
