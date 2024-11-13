/*
 * compile-test.c
 *
 * Created: 18/09/2024 13.41.54
 * Author : antti
 */ 

#include <avr/io.h>

void ADC_init()
{
  ADMUX |= (1 << REFS0) | (0b100 << MUX0);
  ADCSRA |= (1 << ADEN) ;
  ADCSRB = 0x00;
}

uint16_t ADC_read()
{
  // Resetoidaan MUX kanava
  ADMUX &= ~(0b1111 << MUX0);
  // Asetetaan uusi MUX kanava
  ADMUX |= 0b0 << MUX0;
  
  //aloitetaan muunnos
  ADCSRA |= (1 << ADSC);
  while (ADCSRA & 0b01000000)
  {
    ;
  }
  return ADC;
}

void setup()
{
  DDRD |= 0b111 << 2;
  ADC_init();
}

void loop()
{
  int adc_val = ADC_read();
}


int main(void)
{
	setup();
	while (1) 
    {
		loop();
    }
}

