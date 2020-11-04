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

int main()
{
	int i,j;
	printf("Hello from Nios II!\n");
	// set all ports as out : DirReg is offset 0
	IOWR_8DIRECT(PARALLEL_PORT_CUSTOM_0_BASE, 0, 0xff);
	while(1){
		for(i=0; i<8; i++){
			// set port value : PortReg is offset 2
			IOWR_8DIRECT(PARALLEL_PORT_CUSTOM_0_BASE, 2, (1<<i));
			for(j=0; j<50000;j++);
		}
		for(i=6; i>0; i--){
			// set port value : PortReg is offset 2
			IOWR_8DIRECT(PARALLEL_PORT_CUSTOM_0_BASE, 2, (1<<i));
			for(j=0; j<50000;j++);
		}
	}
	return 0;
}
