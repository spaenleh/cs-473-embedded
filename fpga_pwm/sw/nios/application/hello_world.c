/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

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
	//int i,j;
	printf("Hello from Nios II!\n");

	// set periode in us
	IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_PERIODE, 20000);

	// set duty cycle as 2 ms
	IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_DUTY, 4000);

	// set polarity as T_on so that it is on for 2ms and off for 18ms
	IOWR_16DIRECT(PWM_CUSTOM_0_BASE, REG_POLARITY, T_OFF);
	while(1){

	}
	return 0;
}
