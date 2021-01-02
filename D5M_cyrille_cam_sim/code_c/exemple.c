
#include <inttypes.h>
#include "system.h"
#include "io.h"

#define Npix 240*320/4

void clearFrame1(void);
void clearFrame2(void);
void delay(uint32_t T);


int main()
{
	uint8_t tmp;
	uint8_t error;
	uint16_t color16;
	uint32_t color32;
	error = 0;

	IOWR_32DIRECT(HPS_0_BRIDGES_BASE, 0, 0x1234);
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE, 0);

	clearFrame1();
	clearFrame2();
	color32 = IORD_32DIRECT(HPS_0_BRIDGES_BASE, 0);

	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00000000);
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00000100);

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
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00001100);

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
	printf("\nend write frame 1\n");

	printf("write frame 2\n");
	IOWR_8DIRECT(D5M_TOP_0_BASE, 0, 0b00010100);

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

/*
#include <assert.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#include "io.h"
#include "system.h"

#define ONE_MB (1024 * 1024)

int main(void) {
    uint32_t megabyte_count = 0;

    for (uint32_t i = 0; i < HPS_0_BRIDGES_SPAN; i += sizeof(uint32_t)) {

        // Print progress through 256 MB memory available through address span expander
        if ((i % ONE_MB) == 0) {
            printf("megabyte_count = %" PRIu32 "\n", megabyte_count);
            megabyte_count++;
        }

        uint32_t addr = HPS_0_BRIDGES_BASE + i;

        // Write through address span expander
        uint32_t writedata = i;
        IOWR_32DIRECT(addr, 0, writedata);

        // Read through address span expander
        uint32_t readdata = IORD_32DIRECT(addr, 0);

        // Check if read data is equal to written data
        assert(writedata == readdata);
    }

    return EXIT_SUCCESS;
}
*/
