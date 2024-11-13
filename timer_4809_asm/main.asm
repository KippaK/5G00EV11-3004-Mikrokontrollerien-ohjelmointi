;
; timer_4809_asm.asm
;
; Created: 13/11/2024 13.23.34
; Author : antti
;


; Replace with your application code

; Clock selection
.equ TCA_SINGLE_CLKSEL = TCA_SINGLE_CLKSEL_DIV256_gc
.equ TCA_SINGLE_CTRLA_CONF = (TCA_SINGLE_CLKSEL | TCA_SINGLE_ENABLE_bm)

.equ LED_REG_DIR = PORTB_DIR
.equ LED_REG_DIRSET = LED_REG_DIR + 1
.equ LED_REG_OUT = PORTB_OUT
.equ LED_PIN_b = 0
.equ LED_PIN_bm = (1 << LED_PIN_b)

.equ TCA0_SINGLE_CNTH = 0x0A21

start:
	; Stack pointer init
	ldi r16, high(0x17FF)
	out CPU_SPH, r16
	ldi r16, low(0x17FF)
	out CPU_SPL, r16
	rjmp init

tca0_init:
	push r16
	ldi r16, 0x00
	sts TCA0_SINGLE_CTRLA, r16
	sts TCA0_SINGLE_CTRLB, r16
	; TCA top count
	ldi r16, 0xFF
	sts TCA0_SINGLE_PER, r16
	sts TCA0_SINGLE_PER + 1, r16
	ldi r16, TCA_SINGLE_CTRLA_CONF
	sts TCA0_SINGLE_CTRLA, r16
	pop r16
	ret

port_init:
	push r16
	ldi r16, LED_PIN_bm
	sts PORTB_DIRSET, r16
	pop r16
	ret

init:
	rcall tca0_init
	rcall port_init
	rjmp loop

read_tca0_cnth:
	lds r24, TCA0_SPLIT_LCNT
	lds r24, TCA0_SPLIT_HCNT
	ret

drive_led:
	push r16
	push r17
	mov r16, r24
	lds r17, LED_REG_OUT
	cbr r17, LED_PIN_bm
	andi r16, LED_PIN_bm
	or r16, r17
	sts LED_REG_OUT, r16
	pop r17
	pop r16


loop:
	rcall read_tca0_cnth
	mov r16, r24
	sbrc r16, 4
	ldi r24, 0xFF
	sbrs r16, 4
	ldi r24, 0x00
	rcall drive_led

	rjmp loop
