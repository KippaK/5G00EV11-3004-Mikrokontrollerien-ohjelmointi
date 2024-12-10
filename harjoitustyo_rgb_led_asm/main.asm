;
; harjoitustyo_rgb_led_asm.asm
;
; Created: 27/11/2024 13.36.03
; Author : antti
;

.INCLUDE "m4809def.inc"

.org 0
jmp start
.org PORTA_PORT_vect
jmp PORTA_ISR
.org TCB0_INT_vect
jmp TCB0_ISR

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
.equ TCA_SINGLE_CLKSEL_DIV = TCA_SINGLE_CLKSEL_DIV64_gc
.equ TCA0_CMPxEN = (TCA_SINGLE_CMP0EN_bm | TCA_SINGLE_CMP1EN_bm | TCA_SINGLE_CMP2EN_bm)
.equ TCA0_CTRLA_CONF = (TCA_SINGLE_CLKSEL_DIV | TCA_SINGLE_ENABLE_bm)
.equ TCA0_CTRLB_CONF = (TCA0_CMPxEN | TCA_SINGLE_WGMODE_SINGLESLOPE_gc)

; TCB configuration
.equ TCB0_CLKSEL = TCB_CLKSEL_CLKDIV2_gc
.equ TCB0_CNT_MODE = TCB_CNTMODE_INT_gc
.equ TCB0_CTRLA_CONF = (TCB0_CLKSEL | TCB_ENABLE_bm)
.equ TCB0_CTRLB_CONF = (TCB0_CNT_MODE)
.equ TCB0_INTCTRL_CONF = TCB_CAPT_bm

; Button interrupt configuration
.equ PORT_ISC = PORT_ISC_RISING_gc

; Ports
; LEDS
.equ LED_R_reg = PORTB_base
.equ LED_R_bp = 0x00
.equ LED_R_bm = (1 << LED_R_bp)
.equ LED_R_DIR = LED_R_reg + PORT_DIR_offset
.equ LED_R_OUT = LED_R_reg + PORT_OUT_offset

.equ LED_G_reg = PORTB_base
.equ LED_G_bp = 0x01
.equ LED_G_bm = (1 << LED_G_bp)
.equ LED_G_DIR = LED_G_reg + PORT_DIR_offset
.equ LED_G_OUT = LED_G_reg + PORT_OUT_offset

.equ LED_B_reg = PORTB_base
.equ LED_B_bp = 0x02
.equ LED_B_bm = (1 << LED_B_bp)
.equ LED_B_DIR = LED_B_reg + PORT_DIR_offset
.equ LED_B_OUT = LED_B_reg + PORT_OUT_offset


; Buttons
.equ BTN_POW_reg = PORTA_base
.equ BTN_POW_bp = 1
.equ BTN_POW_PIN_offset = (PORT_PIN0CTRL_offset + BTN_POW_bp)
.equ BTN_POW_DIR = BTN_POW_reg + PORT_DIR_offset
.equ BTN_POW_IN = BTN_POW_reg + PORT_IN_offset
.equ BTN_POW_bm = (1 << BTN_POW_bp)
.equ BTN_POW_INTFLAGS = BTN_POW_reg + PORT_INTFLAGS_offset

.equ BTN_MOD_reg = PORTA_base
.equ BTN_MOD_bp = 0
.equ BTN_MOD_PIN_offset = (PORT_PIN0CTRL_offset + BTN_MOD_bp)
.equ BTN_MOD_DIR = BTN_MOD_reg + PORT_DIR_offset
.equ BTN_MOD_IN = BTN_MOD_reg + PORT_IN_offset
.equ BTN_MOD_bm = (1 << BTN_MOD_bp)
.equ BTN_MOD_INTFLAGS = BTN_MOD_reg + PORT_INTFLAGS_offset


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

; TCA0_CMPBUF
.equ TCA0_SINGLE_CMP0L = TCA0_SINGLE_CMP0
.equ TCA0_SINGLE_CMP0H = TCA0_SINGLE_CMP0L + 0x01
.equ TCA0_SINGLE_CMP1L = TCA0_SINGLE_CMP1
.equ TCA0_SINGLE_CMP1H = TCA0_SINGLE_CMP1L
.equ TCA0_SINGLE_CMP2L = TCA0_SINGLE_CMP2
.equ TCA0_SINGLE_CMP2H = TCA0_SINGLE_CMP2L + 0x01

