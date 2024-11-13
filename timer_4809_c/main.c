/*
 * timer_4809_c.c
 *
 * Created: 07/11/2024 11.28.26
 * Author : antti
 */ 

#include <avr/io.h>

#define TCA0_SINGLE_CNT_MAX 65535

void setupTimer0(void) {
	TCA0.SINGLE.CTRLA = 0;
	TCA0.SINGLE.CTRLB = 0;
	TCA0.SINGLE.PER = 0xFFFF;
	TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV1_gc | TCA_SINGLE_ENABLE_bm;
}

uint16_t readTimer0(void) {
	return TCA0.SINGLE.CNT;
}

void setup() {
	setupTimer0();
	PORTB.DIR = 0xFF;
}

void loop() {
	uint16_t current_timer_value = readTimer0();
	        
	if (current_timer_value % 2 == 0) {
		PORTB.OUT = 0xFF;
	}
	else {
		PORTB.OUT = 0x00;
	}
}

int main(void)
{
    /* Replace with your application code */
    setup();
	while (1) 
    {
		loop();
    }
}

