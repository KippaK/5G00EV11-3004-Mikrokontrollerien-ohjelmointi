/*
 * adc_4809_c.c
 *
 * Created: 06/11/2024 13.22.33
 * Author : antti
 */ 

#include <avr/io.h>
#include <util/delay.h>

#define ADC_CHANNEL 0  // Using AIN0 as the input

#define VREF_ADC0REFSEL_VDD_gc (0x1 << 4)

// Function to initialize the ADC
void ADC_init(void) {
	
	// Set the reference voltage to 2.5V (or change as needed)
	 // VREF.CTRLA |= VREF_ADC0REFSEL_4V34_gc;

	// Set the ADC prescaler to divide the clock by 2 for desired speed and reference voltage to VDD
	ADC0.CTRLC = ADC_PRESC_DIV2_gc | VREF_ADC0REFSEL_VDD_gc;
	
	// Select the input channel (e.g., AIN0)
	ADC0.MUXPOS = ADC_MUXPOS_AIN0_gc + ADC_CHANNEL;

	// Enable the ADC
	ADC0.CTRLA = ADC_ENABLE_bm;
}

// Function to read the ADC value
uint16_t ADC_read(void) {
	// Start a conversion
	ADC0.COMMAND = ADC_STCONV_bm;

	// Wait for the conversion to complete
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm));

	// Clear the interrupt flag
	ADC0.INTFLAGS |= ADC_RESRDY_bm;

	// Return the ADC result
	return ADC0.RES;
}

void drive_leds(uint8_t val) {
	uint8_t states = val >> 4;
	PORTF.OUT &= ~(((~states >> 3) & 0b1) << 4);
	PORTA.OUT &= ~(((~states >> 2) & 0b1) << 1);
	PORTE.OUT &= ~(((~states >> 1) & 0b1) << 3);
	PORTB.OUT &= ~(((~states >> 0) & 0b1) << 0);
  
	// Drive Led pins high if corresponding state is 1
	PORTF.OUT |= ((states >> 3) & 0b1) << 4;
	PORTA.OUT |= ((states >> 2) & 0b1) << 1;
	PORTE.OUT |= ((states >> 1) & 0b1) << 3;
	PORTB.OUT |= ((states >> 0) & 0b1) << 0;
}

int main(void) {
	// Initialize the ADC
	ADC_init();
	PORTF.DIR |= (0b1 << 4); 
	PORTA.DIR |= (0b1 << 1);
	PORTE.DIR |= (0b1 << 3);
	PORTB.DIR |= (0b1 << 0);
	uint16_t adc_result = 0;
	// Main loop
	while (1) {
		// Read the ADC value
		adc_result = ADC_read();
		adc_result = adc_result >> 2;
		drive_leds(adc_result);
	}
}