.equ TCA0_SINGLE_PERL = TCA0_SINGLE_PER
.equ TCA0_SINGLE_PERH = (TCA0_SINGLE_PERL + 0x01)
.equ TCA0_SINGLE_PERL_val = 0xFF
.equ TCA0_SINGLE_PERH_val = 0x00

.equ PORTMUX_TCA0_reg = PORTMUX_TCA0_PORTB_gc

; LED duty cycle registers
.equ LED_R_dc_L = TCA0_SINGLE_CMP0L
.equ LED_R_dc_H = (LED_R_dc_L + 1)
.equ LED_G_dc_L = TCA0_SINGLE_CMP1L
.equ LED_G_dc_H = (LED_G_dc_L + 1)
.equ LED_B_dc_L = TCA0_SINGLE_CMP2L
.equ LED_B_dc_H = (LED_B_dc_L + 1)


; Registers
.def pot_t_val_reg = r2
.def pot_r_val_reg = r3
.def pot_g_val_reg = r4
.def pot_b_val_reg = r5
.def pow_state_val_reg = r6
.def mode_state_val_reg = r7
.def mode_step_val_reg = r8

start:
	; Stack pointer init
	ldi r16, high(0x17FF)
	out CPU_SPH, r16
	ldi r16, low(0x17FF)
	out CPU_SPL, r16
	rjmp init


; When calling adc_read, have r24 set as the ADC input pin Selection Bit
; 8-bit ADC0_RES will be stored in r24 upon return
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
; Also does bitwise and between calculated value and powerstate (pow_state_val_reg)
; f(r24, r25, pow_state_val_reg) = (x * y / 256) & pow_state_val_reg
calculate_brightness:
	mul r24, r25
	mov r24, r1
	and r24, pow_state_val_reg
	clr r25
	ret

; Reads Total potentiometer val and stores it into pot_t_val_reg
get_pot_t_val:
	push r16
	ldi r16, POT_T_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov pot_t_val_reg, r24
	pop r16
	ret


; Reads Total potentiometer val and stores it into pot_r_val_reg
get_pot_r_val:
	push r16
	ldi r16, POT_R_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov pot_r_val_reg, r24
	pop r16
	ret


; Reads Total potentiometer val and stores it into pot_g_val_reg
get_pot_g_val:
	push r16
	ldi r16, POT_G_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov pot_g_val_reg, r24
	pop r16
	ret


; Reads Total potentiometer val and stores it into pot_b_val_reg
get_pot_b_val:
	push r16
	ldi r16, POT_B_mc
	sts ADC0_MUXPOS, r16
	rcall adc_read
	mov pot_b_val_reg, r24
	pop r16
	ret


; Gets all potentiometer values and stores them into
; pot_t_val_reg (Total), pot_r_val_reg (R), pot_g_val_reg (G) and pot_b_val_reg (B)
get_pot_vals:
	rcall get_pot_t_val
	rcall get_pot_r_val
	rcall get_pot_g_val
	rcall get_pot_b_val
	ret


; Gets rgb potentiometer values and stores them into
; pot_r_val_reg (R), pot_g_val_reg (G) and pot_b_val_reg (B)
get_rgb_vals:
	rcall get_pot_r_val
	rcall get_pot_g_val
	rcall get_pot_b_val
	ret

; Gets value from pot_t_val_reg and stores it into TCB0_CCMPH
set_mode_speed:
	mov r16, pot_t_val_reg
	ldi r17, 0xFF
	sts TCB0_CCMPL, r17
	sts TCB0_CCMPH, r16
	ret

update_mode_speed:
	rcall get_pot_t_val
	rcall set_mode_speed
	ret

; Gets values from pot_t_val_reg (Total), pot_r_val_reg (R), pot_g_val_reg (G) and pot_b_val_reg (B)
drive_leds_pwm:
	; Push work registers to stack
	push r16
	push r17
	push r18
	push r19
	; Move subroutine variables to work registers
	mov r16, pot_t_val_reg
	mov r17, pot_r_val_reg
	mov r18, pot_g_val_reg
	mov r19, pot_b_val_reg
	and r16, pow_state_val_reg
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

	ldi r24, 0x00
	sts LED_R_dc_L, r17
	sts LED_R_dc_H, r24
	sts LED_G_dc_L, r18
	sts LED_G_dc_H, r24
	sts LED_B_dc_L, r19
	sts LED_B_dc_H, r24


	; Pop work registers from stack
	pop r19
	pop r18
	pop r17
	pop r16
	ret

