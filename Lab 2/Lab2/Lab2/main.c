/*
 * Lab2.c
 *
 * Created: 1/19/2017 10:11:36 AM
 * Author : wongnich
 */ 


/*
This code will cause a TekBot connected to the AVR board to
move forward and when it touches an obstacle, it will reverse
and turn away from the obstacle and resume forward motion.

PORT MAP
Port B, Pin 4 -> Output -> Right Motor Enable
Port B, Pin 5 -> Output -> Right Motor Direction
Port B, Pin 7 -> Output -> Left Motor Enable
Port B, Pin 6 -> Output -> Left Motor Direction
Port D, Pin 1 -> Input -> Left Whisker
Port D, Pin 0 -> Input -> Right Whisker
*/

#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

int main(void)
{
	DDRB = 0b11110000;      // configure Port B pins for input/output
	PORTB = 0b01100000;     // set initial value for Port B outputs
	DDRD = 0b00000000;		//configure Port D pins for input
	PORTD = 0b00000000;		//set initial value for Port D (no output)

	while (1) // loop forever
	{
		PORTB = 0b01100000;     // make TekBot move forward
		
		
		if(PIND == 0b11111110){	//right whisker
			PORTB = 0b00000000;	//back up
			_delay_ms(1000);
			PORTB = 0b00100000;	//turn left
			_delay_ms(1000);
		}
		else if(PIND == 0b11111101){	//left whisker
			PORTB = 0b00000000;	//back up
			_delay_ms(1000);
			PORTB = 0b01000000;	//turn right
			_delay_ms(1000);
		}
		else if(PIND == 0b11111100){	//both whisker (same as left whisker)
			PORTB = 0b00000000;	//back up
			_delay_ms(1000);
			PORTB = 0b01000000;	//turn right
			_delay_ms(1000);
		}
		
	}
}