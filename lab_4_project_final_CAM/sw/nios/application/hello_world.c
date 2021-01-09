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
#include <inttypes.h>
#include "system.h"
#include "io.h"

#include "demo_i2c.c"

void delay(uint32_t T);

int main()
{
	uint8_t tmp;
	uint16_t color;
	int i2C_response;

	//D5M_TOP_0_BASE
	IOWR_8DIRECT(D5M_TOP_0_BASE, 1, 0xFF);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 2, 0xFF);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 3, 0xFF);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 4, 0xFE);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 5, 0x00); // until 12 do not touch, it's the base memory address
	IOWR_8DIRECT(D5M_TOP_0_BASE, 6, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 7, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 8, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 9, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 10, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 11, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 12, 0x00);

	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00001110); // to change 0b00001111 to turn on the camera

	//i2C_response = main_i2c();

	/*
	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);
	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);

	while(IORD_8DIRECT(D5M_TOP_0_BASE, 0)&0b00100000 != 0x00); // wait bussy 0

	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);

	color = IORD_16DIRECT(FRAM_MEMORY_BASE,0*2); //setup test
	color = IORD_16DIRECT(FRAM_MEMORY_BASE,4*2);
	color = IORD_16DIRECT(FRAM_MEMORY_BASE,8*2);
	color = IORD_16DIRECT(FRAM_MEMORY_BASE,12*2);
	color = IORD_16DIRECT(FRAM_MEMORY_BASE,16*2);
	 */

	return 0;
}

void delay(uint32_t T)
{
	uint32_t idx;
	for(idx = T;idx>0;idx--)
	{};
}