PORTA_ISR:
	; Check for power button interrupt
	lds r16, BTN_POW_INTFLAGS
	andi r16, BTN_POW_bm
	cpi r16, BTN_POW_bm
	breq POWER_ISR
	
	; Check for mode button interrupt
	lds r16, BTN_MOD_INTFLAGS
	andi r16, BTN_MOD_bm
	cpi r16, BTN_MOD_bm
	breq MODE_ISR

	; Reset porta interrupt flags
	lds r16, PORTA_INTFLAGS
	sts PORTA_INTFLAGS, r16
	reti
	
POWER_ISR:
	com pow_state_val_reg
	ldi r16, BTN_POW_bm
	sts BTN_POW_INTFLAGS, r16
	reti

MODE_ISR:
	inc mode_state_val_reg
	lds r16, BTN_MOD_bm
	sts BTN_MOD_INTFLAGS, r16
	reti

TCB0_ISR:
	lds r16, TCB0_INTFLAGS
	sbrs r16, 0
	reti
	sts TCB0_INTFLAGS, r16
	inc mode_step_val_reg
	reti

adc_init:
	ldi r16, ADC_CTRLC_CONF
	sts ADC0_CTRLC, r16
	ldi r16, ADC_CTRLA_CONF
	sts ADC0_CTRLA, r16
	ret

port_init:
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
	ret

tca_init:
	; Configure PORTMUX to route TCA outputs to PORTB
	ldi r16, PORTMUX_TCA0_reg
	sts PORTMUX_TCAROUTEA, r16
	; Set the PWM period (frequency)
	ldi r16, TCA0_SINGLE_PERL_val
	sts TCA0_SINGLE_PERL, r16
	ldi r16, TCA0_SINGLE_PERH_val
	sts TCA0_SINGLE_PERH, r16
	; Set TCA0_CTRLA confifuration
	ldi r16, TCA0_CTRLA_CONF
	sts TCA0_SINGLE_CTRLA, r16
	ldi r16, TCA0_CTRLB_CONF
	sts TCA0_SINGLE_CTRLB, r16
	ret

tcb_init:
	ldi r16, TCB0_CTRLA_CONF
	sts TCB0_CTRLA, r16
	ldi r16, TCB0_CTRLB_CONF
	sts TCB0_CTRLB, r16
	ldi r16, TCB0_INTCTRL_CONF
	sts TCB0_INTCTRL, r16
	ldi r16, 0xFF
	sts TCB0_CCMPL, r16
	sts TCB0_CCMPH, r16
	ret

timer_init:
	rcall tca_init
	rcall tcb_init
	ret

interrupt_init:
    ldi r17, PORT_ISC ; Interrupt on rising edge
    sts BTN_POW_reg + BTN_POW_PIN_offset, r17
	sts BTN_MOD_reg + BTN_MOD_PIN_offset, r17

    ret

init:
	rcall adc_init
	rcall port_init
	rcall timer_init
	rcall interrupt_init
; Initial values
	ldi r16, 0xFF ; LED Power state
	mov pow_state_val_reg, r16
	ldi r16, 0x00
	mov mode_state_val_reg, r16
	mov mode_step_val_reg, r16
	sei

	rjmp loop

mode_manual:
	rcall get_pot_vals
	rcall drive_leds_pwm
	rjmp loop

mode_breath:
	rcall update_mode_speed
	mov r16, mode_step_val_reg
	; r17 -> (255 - mode_step_val_reg)
	ldi r17, 0xFF
	sub r17, r16
	; if r16 >= 128 -> move r17 into r16
	sbrc r16, 7
	mov r16, r17
	ldi r17, 0x02
	muls r16, r17
	rcall get_rgb_vals
	rcall drive_leds_pwm
	rjmp loop

loop:
	mov r16, mode_state_val_reg
	; DEBUG
;	mov r17, pot_t_val_reg
;	cpi r17, 0xFF
;	breq debug
	; DEBUG END
	andi r16, 0x01
	cpi r16, 0x00
	breq mode_manual
	cpi r16, 0x01
	breq mode_breath
	rjmp loop

debug:
	nop
	rjmp loop