;
; harjoitustyo_rgb_led_asm.asm
;
; Created: 27/11/2024 13.36.03
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

; LEDS
.equ LED_R_reg = 0
.equ LED_R_bm = 0
.equ LED_G_reg = 0
.equ LED_G_bm = 0
.equ LED_B_reg = 0
.equ LED_B_bm = 0

; Button
.equ BTN_reg = 0
.equ BTN_bm = 0

; Potentiometers
.equ POT_T_reg = 0
.equ POT_T_bm = 0
.equ POT_T_mp = 0
.equ POT_R_reg = 0
.equ POT_R_bm = 0
.equ POT_R_mp = 0
.equ POT_G_reg = 0
.equ POT_G_bm = 0
.equ POT_G_mp = 0
.equ POT_B_reg = 0
.equ POT_B_bm = 0
.equ POT_B_mp = 0

; ADC0_COMMAND
.equ ADC_STCONV = 0b1

; Replace with your application code
init:
	; ADC init
	ldi r16, ADC_CTRLC_CONF
	sts ADC0_CTRLC, r16
	ldi r16, ADC_MUXPOS_CONF
	sts ADC0_MUXPOS, r16
	ldi r16, ADC_CTRLA_CONF
	sts ADC0_CTRLA, r16



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