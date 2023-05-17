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
    la x2, _tab3
    lw x5, 0(x3)
    lw x6, 0(x4)
    lw x7, 0(x2)
    lw x6, 0(x4)
    add x7,x5,x7
    add x7,x7,x6
    li x2, 6 + 7 + 8
    beq x7,x2,_good
    j _bad
    nop




.section .data

_tab: 
.align 11
.word 6
.align 11
_tab2:
.word 7
.align 11
_tab3:
.word 8
