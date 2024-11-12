;
; adc_4809_asm.asm
;
; Created: 12/11/2024 14.18.11
; Author : antti
;

; ADC0_CTRLC configuration
.equ ADC_SAMPCAP = 0b1
.equ ADC_REFSEL = ADC_REFSEL_VDDREF_gc
.equ ADC_PRESC = ADC_PRESC_DIV2_gc
.equ ADC_CTRLC_CONF = (ADC_SAMPCAP | ADC_REFSEL | ADC_PRESC )

; ADC0_MUXPOS configuration
.equ ADC_PIN = ADC_MUXPOS_AIN0_gc
.equ ADC_MUXPOS_CONF = (ADC_PIN)

; ADC0_CTRLA configuration
.equ ADC_ENABLE = 0b1
.equ ADC_RESSEL = ADC_RESSEL_8BIT_gc
.equ ADC_CTRLA_CONF = (ADC_ENABLE | ADC_RESSEL)

; ADC0_COMMAND
.equ ADC_STCONV = 0b1

.equ LED0_REQ_DIR = PORTF_DIR
.equ LED1_REQ_DIR = PORTA_DIR
.equ LED2_REQ_DIR = PORTE_DIR
.equ LED3_REQ_DIR = PORTB_DIR

.equ LED0_REQ_OUT = PORTF_OUT
.equ LED1_REQ_OUT = PORTA_OUT
.equ LED2_REQ_OUT = PORTE_OUT
.equ LED3_REQ_OUT = PORTB_OUT

.equ LED0_MASK = 0x10
.equ LED1_MASK = 0x02
.equ LED2_MASK = 0x08
.equ LED3_MASK = 0x01

init:
	; ADC init
	ldi r16, ADC_CTRLC_CONF
	sts ADC0_CTRLC, r16
	ldi r16, ADC_MUXPOS_CONF
	sts ADC0_MUXPOS, r16
	ldi r16, ADC_CTRLA_CONF
	sts ADC0_CTRLA, r16

	; Port Init
	ldi r16, LED0_MASK
	sts LED0_REQ_DIR, r16
	ldi r16, LED1_MASK
	sts LED1_REQ_DIR, r16
	ldi r16, LED2_MASK
	sts LED2_REQ_DIR, r16
	ldi r16, LED3_MASK
	sts LED3_REQ_DIR, r16

	rjmp loop

adc_read:
	; Start conversion
	ldi r16, ADC_STCONV
	sts ADC0_COMMAND, r16

wait_for_conversion:
	lds r16, ADC0_INTFLAGS
	sbrs r16, ADC_RESRDY_bp
	rjmp wait_for_conversion
	; clear result ready interrupt flag
	ldi r16, (1 << ADC_RESRDY_bp)
	sts ADC0_INTFLAGS, r16


	lds r24, ADC0_RES
	clr r25
	ret

drive_leds:
	lds r20, LED0_REQ_OUT
	cbr r20, LED0_MASK
	lds r21, LED1_REQ_OUT
	cbr r21, LED1_MASK
	lds r22, LED2_REQ_OUT
	cbr r22, LED2_MASK
	lds r23, LED3_REQ_OUT
	cbr r23, LED3_MASK

	sbrc r24, 7
	sbr r20, LED0_MASK
	sbrc r24, 6
	sbr r21, LED1_MASK
	sbrc r24, 5
	sbr r22, LED2_MASK
	sbrc r24, 4
	sbr r23, LED3_MASK

	sts LED0_REQ_OUT, r20
	sts LED1_REQ_OUT, r21
	sts LED2_REQ_OUT, r22
	sts LED3_REQ_OUT, r23

	ret

loop:
	rcall adc_read
	rcall drive_leds
	rjmp loop