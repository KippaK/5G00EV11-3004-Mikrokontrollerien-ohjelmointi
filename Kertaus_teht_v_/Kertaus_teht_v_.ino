void setup() {
  DDRD = DDRD | 0b11100000;
}

void loop() {
  if ((PIND >> 4) & 1) {
    PORTD = PORTD | (0b111 << 5);
  }
  else {
    PORTD = PORTD & ~(0b111 << 5);
  }
}
