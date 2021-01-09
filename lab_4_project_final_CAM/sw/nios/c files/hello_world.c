#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include "system.h"
#include "io.h"
//#include "demo_i2c.c"

#define ONE_MB (1024 * 1024)
#define Npix 240*320/4

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


	char* myfile = "/mnt/host/image.ppm";
	FILE *myfileout = fopen("image.ppm", "w+");
	if (!myfileout) {
		printf("Error: could not open for writing\n");
	}

	//int col_max = 320;
	//int col= 0;
	for (uint32_t i = 0; i < HPS_0_BRIDGES_SPAN; i += sizeof(uint32_t)) {
	//for (uint32_t i = 0; i < 320*3; i += sizeof(uint32_t)) {

		int32_t addr = HPS_0_BRIDGES_BASE + i;

		// Read through address span expander
		uint32_t readdata = IORD_32DIRECT(addr, 0);
		//printf("%d, ", readdata);
		fprintf(myfileout, "%d", &readdata);

		/*
		col ++;
		if(col == col_max){
			col = 0;
			printf("\n");
		}
		*/
	}

	/*
	FILE *foutput = fopen(filename, "w");
	if (!foutput) {
		printf("Error: could not open \"%s\" for writing\n", filename);
	}
	int nsuccess;
	uint32_t test[240*320];
	//uint32_t small_im[240*2];
	nsuccess = fprintf(foutput, "%" SCNd32, &test);
	printf("%"SCNd32, test);

	FILE *foutput2 = fopen(image, "w+");
	if (!foutput2) {
		printf("Error: could not open \"%s\" for writing\n", image);
	}
	int ii, jj;
	for(ii=0;ii<320; ii++){
		for(jj=0; jj<240; jj++){
			fprintf(foutput2, "%" SCNd32, &test[ii*240+jj]);
		}
		fprintf(foutput2, "\n");
	}

	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4-4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*2,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*2-4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*3,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*3-4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4-4,0);

	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4-4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4*2,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4*2-4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4*3,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4*3-4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4*4,0);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE+Npix*4*4+Npix*4*4-4,0);
	*/

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
