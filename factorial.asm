;
; CSc 230 Assignment 5 Part 2 Programming
;   Factorial
;  
; Chris Warren
;	Date: November 15th 2017

.include "m2560def.inc"

.cseg

; Just showing below a different way to run assembly code to create factorial from 1! to 10!, using a short program.
; Not showing result on LEDs, since it is 24 bits wide. 
; Input at R2, value decimal 1~10, representing 1! to 10!
; Output Result 1~3628800 (0x375F00) at: R20:R21:R22 (LSB)
; Temporary Multiplication Middle Byte: R17
; The routine moves the number! to the result bytes, then multiply it by number!-1 and repeat until it becomes 1.
; The multiplication 24x8 routine is the most short possible, saving registers and clock cycles.
; The whole routine only use registers, no RAM is used.
; The RCALL can be avoided, since the routine is straight forward, entry and exit, no stack used.
; This is basically the same as your version, with 24 bits answer, no LED display.
; Wagner Lipnharski Sep/22/2021

      ldi  r16, low(RAMEND)
      out  SPL, r16
      ldi  r16, high(RAMEND)
      out  SPH, r16

      Mov  R16, R2      ; Get Value to factor
      Rcall A0          ; Call Factorial
      ...
      
      
A0:   Clr  R20          ; Results = Number!
      Clr  R21          ;
      Ldi  R22, R16     ; 

A1:   Dec  R16          ; Number! - 1
      Cpi  R16,1        ; If 1 then ended
      Brne A2           ;
      Ret
                        ; This multiplication 24x8 is tricky, fast and save bytes
A2:   Mul  R22, R16     ; Mul Result LSB x Number!-1
      Mov  R22, R0      ; LSB Mul to Result LSB Byte 
      Mov  R17, R1      ; MSB Mul to Temporary Middle Byte

      Mul  R20, R16     ; Mul Result MSB x Number!-1
      Mov  R20, R0      ; LSB Mul to MSB Result Byte, ignore MSB Mul, will be zero
      
      Mul  R21, R16     ; Mul Result Middle x Number!-1
      Mov  R21, R0      ; LSB Mul to Result Middle Byte
      Add  R21, R17     ; Add Temporary Middle to Result Middle Byte
      Adc  R20, R1      ; Add MSB Mul with Carry to Result MSB Byte
      
      Rjmp A1
