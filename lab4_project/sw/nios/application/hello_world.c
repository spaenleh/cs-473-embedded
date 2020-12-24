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

#define REG_CMD		0
#define REG_DATA	2
#define REG_S_INSTR	4
#define REG_S_POLL	6
#define ADRR		DISPLAY_IP_0_BASE
#define DELAY		10

#define NPIX		240*320/4


// prototypes
void delay_ms(int duration);
void delay_clk(int number);
void send_reset();
void LCD_init();
void fill_frame(int offset);


int main()
{
	printf("Hello from Nios II!\n");

	// write in the SDRAM with the alterafs library
	fill_frame(0);
	fill_frame(4*NPIX*4);

	LCD_init();
	// Display bit is at 1 and reset bit is at 0
	//IOWR_16DIRECT(ADRR, REG_S_INSTR, 0b10000000);
	while(1){
		//IOWR_16DIRECT(ADRR, REG_S_INSTR, 0b10000000);
		delay_ms(100);
	}
	return 0;
}

void fill_frame(int offset){
	printf("writing frame with offset %d\n", offset);
	for(int i=0; i< NPIX;i++) {
		IOWR_32DIRECT(HPS_0_BRIDGES_BASE + offset + i*4, 0, 0xFF00FF00);
	}
	printf("Finished filling memory\n");
}

void LCD_init(){
	send_reset();
	// Exit sleep
	IOWR_16DIRECT(ADRR, REG_CMD, 0x11);
	delay_clk(DELAY);

	// Power CTRL B
	IOWR_16DIRECT(ADRR, REG_CMD, 0xCF);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x81);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0xC0); // 0x30 selon datasheet
	delay_clk(DELAY);

	// power on sequence control
	IOWR_16DIRECT(ADRR, REG_CMD, 0xED);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x64);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x03);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x12);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x81);
	delay_clk(DELAY);
	// Driver timing control A
	IOWR_16DIRECT(ADRR, REG_CMD, 0xE8);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x85);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x01);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x798); // should not be a problem since we have 16bits
	delay_clk(DELAY);
	// Power control A
	IOWR_16DIRECT(ADRR, REG_CMD, 0xCB);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x39);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x2C);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x34);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x02);
	delay_clk(DELAY);
	// pump ratio control
	IOWR_16DIRECT(ADRR, REG_CMD, 0xF7);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x20);
	delay_clk(DELAY);
	// Driver timing control B
	IOWR_16DIRECT(ADRR, REG_CMD, 0xEA);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	// Frame control
	IOWR_16DIRECT(ADRR, REG_CMD, 0xB1);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x1B);
	delay_clk(DELAY);
	// Display function control
	IOWR_16DIRECT(ADRR, REG_CMD, 0xB6);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x0A);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0xA2);
	delay_clk(DELAY);
	// Power control 1
	IOWR_16DIRECT(ADRR, REG_CMD, 0xC0);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x05);
	delay_clk(DELAY);
	// Power control 2
	IOWR_16DIRECT(ADRR, REG_CMD, 0xC1);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x11);
	delay_clk(DELAY);
	// VCM control 1
	IOWR_16DIRECT(ADRR, REG_CMD, 0xC5);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x45);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x45);
	delay_clk(DELAY);
	// VCM control 2
	IOWR_16DIRECT(ADRR, REG_CMD, 0xC7);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0xA2);
	delay_clk(DELAY);
	// Memory access control
	IOWR_16DIRECT(ADRR, REG_CMD, 0x36);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x08); // BGR order
	delay_clk(DELAY);
	// Enable 3G
	IOWR_16DIRECT(ADRR, REG_CMD, 0xF2);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00); // Disable 3Gamma correction
	delay_clk(DELAY);

	// here comes the gamma correction positive
	// here comes the gamma correction negative

	// Column address set
	IOWR_16DIRECT(ADRR, REG_CMD, 0x2A);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0xEF);
	delay_clk(DELAY);
	// Page address set
	IOWR_16DIRECT(ADRR, REG_CMD, 0x2B);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x01);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x3F);
	delay_clk(DELAY);
	// COLMOD : pixel format set
	IOWR_16DIRECT(ADRR, REG_CMD, 0x3A);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x55);
	delay_clk(DELAY);
	// Interface control
	IOWR_16DIRECT(ADRR, REG_CMD, 0xF6);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x01);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x30);
	delay_clk(DELAY);
	IOWR_16DIRECT(ADRR, REG_DATA, 0x00);
	delay_clk(DELAY);
	// display on
	IOWR_16DIRECT(ADRR, REG_CMD, 0x29);
	delay_clk(DELAY);

}

void send_reset(){
	//uint16_t value = IORD_16DIRECT()
	IOWR_16DIRECT(ADRR, REG_S_INSTR, 0b00000000);
	delay_ms(1);
	IOWR_16DIRECT(ADRR, REG_S_INSTR, 0b01000000);
	delay_ms(100);
	IOWR_16DIRECT(ADRR, REG_S_INSTR, 0b00000000);
	delay_ms(1200);
}

// wait for duration ms
void delay_ms(int duration){
	int i;
	for(i=0; i<500*duration; i++);
}

// wait for duration ms
void delay_clk(int number){
	int i;
	for(i=0; i<number; i++);
}
