.global _start

_start:
	AND r1,r0,#2
	AND r1,r0,r3
	MOV r5,#9
	AND r1,r2,ROR r5
	MUL r1,r2,r0
	SWP r4,r2,[r1]
