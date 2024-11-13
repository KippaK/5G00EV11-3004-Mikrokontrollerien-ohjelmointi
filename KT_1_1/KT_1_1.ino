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
  while (ADCSRA & B01000000)
  {
    ;
  }
  return ADC;
}

void setup()
{
  Serial.begin(9600);
  DDRD |= 0b111 << 2;
  ADC_init();
}

void loop()
{
  int adc_val = ADC_read();
  Serial.println(adc_val);

  delay(300);
}
