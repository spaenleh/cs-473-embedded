#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include "system.h"
#include "io.h"
//#include "demo_i2c.c"

#define ONE_MB (1024 * 1024)
#define Npix   240*320/4
#define HEIGHT 240
#define WIDTH  320

void clearFrame1(void);
void clearFrame2(void);
void delay(uint32_t T);

int main()
{
	uint8_t tmp;
	uint8_t error;
	uint16_t color16 =0;
	uint32_t color32;
	error = 0;
	//char* filename = "/mnt/host/image.ppm";
	//char* image = "./test.ppm";

	IOWR_32DIRECT(HPS_0_BRIDGES_BASE, 0, 0x1234);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE, 0);

	clearFrame1();
	clearFrame2();
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE, 0);

	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00000000);

	//I2C commands for TRDB-D5M
	bool i2c_reponse = false;
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00000010); // enable clk_gen
	i2c_reponse = main_i2c();

	//IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00000100); //enable avalon master (enable also the the cam)
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00000110);

	IOWR_8DIRECT(D5M_TOP_0_BASE, 1, 0x55);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 2, 0x55);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 3, 0x55);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 4, 0x56);

	IOWR_8DIRECT(D5M_TOP_0_BASE, 5, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 6, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 7, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 8, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 9, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 10, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 11, 0x00);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 12, 0x00);

	printf("write frame 1\n");
	//IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00001100); //Start frame 01 and enable avalon master (also enable clkgen en cam)
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00001111);

	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);

	if((tmp&0b00100000) != 0)
	{
		printf("busy\n");
	}

	while((IORD_8DIRECT(D5M_TOP_0_BASE, 0)&0b00100000) != 0x00)
	{
		delay(1000000);
		printf(".");
	}
	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);
	printf("\send write frame 1\n");

	/*
	printf("write frame 2\n");
	//IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00010100);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00010111);

	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);

	if((tmp&0b00100000) != 0)
	{
		printf("busy\n");
	}

	while((IORD_8DIRECT(D5M_TOP_0_BASE, 0)&0b00100000) != 0x00)
	{
		delay(1000000);
		printf(".");
	}
	tmp = IORD_8DIRECT(D5M_TOP_0_BASE, 0);
	printf("\nend write frame 2\n");
	*/

	char* myfile = "/mnt/host/myimage.ppm";
	FILE *myfileout = fopen(myfile, "w");
	if (!myfileout) {
		printf("Error: could not open for writing\n");
	}

	int frame = HEIGHT*WIDTH;
	int max_val = 255;
	uint16_t value1;
	uint8_t red, green, blue;
	fprintf(myfileout, "P3 \n %d %d \n  %d \n", WIDTH, HEIGHT, max_val);

	//for (uint32_t i = 0; i < HPS_0_BRIDGES_SPAN; i += sizeof(uint32_t)) {
	for (uint32_t i = 0; i < 4*frame; i += sizeof(uint32_t)) {
		int32_t addr = HPS_0_BRIDGES_BASE + i;

		// Read through address span expander
		uint32_t readdata = IORD_32DIRECT(addr, 0);
		value1 = 0x0000FFFF & readdata;
		red = (0xF800 & value1)>>8;
		green = (0x07E0 & value1)>>3;
		blue = (0x001F & value1)<<3;
		blue = blue & ~0x07;

		fprintf(myfileout, "%d %d %d \n", red, green, blue);
	}
	fclose(myfileout);
	printf("finish all\n");

	return 0;
}

void clearFrame1(void)
{
	printf("start clear frame 1\n");
	for(int i = 0; i<Npix;i++)
	{
		IOWR_32DIRECT(HPS_0_BRIDGES_BASE+i*4, 0, 0x00);
	}
	printf("frame cleared 1\n");
}

void clearFrame2(void)
{
	printf("start clear frame 2\n");
	for(int i = 0; i<Npix;i++)
	{
		IOWR_32DIRECT(HPS_0_BRIDGES_BASE + 4*Npix*4 + i*4, 0, 0x00);
	}
	printf("frame cleared 2\n");
}

void delay(uint32_t T)
{
	uint32_t idx;
	for(idx = T;idx>0;idx--)
	{};
}
