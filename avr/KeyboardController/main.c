/*
 * KeyboardController.c
 *
 * Created: 06.06.2016 20:39:17
 * Author : Florian Ulmschneider
 */

#define F_CPU 8000000

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/cpufunc.h>

#define RDWR_PIN PA0
#define CE_PIN PD3
#define SPKR_PIN PD5
#define WAIT_PIN PD6
#define NMI_PIN PA1
#define KBD_CLK_PIN PD2
#define KBD_DATA_PIN PD4

volatile uint8_t inputRegister;
volatile uint8_t outputRegister[4] = {0, 0, 0, 0};

ISR(INT1_vect) {
	uint8_t address = PIND & 0b00000011;
	if(PINA & (1 << RDWR_PIN)) {
		//Z80 read
		if(!address) PORTA |= (1 << NMI_PIN);
		DDRB = 0xFF;
		PORTB = outputRegister[address];
		PORTD |= (1 << WAIT_PIN);
		_NOP();
		PORTD &= !(1 << WAIT_PIN);
		DDRB = 0;
		PORTB = 0;
	}
	else {
		//Z80 write
		inputRegister = PINB;
		PORTD |= (1 << WAIT_PIN);
		_NOP();
		PORTD &= !(1 << WAIT_PIN);
		switch(address) {
			case 1:
				outputRegister[1] = inputRegister;
				break;
			case 2:
				TCCR0B = inputRegister & 0b00000111;
				break;
			case 3:
				OCR0A = inputRegister;
				break;
			default:
				break;
		}
	}
}

int main(void)
{
	//Initialize INT1
	MCUCR |= (1 << ISC11);
	GIMSK |= (1 << INT1);
	
	//Initialize Timer 0
	TCCR0A |= (1 << COM0B0) | (1 << WGM01);
	
	DDRD |= (1 << SPKR_PIN) | (1 << WAIT_PIN);
	DDRA |= (1 << NMI_PIN);
	PORTA |= (1 << RDWR_PIN);
	PORTD |= (1 << CE_PIN);
	sei();
	
	//Main loop
    while (1) {
		if (outputRegister[1]) {
			outputRegister[0]++;
			PORTA &= ~(1 << NMI_PIN);
			_delay_ms(1000);
		}
    }
	return(0);
}
