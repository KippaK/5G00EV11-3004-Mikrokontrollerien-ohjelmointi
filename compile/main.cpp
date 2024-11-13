#include <avr/io.h>
#include <util/delay.h>

// Initialize ADC
void ADC_init()
{
	// Set reference voltage and select ADC channel 0
	ADMUX |= (1 << REFS0) | (0b100 << MUX0);
	
	// Enable ADC
	ADCSRA |= (1 << ADEN);
	
	// Disable high-speed mode (ADCSRB)
	ADCSRB = 0x00;
}

// Read ADC value
uint16_t ADC_read()
{
	// Reset MUX channel selection
	ADMUX &= ~(0b1111 << MUX0);
	
	// Set MUX channel to 0
	ADMUX |= 0b0 << MUX0;
	
	// Start the conversion
	ADCSRA |= (1 << ADSC);
	
	// Wait for the conversion to complete
	while (ADCSRA & (1 << ADSC))
	{
		// Wait here until ADSC bit is cleared
	}
	
	// Return the ADC value
	return ADC;
}

void setup()
{
	// Configure PORTD pins 2, 3, 4 as output (LEDs for debugging)
	DDRD |= 0b111 << 2;

	// Initialize ADC
	ADC_init();
}

void loop()
{
	// Read the ADC value
	uint16_t adc_val = ADC_read();
	
	// You can toggle PORTD pins for debugging using LEDs
	if (adc_val > 512)
	{
		// Set PORTD pins if ADC value is greater than 512
		PORTD |= (1 << 2);  // Turn on PD2 LED
	}
	else
	{
		// Clear PORTD pins if ADC value is less than 512
		PORTD &= ~(1 << 2); // Turn off PD2 LED
	}
	
	// Small delay to slow down the loop
}

int main(void)
{
	// Call setup function
	setup();
	
	// Main loop
	while (1)
	{
		loop();
	}
}
