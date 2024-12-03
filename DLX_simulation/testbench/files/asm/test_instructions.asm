addi r1, r0, 8
addui r2, r0, -8
subi r3, r1, 4
subui r4, r1, -4
andi r5, r1, 5
ori r6, r1, 5
xori r7, r1, 5
addi r17, r0, 112
slli r8, r1, 2
srli r9, r1, 2
srai r10, r1, 4
seqi r11, r1, 8
snei r12, r1, 0
slti r13, r1, 10
sgti r14, r1, 0
slei r15, r1, 8
sgei r16, r1, 8
jr r17
xor r1, r1, r1
xor r2, r2, r2
xor r3, r3, r3
xor r4, r4, r4
xor r5, r5, r5
xor r6, r6, r6
xor r7, r7, r7
xor r8, r8, r8
xor r9, r9, r9
xor r10, r10, r10
add r18, r0, r1
addu r19, r0, r2
sub r20, r18, r1
subu r21, r18, r2
and r22, r18, r1
or r23, r18, r1
sll r24, r18, r1
srl r25, r18, r1
seq r27, r18, r1
sne r28, r18, r1
sle r29, r18, r1
sge r30, r18, r1
sw 0(r0), r0
sw 1(r0), r1
sw 2(r0), r2
sw 3(r0), r3
sw 4(r0), r4
sw 5(r0), r5
sw 6(r0), r6
sw 7(r0), r7
lw r7, 0(r0)
lw r6, 1(r0)
lw r5, 2(r0)
lw r4, 3(r0)
lw r3, 4(r0)
lw r2, 5(r0)
lw r1, 6(r0)
lw r0, 7(r0)