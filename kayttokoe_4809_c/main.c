/*
 * kayttokoe_4809_c.c
 *
 * Created: 04/12/2024 12.21.50
 * Author : antti
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>


#define ADC_CHANNEL 0  // Using AIN0 as the input
#define ADC_MAX_VAL 0x03FF

volatile int state = 1;

void ADC_init(void) {
	VREF.CTRLA |= VREF_ADC0REFSEL_4V34_gc;
	ADC0.CTRLC = ADC_PRESC_DIV2_gc;
	ADC0.MUXPOS = ADC_MUXPOS_AIN0_gc + ADC_CHANNEL;
	ADC0.CTRLA = ADC_ENABLE_bm;
}

void setup()
{
	ADC_init();
	// PB0, PB1, PB2 as output (LEDs)
	PORTB.DIRSET = PIN0_bm | PIN1_bm | PIN2_bm;
	// PA0 as input (button)
	PORTA.DIRCLR = PIN0_bm;
	PORTA.PIN0CTRL = PORT_ISC_RISING_gc;
	// PD0 as input (potentionmeter)
	PORTD.DIRCLR = PIN0_bm;	
	sei();
}

ISR(PORTA_PORT_vect) {
	_delay_ms(20);
	if (PORTA.INTFLAGS & PIN0_bm) {  // Check if the interrupt is from PIN2
		if (state == 1) { state = 0; }
		else { state = 1; }
		PORTA.INTFLAGS = PIN0_bm;  // Clear the interrupt flag
	}
}

uint16_t ADC_read(void) {
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm));
	ADC0.INTFLAGS |= ADC_RESRDY_bm;
	return ADC0.RES;
}

void loop()
{
	uint16_t adc_val = ADC_read();
	double voltage  = ((double)adc_val / ADC_MAX_VAL) * 12;
	if (state == 0) {
		PORTB.OUTCLR = 0x07;
	}
	else if (voltage < 4) {
		PORTB.OUTCLR = 0x07;
		PORTB.OUTSET = 0x01;
	} else if (voltage < 8) {
		PORTB.OUTCLR = 0x07;
		PORTB.OUTSET = 0x02;
	} else {
		PORTB.OUTCLR = 0x07;
		PORTB.OUTSET = 0x04;
	}
}


int main(void)
{
	setup();
	while (1) 
    {
		loop();
    }
}

