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
	ldi r18, 0b00000000

	ldi r17, 0b00001000
	and r17, r16
	or r18, r17
	lsl r18

	ldi r17, 0b00000100
	and r17, r16
	or r18, r17
	lsl r18

	ldi r17, 0b00000010
	and r17, r16
	or r18, r17
	lsl r18

	ldi r17, 0b00000001
	and r17, r16
	or r18, r17
	lsl r18

	sts portl, r18;turns on leds based on result

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
; Didn't follow to see where the data into R20 R21 (LSB) came from, but suppose you can
; do this directly on the caller routine, considering R22 is the multiplier, and considering
; AtMegas have in fact the MUL instruction:
; R20:R21 value to be multiplied by R22
; Result on R24:R25
; This multiplying 16x8 bits routine is much shorter and faster.

		Mul  R21, R22
		Movw R24:R25, R0:R1
		Mul  R20, R22
		Add  R24, R0
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
