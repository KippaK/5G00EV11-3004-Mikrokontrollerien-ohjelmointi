void setup() {
  // input D4,D5,C6,B2
  PORTD.DIR &= ~(0b1 << 4);
  PORTD.DIR &= ~(0b1 << 5);
  PORTC.DIR &= ~(0b1 << 6);
  PORTB.DIR &= ~(0b1 << 2);
  // output F4,A1,E3,B0
  PORTF.DIR |= (0b1 << 4); 
  PORTA.DIR |= (0b1 << 1);
  PORTE.DIR |= (0b1 << 3);
  PORTB.DIR |= (0b1 << 0);
  Serial.begin(9600);
}

void loop() {
  int states = 
    ((PORTD.IN >> 4) & 0b1) << 3 |
    ((PORTD.IN >> 5) & 0b1) << 2 |
    ((PORTC.IN >> 6) & 0b1) << 1 |
    ((PORTB.IN >> 2) & 0b1) << 0;

  
  // Drive Led pins low if corresponding state is 0
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
