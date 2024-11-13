/*
 * 4btn_4led.cpp
 *
 * Created: 24/09/2024 10.17.53
 * Author : antti
 */ 

#include <avr/io.h>

void setup() {
	DDRD |= 0b1111 << 4;
	DDRB &= ~(0b1111);
}

void loop() {
	PORTD = (PINB & 0b1111) << 4;
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

