;
; harjoitustyo_rgb_led_asm.asm
;
; Created: 27/11/2024 13.36.03
; Author : antti
;

; ADC0 configuration
; ADC0_CTRLC configuration
.equ ADC_SAMPCAP = 0b1
.equ ADC_REFSEL = ADC_REFSEL_VDDREF_gc
.equ ADC_PRESC = ADC_PRESC_DIV2_gc
.equ ADC_CTRLC_CONF = (ADC_SAMPCAP | ADC_REFSEL | ADC_PRESC )

; ADC0_CTRLA configuration
.equ ADC_ENABLE = 0b1
.equ ADC_RESSEL = ADC_RESSEL_8BIT_gc
.equ ADC_CTRLA_CONF = (ADC_ENABLE | ADC_RESSEL)

; TCA0 configuration
; TCA0_CTRLA configuration
.equ TCA_SINGLE_CLKSEL_DIV = TCA_SINGLE_CLKSEL_DIV64_gc
.equ TCA0_CTRLA_CONF = (TCA_SINGLE_CLKSEL_DIV | TCA_SINGLE_ENABLE_bm)


; Ports
; LEDS
.equ LED_R_reg = PORTB_base
.equ LED_R_bp = 0x05
.equ LED_R_bm = (1 << LED_R_bp)
.equ LED_R_DIR = LED_R_reg + PORT_DIR_offset
.equ LED_R_OUT = LED_R_reg + PORT_OUT_offset

.equ LED_G_reg = PORTB_base
.equ LED_G_bp = 0x02
.equ LED_G_bm = (1 << LED_G_bp)
.equ LED_G_DIR = LED_G_reg + PORT_DIR_offset
.equ LED_G_OUT = LED_G_reg + PORT_OUT_offset

.equ LED_B_reg = PORTF_base
.equ LED_B_bp = 0x04
.equ LED_B_bm = (1 << LED_B_bp)
.equ LED_B_DIR = LED_B_reg + PORT_DIR_offset
.equ LED_B_OUT = LED_B_reg + PORT_OUT_offset


; Buttons
.equ BTN_POW_reg = PORTA_base
.equ BTN_POW_bp = 0x01
.equ BTN_POW_DIR = BTN_POW_reg + PORT_DIR_offset
.equ BTN_POW_IN = BTN_POW_reg + PORT_IN_offset
.equ BTN_POW_bm = (1 << BTN_POW_bp)

.equ BTN_MOD_reg = PORTE_base
.equ BTN_MOD_bp = 0x03
.equ BTN_MOD_DIR = BTN_MOD_reg + PORT_DIR_offset
.equ BTN_MOD_IN = BTN_MOD_reg + PORT_IN_offset
.equ BTN_MOD_bm = (1 << BTN_MOD_bp)


; Potentiometers
.equ POT_T_reg = PORTD_base
.equ POT_T_bp = 0x03
.equ POT_T_DIR = POT_T_reg + PORT_DIR_offset
.equ POT_T_bm = (1 << POT_T_bp)
.equ POT_T_mc = POT_T_bp

.equ POT_R_reg = PORTD_base
.equ POT_R_bp = 0x02
.equ POT_R_DIR = POT_R_reg + PORT_DIR_offset
.equ POT_R_bm = (1 << POT_R_bp)
.equ POT_R_mc = POT_R_bp

.equ POT_G_reg = PORTD_base
.equ POT_G_bp = 0x01
.equ POT_G_DIR = POT_G_reg + PORT_DIR_offset
.equ POT_G_bm = (1 << POT_G_bp)
.equ POT_G_mc = POT_G_bp

.equ POT_B_reg = PORTD_base
.equ POT_B_bp = 0x00
.equ POT_B_DIR = POT_B_reg + PORT_DIR_offset
.equ POT_B_bm = (1 << POT_B_bp)
.equ POT_B_mc = POT_B_bp

; ADC0_COMMAND
.equ ADC_STCONV = 0b1

; TCA0_CMP
.equ TCA0_SINGLE_CMP0H = TCA0_SINGLE_CMP0
.equ TCA0_SINGLE_CMP0L = TCA0_SINGLE_CMP0H + 0x01
.equ TCA0_SINGLE_CMP1H = TCA0_SINGLE_CMP1
.equ TCA0_SINGLE_CMP1L = TCA0_SINGLE_CMP0H
.equ TCA0_SINGLE_CMP2H = TCA0_SINGLE_CMP2
.equ TCA0_SINGLE_CMP2L = TCA0_SINGLE_CMP2H + 0x01

; LED duty cycle registers
.equ LED_R_dc_reg = TCA0_SINGLE_CMP0L
.equ LED_G_dc_reg = TCA0_SINGLE_CMP1L
.equ LED_B_dc_reg = TCA0_SINGLE_CMP2L


