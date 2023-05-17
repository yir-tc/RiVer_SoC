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
    addi x2,x0,2020
    sw x2,4(x0)
    lw x3,4(x0) 
    sw x3,4(x0) 
    lw x3,4(x0) 
    beq x2,x3,_good
    j _bad
    nop 
