;
; CSc 230 Assignment 5 Part 2 Programming
;   Factorial
;  
; Chris Warren
;	Date: November 15th 2017
; this program calculate the factorial of a constant <=6
;the constant is found in the memory location called init and the result is found in the memory location result
;the result is then outputed on 4 LEDs
; 
;
;   
;
.include "m2560def.inc"

.cseg

.MACRO ADDW ;
	add @1, @3
	adc @0, @2
.ENDMACRO

	; initialize the stack pointer
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

;  Obtain the constant from location init
	ldi zH, High(init<<1)
	ldi zL, low(init<<1)
	lpm r16, Z

	push r16
	ldi r25, 1
	call factorial
	; pop previously pushed parameters
	pop r16
	

	;series of masks and logical operations which spread out the lower nibble of result
	lds r16, result
	
	; Reduced to only 9 instructions to spread out R16 lower nibble
	Clr  R18
	Sbrc R16, 8
	Ori  R18, 0b1000000
	Sbrc R16, 4
	Ori  R18, 0b00100000
	Sbrc R16, 2
	Ori  R18, 0b00001000
	Sbrc R16, 1
	Ori  R18, 0b00000010
	
	sts portl, r18  ;turns on leds based on result

done:		jmp done


factorial:
		;protect the Z register
		push r30
		push r31
		;  protect r20 r21 r22 r23
		push r20
		push r21
		push r22
		push r23
		; put the stack pointer into the Z register
		in ZH, SPH
		in ZL, SPL
		;get the 2nd parameter pushed on the stack:
		;ldd r21, Z+10
		ldd r23, z+10
	
		cpi r23, 1		;base case:
		breq return		;init = 1, then return
		mov r20, r23
		dec r23
		
		push r23
		call factorial
		pop r23
	
		push r20
		push r25
		call multiply

		pop r20
		pop r23
			
return:
factorial_end:
	pop r23
	pop r22
	pop r21
	pop r20
	pop r31
	pop r30
	sts result, r25
	ret


multiply:
		;protect the Z register
		push r30
		push r31
		;  protect r20 r21 r22 r23 
		push r20
		push r21
		push r22
		push r23
		; put the stack pointer into the Z register
		in ZH, SPH
		in ZL, SPL
	
		; get the 1st parameter pushed on the stack:
		ldd r21, Z+11
		ldi r20, 0x00
		; get the 2nd parameter pushed on the stack:
		ldd r22, Z+10
	
		clr r24		;clears return register
		clr r25



;word multiply (byte factor, byte multiplier) {
;	word answer = 0;
;	while (factor-- > 0) answer += multiplier;
;	return answer;
;}
loop:
addw r24, r25, r20, r21
dec r22
cpi r22, 0x01
brge loop
				
multiply_end: ; This is where we return from the subroutine
		; restore the registers protected on entry
		; into the subroutine
		pop r23
		pop r22
		pop r21
		pop r20
		pop r31
		pop r30

		ret

; The constant, named init, holds the starting number.  
init:	.db 0x03

; This is in the data segment (ie. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor.  
;
.dseg
.org 0x200

result:	.byte 2