start:
	; Stack pointer init
	ldi r16, high(0x17FF)
	out CPU_SPH, r16
	ldi r16, low(0x17FF)
	out CPU_SPL, r16
	rjmp init


; When calling adc_read, have r24 set as the ADC input pin Selection Bit
; ADC0_RES will be stored in r24 upon return
adc_read:
	; Start conversion
	push r16
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
	pop r16
	ret


; Given two 8 bit brightness values in r24 and r25
; Calculates combined brightness value and returns it to r24
calculate_brightness:
	push r0
	push r1
	mul r24, r25
	mov r24, r1
	clr r25
	pop r1
	pop r0
	ret

; Gets all potentiometer values and stores them into
; r24 (Total), r25 (R), r26 (G) and r27 (B)
get_pot_vals:
	push r16

	ldi r16, POT_R_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov r24, r16

	ldi r16, POT_G_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov r24, r16

	ldi r16, POT_B_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov r24, r16

	ldi r16, POT_T_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov r24, r16

	pop r16


; Gets values from r24 (Total), r25 (R), r26 (G) and r27 (B)
drive_leds_pwm:
	; Push work registers to stack
	push r16
	push r17
	push r18
	push r19
	; Move subroutine variables to work registers
	mov r16, r24
	mov r17, r25
	mov r18, r26
	mov r19, r27

	; Calculate true brightness of each led
	; Red
	mov r25, r16
	mov r24, r17
	rcall calculate_brightness
	mov r17, r24
	; Green
	mov r25, r16
	mov r24, r18
	rcall calculate_brightness
	mov r18, r24
	; Blue
	mov r25, r16
	mov r24, r19
	rcall calculate_brightness
	mov r19, r24

	sts LED_R_dc_reg, r17
	sts LED_G_dc_reg, r18
	sts LED_B_dc_reg, r19

	; Pop work registers from stack
	pop r19
	pop r18
	pop r17
	pop r16
	ret

init:
; ADC init
	ldi r16, ADC_CTRLC_CONF
	sts ADC0_CTRLC, r16
	ldi r16, ADC_CTRLA_CONF
	sts ADC0_CTRLA, r16

; PORT init
	; Button pin I/O directions
	lds r16, BTN_POW_DIR
	ldi r17, BTN_POW_bm
	com r17
	and r16, r17
	sts BTN_POW_DIR, r16

	lds r16, BTN_MOD_DIR
	ldi r17, BTN_MOD_bm
	com r17
	and r16, r17
	sts BTN_MOD_DIR, r16


	; LED pin I/O directions
	lds r16, POT_T_DIR
	ldi r17, POT_T_bm
	com r17
	and r16, r17
	sts POT_T_DIR, r16

	lds r16, POT_R_DIR
	ldi r17, POT_R_bm
	com r17
	and r16, r17
	sts POT_R_DIR, r16

	lds r16, POT_G_DIR
	ldi r17, POT_G_bm
	com r17
	and r16, r17
	sts POT_G_DIR, r16

	lds r16, POT_B_DIR
	ldi r17, POT_B_bm
	com r17
	and r16, r17
	sts POT_B_DIR, r16

	; LED pin I/O directions
	lds r16, LED_R_DIR
	ldi r17, LED_R_bm
	or r16, r17
	sts LED_R_DIR, r16

	lds r16, LED_G_DIR
	ldi r17, LED_G_bm
	or r16, r17
	sts LED_G_DIR, r16

	lds r16, LED_B_DIR
	ldi r17, LED_B_bm
	or r16, r17
	sts LED_B_DIR, r16

; TCA0 init
	; Configure PORTMUX to route TCA outputs to PORTB
	ldi r16, PORTMUX_TCA0_PORTB_gc
	sts PORTMUX_TCAROUTEA, r16
	; Set the PWM period (frequency)
	ldi r16, 0xFF
	sts TCA0_SINGLE_PER, r16
	; Set TCA0_CTRLA confifuration
	ldi r16, TCA0_CTRLA_CONF
	sts TCA0_SINGLE_CTRLA, r16


; Initial values
	ldi r31, 0x00 ; RGB LED mode value

	rjmp loop


mode_manual:
	rcall get_pot_vals
	rcall drive_leds_pwm
	ret

mode_breath:
	ret

mode_rainbow:
	ret

loop:
	mov r16, r31
	andi r16, 0x03
	cpi r16, 0x00
	breq mode_manual
	cpi r16, 0x01
	breq mode_breath
	cpi r16, 0x02
	breq mode_rainbow


	rjmp loop