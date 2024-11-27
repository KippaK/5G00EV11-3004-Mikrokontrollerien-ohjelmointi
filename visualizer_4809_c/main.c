/*
 * visualizer_4809_c.c
 *
 * Created: 20/11/2024 15.22.56
 * Author : antti
 */ 

#include <avr/io.h>


#include <avr/io.h>
#include <util/delay.h>

#define ADC_CHANNEL 0  // Using AIN0 as the input

#define VREF_ADC0REFSEL_VDD_gc (0x1 << 4)

void uart_init() {
	uint16_t baud = F_CPU / 16 / 9600 - 1; // Calculate baud rate
	USART0.BAUD = baud;
	USART0.CTRLB = USART_TXEN_bm; // Enable transmitter
}

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

// Send a single character over UART
void uart_send_char(char c) {
	while (!(USART0.STATUS & USART_DREIF_bm)); // Wait until ready to send
	USART0.TXDATAL = c;
}

// Send a string over UART
void uart_send_string(const char* str) {
	while (*str) {
		uart_send_char(*str++);
	}
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


int main(void) {
	// Initialize the ADC
	ADC_init();
	uint16_t adc_result = 0;
	char buf[5];
	// Main loop
	while (1) {
		// Read the ADC value
		adc_result = ADC_read();
		adc_result = adc_result >> 2;
		itoa(adc_result, buf, 10);
		uart_send_string("ADC result = ");
		uart_send_string(buf);
		uart_send_char('\n');
	}
}
