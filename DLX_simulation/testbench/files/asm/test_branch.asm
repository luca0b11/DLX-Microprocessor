lw r1, 1(r0)
lw r2, 2(r0)
lw r3, 3(r0)
nop
xor r4, r4, r4
xor r5, r5, r5
xor r6, r6, r6
add r4, r1, r2
sub r5, r1, r3
mult r6, r2, r3
nop
and r7, r1, r2
or  r8, r1, r4
xor r9, r1, r5
slli r10, r6, 2  
srli r11, r2, 1
beqz r1, label1
bnez r1, label2

label1:
sw 4(r0), r4
sw 5(r0), r5
sw 6(r0), r6
j exit

label2:
sw 7(r0), r7
sw 8(r0), r8
sw 9(r0), r9

exit:
nop