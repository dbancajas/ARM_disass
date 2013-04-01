.global _start

_start:
	AND r10,r7,#256
	AND r10,r7,#16
	AND r10,r7,#32
	AND r10,r7,#64
	AND r10,r7,#128
	AND r10,r7,#1024
	AND r10,r7,#51200
	AND r15,r6,r8
	ANDEQS r1,r2,ROR r5
	AND r9,r6,r8
	AND r11,r6,r7
	AND r12,r6,r6
	AND r13,r6,r5
	AND r14,r6,r4
	AND r9,r6,r8, LSL #16
	AND r9,r6,r8, LSR #12
	AND r9,r6,r8, ROR #5
	AND r9,r6,r8, ASR #2
	AND r9,r6,r8, ROR #0
	AND r9,r6,r8, ASR R10
	ADD r9,r6,r8, ASR R10
	ADD r10,r7,#51200
	ADD r10,r7,#16
