/*
 * interrupt_vector_4809_c.c
 *
 * Created: 20/11/2024 13.24.54
 * Author : antti
 */ 

#include <avr/sfr_defs.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#define RTC_PRESCALER	RTC_PRESCALER_DIV1_gc
#define RTC_CLKSEL_VAL	RTC_CLKSEL_INT32K_gc
#define RTC_PER_VAL		0x0FFF

void rtc_setup() {
	RTC.CTRLA |= RTC_RUNSTDBY_bm | RTC_PRESCALER | RTC_RTCEN_bm;
	RTC.INTCTRL |= RTC_OVF_bm;
	RTC.CLKSEL |= RTC_CLKSEL_VAL;
	RTC.PERL = (RTC_PER_VAL & 0xFF);
	RTC.PERH = (RTC_PER_VAL >> 8);
	while (RTC.STATUS & RTC_CTRLABUSY_bm);
}

void setup() {
	rtc_setup();
 	CPUINT.LVL1VEC = 0x06;
	sei();
	PORTB.DIR |= 0x01;
}

ISR(RTC_CNT_vect) {
	RTC.INTFLAGS = RTC_OVF_bm;
	PORTB.OUTTGL = PIN0_bm;
}


void loop() {

}

int main(void)
{
	setup();
    while (1) 
    {
		loop();
    }
}

