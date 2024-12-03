lw r2, 2(r0)
add r1, r0, r0
nop

loop:
nop
sgei r3, r2, 16
nop
mult r2, r2, r2
nop
addi r1, r1, 1
beqz r3, loop