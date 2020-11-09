#include <stdio.h>
#include "system.h"
#include "io.h"

// register map
#define REG_PERIODE		0
#define REG_DUTY		2
#define REG_POLARITY	4
#define T_ON			1
#define T_OFF			0

int main()
{
	int i,j;
	printf("Program started !\n");

	// set 20 ms for servo-motor
	IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_PERIODE, 20000);

	// set polarity as T_on
	IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_POLARITY, T_ON);

	while(1){
		for(j=0; j<50000; j++);		// delay
		for(i=2000; i>1000; i--){
			IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_DUTY, i);
			for(j=0; j<500; j++);	// delay
		}
		for(j=0; j<5000000; j++);	// delay
		for(i=1000; i<2000; i++){
			IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_DUTY, i);
			for(j=0; j<2000; j++);	// delay
		}
	}

	return 0;
}
