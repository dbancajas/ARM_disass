.global _start
_start:
 
	adc r12,r7,#10
	adceq r12,r7,#10
	adcne r12,r7,#10
	adc  r15,r7,#1
	adc  r14,r7,#1
	adc  r13,r7,#1
	adcs  r13,r7,#1
	addnes r1,r2,r3
