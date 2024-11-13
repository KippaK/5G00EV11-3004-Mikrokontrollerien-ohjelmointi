;
; 4btn4led_asm.asm
;
; Created: 24/10/2024 8.26.56
; Author : antti
;


; Replace with your application code

	.include "m4809def.inc"      ; Include device header file

	.equ SRAM_END = RAMEND        ; Define the end of SRAM, taken from the device definition

	.org 0x0000                  ; Reset vector at address 0
	rjmp RESET                   ; Jump to RESET handler

; RESET handler
RESET:
	; Initialize the stack pointer
	ldi r16, high(SRAM_END)
	sts CPU_SPH, r16
	ldi r16, low(SRAM_END)
	sts CPU_SPl, r16

	; Set inputs and outputs
	; Set PD4 and PD5 as input
	lds r16, PORTD_DIR
	andi r16, 0xCF
	sts PORTD_DIR, r16

	; Set PC6 as input
	lds r16, PORTC_DIR
	andi r16, 0xBF
	sts PORTC_DIR, r16

	; Set PB2 as input and PB0 as output
	lds r16, PORTB_DIR
	andi r16, 0xFB
	ori r16, 0x01
	sts PORTB_DIR, r16

	; Set PF4 ans output
	lds r16, PORTF_DIR
	ori r16, 0x10
	sts PORTF_DIR, r16

	; Set PA1 as output
	lds r16, PORTA_DIR
	ori r16, 0x02
	sts PORTA_DIR, r16

	; Set PE3 as output
	lds r16, PORTE_DIR
	ori r16, 0x08
	sts PORTE_DIR, r16


main_loop:

    ; Set PF4 as the value of PD4
    lds r16, PORTD_IN	; Load PORTD_IN to r16
    lds r17, PORTF_OUT	; Load PORTF_OUT to r17
    andi r16, 0x10		; Mask all bits except bit 4 (PD4)
	cbr r17, 0x10		; Clear bit 4 of PORTF_OUT
    or r17, r16			; Set PORTF_OUT pin 4 HIGH if PORTD_IN pin 4 is HIGH
    sts PORTF_OUT, r17	; Store the modified value back to PORTF_OUT

    ; Set PA1 as the value of PD5
    lds r16, PORTD_IN	; Load PORTD_IN to r16
    lds r17, PORTA_OUT	; Load PORTA_OUT to r17
    andi r16, 0x20		; Mask all bits except bit 5 (PD5)
    lsr r16				; Shift bit 5 right by 1 position to bit 4
    lsr r16				; Shift bit 5 right by 1 position to bit 3
    lsr r16				; Shift bit 5 right by 1 position to bit 2
    lsr r16				; Shift bit 5 right by 1 position to bit 1
	cbr r17, 0x02		; Clear bit 1 of PORTA_OUT
    or r17, r16			; Set PORTA_OUT pin 1 HIGH if PORTD_IN pin 5 is HIGH
    sts PORTA_OUT, r17	; Store the modified value back to PORTA_OUT

	; Set PE3 as the value of PC6
    lds r16, PORTC_IN	; Load PORTC_IN to r16
    lds r17, PORTE_OUT	; Load PORTE_OUT to r17
    andi r16, 0x40		; Mask all bits except bit 6 (PC6)
    lsr r16				; Shift bit 6 right by 1 position to bit 5
    lsr r16				; Shift bit 6 right by 1 position to bit 4
    lsr r16				; Shift bit 6 right by 1 position to bit 3
	cbr r17, 0x08		; Clear bit 3 of PORTE_OUT
    or r17, r16			; Set PORTE_OUT pin 3 HIGH if PORTC_IN pin 6 is HIGH
    sts PORTE_OUT, r17	; Store the modified value back to PORTE_OUT

    ; Set PB0 as the value of PB2
    lds r16, PORTB_IN	; Load PORTB_IN to r16
    lds r17, PORTB_OUT	; Load PORTB_OUT to r17
    andi r16, 0x04		; Mask all bits except bit 2 (PB2)
    lsr r16				; Shift bit 2 right by 1 position to bit 1
    lsr r16				; Shift bit 2 right by 1 position to bit 0
	cbr r17, 0x01		; Clear bit 0 of PORTB_OUT
    or r17, r16			; Set PORTB_OUT pin 0 HIGH if PORTB_IN pin 2 is HIGH
    sts PORTB_OUT, r17	; Store the modified value back to PORTB_OUT

	rjmp main_loop