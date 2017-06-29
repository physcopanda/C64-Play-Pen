// Harmless warning about browse information
#pragma warning (disable : 4786)
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "Compress.h"
#include "Decompress.h"
#include "../Common/ParamToNum.h"

// Some test command lines
//-c C:\work\C64\MusicEditorHelp\MusicEditorHelp.prg c:\temp\t.cprg
//-c C:\work\C64\MusicEditorHelp\MusicEditorHelp.prg c:\temp\t.cprg 2
//-d c:\temp\t.cprg c:\temp\t.prg
//-c C:\work\ReplicaNetWork\TestXPCompression\Scroller.prg c:\temp\t.cprg 2
//-c C:\work\C64\CityGame\OriginalData.prg c:\temp\t.cprg 2
//-c C:\work\C64\Decompression\TestScreen.bin c:\temp\t.cprg
//-c64b C:\work\C64\RacingGame\OriginalData.prg c:\temp\tc.prg 2048
//-c64b C:\work\C64\CityGame\OriginalData.prg c:\temp\tc.prg 22016
//-c64b ScrollerUT1024.prg c:\temp\tc.prg 1024
//-c64b ScrollerUT1024.prg c:\temp\tc.prg 0x400
//-c64b ScrollerUT1024.prg c:\temp\tc.prg $400
//-c UnitTest1.dat c:\temp\ut1.cdat


// TODP: Add an option to compress and run BASIC code.
// Related^^ TODO: Update $2d and $2e properly so that other applications that expect them will work.
//-c64b SEUCK.prg SEUCKComp.prg 2064
//>Actually what can be done is to add to the loaded input data some code at some out of the way address (like $f000 or $c000)
// Then that will warmboot/restore BASIC and the correct expected values in $2d $2e etc.
// Then this code can call the BASIC code without needing any decompress code changes in the binary blobs below. Also it'll mean the booting code is also compressed.

// TODO: Document how to generate the sC64DecompNoEffect and sC64DecompBorderEffect (From C64\Decompression?) and the constants like 0x8e9 that poke into the code.

static u8 sC64DecompNoEffect[] = {
	0x0B, 0x08, 0x01, 0x00, 0x9E, 0x32, 0x30, 0x36, 0x31, 0x00, 0x00, 0x00, 0x78, 0xA9, 0x20, 0x85, 
	0x01, 0xA2, 0x33, 0xBD, 0x2F, 0x08, 0x95, 0x4F, 0xCA, 0xD0, 0xF8, 0xA2, 0xCB, 0xBD, 0x62, 0x08, 
	0x9D, 0xFF, 0x00, 0xBD, 0x0C, 0x09, 0x9D, 0x33, 0x03, 0xCA, 0xD0, 0xF1, 0x4C, 0x6D, 0x00, 0xAD, 
	0x00, 0x04, 0xE6, 0x51, 0xD0, 0x02, 0xE6, 0x52, 0x8D, 0x01, 0x08, 0xE6, 0x5A, 0xD0, 0x02, 0xE6, 
	0x5B, 0x60, 0xAD, 0xFF, 0xFF, 0xE6, 0x64, 0xD0, 0x02, 0xE6, 0x65, 0x60, 0xBD, 0xB5, 0x08, 0x9D, 
	0x00, 0xFF, 0xCA, 0xD0, 0xF7, 0xC6, 0x6F, 0xC6, 0x72, 0xA5, 0x6F, 0xC9, 0x07, 0xD0, 0xED, 0x4C, 
	0x12, 0x01, 0x48, 0xE0, 0x80, 0xF0, 0x05, 0x8A, 0x0A, 0xAA, 0x68, 0x60, 0x20, 0x63, 0x00, 0x38, 
	0x2A, 0xAA, 0x68, 0x60, 0xA2, 0x80, 0xA0, 0x01, 0x84, 0x02, 0x88, 0x84, 0x03, 0x84, 0x09, 0x8C, 
	0x37, 0x01, 0x98, 0x20, 0x00, 0x01, 0x20, 0x00, 0x01, 0x20, 0x00, 0x01, 0x20, 0x00, 0x01, 0x2E, 
	0x37, 0x01, 0xA9, 0x00, 0x20, 0x00, 0x01, 0x2A, 0xC9, 0x00, 0xD0, 0x05, 0x20, 0x00, 0x01, 0x90, 
	0x0F, 0xA0, 0x07, 0x20, 0x00, 0x01, 0x2A, 0x88, 0xD0, 0xF9, 0x20, 0x59, 0x00, 0x4C, 0x30, 0x01, 
	0xA9, 0x00, 0x85, 0xFE, 0x85, 0xFC, 0x20, 0x00, 0x01, 0x2A, 0x20, 0x00, 0x01, 0x2A, 0xF0, 0x2A, 
	0xC9, 0x01, 0xD0, 0x41, 0xA9, 0x00, 0xA0, 0x04, 0x20, 0x00, 0x01, 0x2A, 0x88, 0xD0, 0xF9, 0xA8, 
	0xB9, 0x10, 0x00, 0x85, 0xFD, 0xB9, 0x20, 0x00, 0x85, 0xFE, 0xB9, 0x30, 0x00, 0x85, 0xFB, 0xB9, 
	0x40, 0x00, 0x85, 0xFC, 0x4C, 0x96, 0x03, 0x4C, 0x00, 0x09, 0xA9, 0x01, 0x85, 0xFD, 0x20, 0x00, 
	0x01, 0x26, 0xFD, 0x26, 0xFE, 0xB0, 0xF0, 0x20, 0x00, 0x01, 0x90, 0xF2, 0xE6, 0xFD, 0xD0, 0x02, 
	0xE6, 0xFE, 0x4C, 0x34, 0x03, 0x85, 0xFD, 0xC6, 0xFD, 0x4C, 0x34, 0x03, 0xA9, 0x00, 0x20, 0x00, 
	0x01, 0x2A, 0x20, 0x00, 0x01, 0x2A, 0xD0, 0x0B, 0xA5, 0x02, 0x85, 0xFB, 0xA5, 0x03, 0x85, 0xFC, 
	0x4C, 0x7A, 0x03, 0xA8, 0x29, 0x01, 0x85, 0xFB, 0x98, 0x29, 0x02, 0xD0, 0x13, 0x20, 0x00, 0x01, 
	0xB0, 0x0A, 0x20, 0x00, 0x01, 0x26, 0xFB, 0x26, 0xFC, 0x4C, 0x55, 0x03, 0xA0, 0x06, 0xD0, 0x02, 
	0xA0, 0x05, 0x20, 0x00, 0x01, 0x26, 0xFB, 0x26, 0xFC, 0x88, 0xD0, 0xF6, 0xE6, 0xFB, 0xD0, 0x02, 
	0xE6, 0xFC, 0xA4, 0x09, 0xA5, 0xFD, 0x99, 0x10, 0x00, 0xA5, 0xFE, 0x99, 0x20, 0x00, 0xA5, 0xFB, 
	0x99, 0x30, 0x00, 0xA5, 0xFC, 0x99, 0x40, 0x00, 0xC8, 0x98, 0x29, 0x0F, 0x85, 0x09, 0xA5, 0xFB, 
	0x85, 0x02, 0xA5, 0xFC, 0x85, 0x03, 0xC9, 0x0D, 0x90, 0x0E, 0xF0, 0x02, 0xB0, 0x04, 0xA5, 0xFB, 
	0xF0, 0x06, 0xE6, 0xFD, 0xD0, 0x02, 0xE6, 0xFE, 0xA5, 0x5A, 0x38, 0xE5, 0xFB, 0x85, 0x51, 0xA5, 
	0x5B, 0xE5, 0xFC, 0x85, 0x52, 0x20, 0x50, 0x00, 0xA4, 0xFD, 0xF0, 0x06, 0x20, 0x50, 0x00, 0x88, 
	0xD0, 0xFA, 0xA5, 0xFE, 0xF0, 0x0A, 0x20, 0x50, 0x00, 0x88, 0xD0, 0xFA, 0xC6, 0xFE, 0xD0, 0xF6, 
	0x4C, 0x30, 0x01
};

static u8 sC64DecompBorderEffect[] = {
	0x0B, 0x08, 0x01, 0x00, 0x9E, 0x32, 0x30, 0x36, 0x31, 0x00, 0x00, 0x00, 0x78, 0xA9, 0x20, 0x85, 
	0x01, 0xA2, 0x33, 0xBD, 0x2F, 0x08, 0x95, 0x4F, 0xCA, 0xD0, 0xF8, 0xA2, 0xCB, 0xBD, 0x62, 0x08, 
	0x9D, 0xFF, 0x00, 0xBD, 0x0C, 0x09, 0x9D, 0x33, 0x03, 0xCA, 0xD0, 0xF1, 0x4C, 0x6D, 0x00, 0xAD, 
	0x00, 0x04, 0xE6, 0x51, 0xD0, 0x02, 0xE6, 0x52, 0x8D, 0x01, 0x08, 0xE6, 0x5A, 0xD0, 0x02, 0xE6, 
	0x5B, 0x60, 0xAD, 0xFF, 0xFF, 0xE6, 0x64, 0xD0, 0x02, 0xE6, 0x65, 0x60, 0xBD, 0xC0, 0x08, 0x9D, 
	0x00, 0xFF, 0xCA, 0xD0, 0xF7, 0xC6, 0x6F, 0xC6, 0x72, 0xA5, 0x6F, 0xC9, 0x07, 0xD0, 0xED, 0x4C, 
	0x12, 0x01, 0x48, 0xE0, 0x80, 0xF0, 0x05, 0x8A, 0x0A, 0xAA, 0x68, 0x60, 0x20, 0x63, 0x00, 0x38, 
	0x2A, 0xAA, 0x68, 0x60, 0xA2, 0x80, 0xA0, 0x01, 0x84, 0x02, 0x88, 0x84, 0x03, 0x84, 0x09, 0x8C, 
	0x37, 0x01, 0x98, 0x20, 0x00, 0x01, 0x20, 0x00, 0x01, 0x20, 0x00, 0x01, 0x20, 0x00, 0x01, 0x2E, 
	0x37, 0x01, 0xA9, 0x00, 0x20, 0x00, 0x01, 0x2A, 0xC9, 0x00, 0xD0, 0x05, 0x20, 0x00, 0x01, 0x90, 
	0x0F, 0xA0, 0x07, 0x20, 0x00, 0x01, 0x2A, 0x88, 0xD0, 0xF9, 0x20, 0x59, 0x00, 0x4C, 0x30, 0x01, 
	0xA9, 0x00, 0x85, 0xFE, 0x85, 0xFC, 0x20, 0x00, 0x01, 0x2A, 0x20, 0x00, 0x01, 0x2A, 0xF0, 0x2A, 
	0xC9, 0x01, 0xD0, 0x41, 0xA9, 0x00, 0xA0, 0x04, 0x20, 0x00, 0x01, 0x2A, 0x88, 0xD0, 0xF9, 0xA8, 
	0xB9, 0x10, 0x00, 0x85, 0xFD, 0xB9, 0x20, 0x00, 0x85, 0xFE, 0xB9, 0x30, 0x00, 0x85, 0xFB, 0xB9, 
	0x40, 0x00, 0x85, 0xFC, 0x4C, 0x96, 0x03, 0x4C, 0x00, 0x09, 0xA9, 0x01, 0x85, 0xFD, 0x20, 0x00, 
	0x01, 0x26, 0xFD, 0x26, 0xFE, 0xB0, 0xF0, 0x20, 0x00, 0x01, 0x90, 0xF2, 0xE6, 0xFD, 0xD0, 0x02, 
	0xE6, 0xFE, 0x4C, 0x34, 0x03, 0x85, 0xFD, 0xC6, 0xFD, 0x4C, 0x34, 0x03, 0xA9, 0x00, 0x20, 0x00, 
	0x01, 0x2A, 0x20, 0x00, 0x01, 0x2A, 0xD0, 0x0B, 0xA5, 0x02, 0x85, 0xFB, 0xA5, 0x03, 0x85, 0xFC, 
	0x4C, 0x7A, 0x03, 0xA8, 0x29, 0x01, 0x85, 0xFB, 0x98, 0x29, 0x02, 0xD0, 0x13, 0x20, 0x00, 0x01, 
	0xB0, 0x0A, 0x20, 0x00, 0x01, 0x26, 0xFB, 0x26, 0xFC, 0x4C, 0x55, 0x03, 0xA0, 0x06, 0xD0, 0x02, 
	0xA0, 0x05, 0x20, 0x00, 0x01, 0x26, 0xFB, 0x26, 0xFC, 0x88, 0xD0, 0xF6, 0xE6, 0xFB, 0xD0, 0x02, 
	0xE6, 0xFC, 0xA4, 0x09, 0xA5, 0xFD, 0x99, 0x10, 0x00, 0xA5, 0xFE, 0x99, 0x20, 0x00, 0xA5, 0xFB, 
	0x99, 0x30, 0x00, 0xA5, 0xFC, 0x99, 0x40, 0x00, 0xC8, 0x98, 0x29, 0x0F, 0x85, 0x09, 0xA5, 0xFB, 
	0x85, 0x02, 0xA5, 0xFC, 0x85, 0x03, 0xC9, 0x0D, 0x90, 0x0E, 0xF0, 0x02, 0xB0, 0x04, 0xA5, 0xFB, 
	0xF0, 0x06, 0xE6, 0xFD, 0xD0, 0x02, 0xE6, 0xFE, 0xA5, 0x5A, 0x38, 0xE5, 0xFB, 0x85, 0x51, 0xA5, 
	0x5B, 0xE5, 0xFC, 0x85, 0x52, 0xA9, 0x25, 0x85, 0x01, 0xEE, 0x20, 0xD0, 0xA9, 0x20, 0x85, 0x01, 
	0x20, 0x50, 0x00, 0xA4, 0xFD, 0xF0, 0x06, 0x20, 0x50, 0x00, 0x88, 0xD0, 0xFA, 0xA5, 0xFE, 0xF0, 
	0x0A, 0x20, 0x50, 0x00, 0x88, 0xD0, 0xFA, 0xC6, 0xFE, 0xD0, 0xF6, 0x4C, 0x30, 0x01
};

const u32 sStartOfBASIC = 0x801;


static void TestRLEPack(u8 *input,const u32 inputLength, u8 *output, u32 *outLen)
{
	u32 foundLeast[256];
	memset(foundLeast,0,sizeof(foundLeast));

	// Total up the occurrences of each byte value
	u32 i;
	for (i=0;i<inputLength;i++)
	{
		foundLeast[input[i]]++;
	}

	// Find the least used byte
	u8 leastIndex = 0;
	for (i=1;i<256;i++)
	{
		if (foundLeast[i] < foundLeast[leastIndex])
		{
			leastIndex = (u8) i;
		}
	}

	u32 outPos = 0;
	// Save the marker
	output[outPos++] = leastIndex;

	// Now RLE pack with the least used byte as a marker
	for (i=0;i<inputLength;i)
	{
		bool match = false;
		if ( (i+3) < inputLength )
		{
			if ( (input[i] == input[i+1]) && (input[i] == input[i+2]))
			{
				match = true;
			}
		}
		// Check to see if we need to output a run
		if ( (input[i] == leastIndex) || match)
		{
			u32 j = 0;
			while ((input[i+j] == input[i]) && (j < 256))
			{
				j++;
			}
			output[outPos++] = leastIndex;
			output[outPos++] = (u8)j;
			output[outPos++] = input[i];
			i+=j;
		}
		else
		{
			output[outPos++] = input[i++];
		}
	}

	// Last byte, will trigger a test for end of file
	output[outPos++] = leastIndex;

	*outLen = outPos;
}

int main(int argc,char **argv)
{
	if (argc < 4)
	{
		printf("LZMPi : A very simple file compressor or decompressor suitable for C64 files.\n\n"
		 " -c <input file> <outfile file> [offset from the start of the file]\n"
		 " -d <input file> <outfile file>\n"
		 " -c64[b] <input file> <outfile file> <run address> [start address]\n\n"
		 "Use the following to skip a number of bytes from the start of the file and\n"
		 "set a length. If the length equals 0 the length is still set from the file: \n"
		 " -c <input file> <outfile file> <offset> [length]\n\n"
		 "-c64 will compress a C64 prg file with the start address being the first two\n"
		 "bytes of the file. The optional start address will override the start address\n"
		 "read from the first two bytes of the prg file.\n"
		 "-c64b will cause the border to flash during decompression.\n"
		 "By default the border will not flash.\n\n");

		exit(-1);
	}

	u8 input[65536];
	u8 output[73728];
	int offset = 0;
	int wantedLength = 0;
	bool outputC64Header = false;
	bool useRLE = false;
	u32 startC64Code = 0x900;
	u32 loadC64Code = 0;
	bool flashBorder = false;


	if ((argv[1][1] == 'c') && (argv[1][2] == 'r'))
	{
		useRLE = true;
	}

	if ((argv[1][1] == 'c') && (argv[1][2] == '6') && (argv[1][3] == '4'))
	{
		if (argc >= 5)
		{
			outputC64Header = true;
			if (argv[1][4] == 'b')
			{
				printf("Making the border flash.\n");
				flashBorder = true;
			}

			startC64Code = ParamToNum(argv[4]);
			printf("Using run address $%04x\n",startC64Code);

			if (argc >= 6)
			{
				loadC64Code = ParamToNum(argv[5]);
				printf("Using load address $%04x\n",loadC64Code);
			}
		}
		else
		{
			printf("%s: Missing a start address?\n",argv[1]);
			return -1;
		}
	}
	else if (argv[1][1] == 'c')
	{
		if (argc >= 5)
		{	
			offset = ParamToNum(argv[4]);
		}
		if (argc >= 6)
		{
			wantedLength = ParamToNum(argv[5]);
		}
	}

	FILE *fp;
	printf("Opening '%s' for reading...\n",argv[2]);
	fp = fopen(argv[2],"rb");
	if (!fp)
	{
		printf("Problem opening '%s' for reading\n",argv[2]);
		exit(-1);
	}

	if (outputC64Header)
	{
		if (!loadC64Code)
		{
			loadC64Code = fgetc(fp);
			loadC64Code |= fgetc(fp) << 8;
			printf("Read load address as $%04x\n",loadC64Code);
		}
		else
		{
			// Skip two bytes
			fseek(fp,2,SEEK_SET);
		}
	}

	if (offset)
	{
		fseek(fp,offset,SEEK_SET);
	}

	u16 inputSize = fread(input,1,sizeof(input),fp);

	if (wantedLength)
	{
		inputSize = wantedLength;
	}

	fclose(fp);

	printf("Opening '%s' for writing...\n",argv[3]);
	fp = fopen(argv[3],"wb");
	if (!fp)
	{
		printf("Problem opening '%s' for writing\n",argv[3]);
		exit(-1);
	}

	printf("Working...\n");

	if (argv[1][1] == 'c')
	{
#if 0
		u16 j;
		for (j=0;j<inputSize;j++)
		{
			if ( (j % 16) == 0)
			{
				printf("\n");
			}
			printf("0x%0.2x,",input[j]);
		}
		printf("\n");
		exit(0);
#endif

		if (!outputC64Header)
		{
			fwrite(&inputSize,1,sizeof(inputSize),fp);
		}

		u32 outSize;
		u32 outBitSize;
		int bestBits = 0;
		Compression comp;
#if 1
		// For now we will always use one escape bit because it seems to consistently generate
		// the best results.
		if (useRLE)
		{
			TestRLEPack(input,inputSize,output,&outSize);
		}
		else
		{
#if 0
			comp.Compress(input,inputSize,output,&outSize,10,1);
			outBitSize = comp.mTotalBitsOut;
			comp.mEarlyOut = outBitSize;

			int besta = gXPCompressionTweak1,bestb = gXPCompressionTweak2,bestc = gXPCompressionTweak3,bestd = gXPCompressionTweak4;

			int a,b,c,d;
			for (a=1 ; a < 10 ; a++)
			{
				for (b=1 ; b < 10 ; b++)
				{
					for (c=1 ; c < 10 ; c++)
					{
						for (d=1 ; d < 10 ; d++)
						{
							gXPCompressionTweak1 = a;
							gXPCompressionTweak2 = b;
							gXPCompressionTweak3 = c;
							gXPCompressionTweak4 = d;

							Compression comp2;
							comp2.mEarlyOut = comp.mEarlyOut;
							int ret = comp2.Compress(input,inputSize,output,&outSize,10,1);
							printf("Working %d : %d %d %d %d                \r",outBitSize - comp2.mTotalBitsOut , a , b ,c , d);
							if (ret == -1)
							{
								continue;
							}

							if (comp2.mTotalBitsOut < outBitSize)
							{
								printf("New best %d : %d %d %d %d                \n",outBitSize - comp2.mTotalBitsOut , a , b ,c , d);
								outBitSize = comp2.mTotalBitsOut;
								comp.mEarlyOut = outBitSize;
								besta = gXPCompressionTweak1;
								bestb = gXPCompressionTweak2;
								bestc = gXPCompressionTweak3;
								bestd = gXPCompressionTweak4;
							}
						}
					}
				}
			}
			gXPCompressionTweak1 = besta;
			gXPCompressionTweak2 = bestb;
			gXPCompressionTweak3 = bestc;
			gXPCompressionTweak4 = bestd;
#endif

			Compression comp3;

			comp3.Compress(input,inputSize,output,&outSize,10,1);
			outBitSize = comp3.mTotalBitsOut;

			// This tries to optimise the compression choices even more by optionally trying each
			// dictionary and literal choice one at a time to get the best output length.
			// It saves 149 bytes with C:\work\C64\CityGame\OriginalData.prg but takes ages.
#if 0
			size_t choiceIndex;
			for (choiceIndex = 0 ; choiceIndex < comp3.mChoicesPos.size() ; /*Deliberate no incr*/)
			{
				printf("Considering pos %d/%d with len %d exceptions %d\r",choiceIndex,comp3.mChoicesPos.size(),outSize,comp3.mIgnoreChoicePos.size());
				Compression comp2;
				comp2.mIgnoreChoicePos = comp3.mIgnoreChoicePos;
				comp2.mIgnoreChoicePos.insert(comp3.mChoicesPos[choiceIndex]);
				u32 outSize2;
				u32 outBitSize2;
				comp2.Compress(input,inputSize,output,&outSize2,10,1);
				outBitSize2 = comp2.mTotalBitsOut;
	//			printf("   Got size %d\n",outSize2);
				if (outBitSize2 < outBitSize)
				{
					printf("\nFound %d bits at pos %d/%d\n",outBitSize - outBitSize2,choiceIndex,comp3.mChoicesPos.size());
					comp3.mIgnoreChoicePos = comp2.mIgnoreChoicePos;
					comp3.mChoicesPos = comp2.mChoicesPos;
					outBitSize = outBitSize2;
					outSize = outSize2;
					// loop and check again
					continue;
				}
				choiceIndex++;
			}

			// Final compress with the choices
			comp3.mEarlyOut = -1;
			comp3.mEnableChoicesOutput = true;
			comp3.Compress(input,inputSize,output,&outSize,10,1);
#endif
		}

#else
		comp.Compress(input,inputSize,output,&outSize,10,0);
		int i;
		for (i = 1; i < 4 ; i++)
		{
			u32 tSize;
			printf("Trying optimise %d... ",i);
			comp.Compress(input,inputSize,output,&tSize,10,i);
			if (tSize < outSize)
			{
				printf("Better!\n",i);
				bestBits = i;
				outSize = tSize;
			}
			else
			{
				printf("\n",i);
			}
		}
		comp.Compress(input,inputSize,output,&outSize,10,bestBits);
#endif

		if (outputC64Header)
		{
			fputc(1,fp);
			fputc(8,fp);
			u8 *theC64Code;
			u32 endOfMemory;
			size_t sizeToWrite;

			endOfMemory = sStartOfBASIC + sizeof(sC64DecompNoEffect) + outSize;
			theC64Code = sC64DecompNoEffect;
			sizeToWrite = sizeof(sC64DecompNoEffect);
			if (flashBorder)
			{
				theC64Code = sC64DecompBorderEffect;
				endOfMemory = sStartOfBASIC + sizeof(sC64DecompBorderEffect) + outSize;
				sizeToWrite = sizeof(sC64DecompBorderEffect);
			}

			// Update the offsets in the code header to save out
			// As luck would have it the two bits of code have the same offsets early on, it is
			// only later in the code with the extra border update code that produces different code.
			// MPi: TODO: remove these magic numbers such as 0x83a and 0x844 from here and below and make them constants.
			theC64Code[0x8e9 - sStartOfBASIC] = (u8) (startC64Code & 0xff);
			theC64Code[0x8ea - sStartOfBASIC] = (u8) ((startC64Code>>8) & 0xff);

			theC64Code[0x84e - sStartOfBASIC] = (u8) ((endOfMemory-0x100) & 0xff);
			theC64Code[0x84f - sStartOfBASIC] = (u8) (((endOfMemory-0x100)>>8) & 0xff);

			theC64Code[0x844 - sStartOfBASIC] = (u8) ((0x10000 - outSize) & 0xff);
			theC64Code[0x845 - sStartOfBASIC] = (u8) (((0x10000 - outSize)>>8) & 0xff);

			theC64Code[0x83a - sStartOfBASIC] = (u8) (loadC64Code & 0xff);
			theC64Code[0x83b - sStartOfBASIC] = (u8) ((loadC64Code>>8) & 0xff);

			fwrite(theC64Code,1,sizeToWrite,fp);
		}

		fwrite(output,1,outSize,fp);

		printf("Input length = $%04x output length = $%04x\n",(int)inputSize,(int)ftell(fp));
		fclose(fp);

		// Enable the following code to paranoia check the compression is OK
#if 1
		if (!useRLE)
		{
			u8 temp[65536];
			u32 tempLen;
			if (Decompress(output,outSize,temp,&tempLen) || (tempLen != inputSize) || (memcmp(temp,input,tempLen) != 0))
			{
				printf("Problem during decompression\n");
				exit(-1);
			}
		}
#endif

	}

	if (argv[1][1] == 'd')
	{
		// Setup some defaults that can get overridden by the self decompressing header check
		u8 *compressedDataStart = input + sizeof(u16);
		u16 origSize = *(u16*)input;
		bool outputHeader = false;
		// Check for a compressed file with a known self decompressing header
		const size_t kLaterCodeOffset = 0x8f0 - sStartOfBASIC;
		if ((inputSize >= sizeof(sC64DecompNoEffect)) && (memcmp(input+2+kLaterCodeOffset,sC64DecompNoEffect+kLaterCodeOffset,sizeof(sC64DecompNoEffect)-kLaterCodeOffset)==0))
		{
			printf("Detected: sC64DecompNoEffect\n");
			compressedDataStart = input + 2 + sizeof(sC64DecompNoEffect);
			outputHeader = true;
		}
		else if ((inputSize >= sizeof(sC64DecompBorderEffect)) && (memcmp(input+2+kLaterCodeOffset,sC64DecompBorderEffect+kLaterCodeOffset,sizeof(sC64DecompBorderEffect)-kLaterCodeOffset)==0))
		{
			printf("Detected: sC64DecompBorderEffect\n");
			compressedDataStart = input + 2 + sizeof(sC64DecompBorderEffect);
			outputHeader = true;
		}
		if (outputHeader)
		{
			size_t loadAddress = *(u16*)(input + 2 + (0x83a - sStartOfBASIC));
			printf("Original load address = $%04x\n",loadAddress);
			fputc(loadAddress & 0xff,fp);
			fputc(loadAddress >> 8,fp);

			// Fix the inputSize in case the prg has extra crap added to the end of it
			inputSize = 65536 - (*(u16*)(input + 2 + (0x844 - sStartOfBASIC)));
		}
		else
		{
			inputSize -= compressedDataStart - input;
			printf("Input length = $%04x Original output length = $%04x\n",(int)inputSize,(int)origSize);
		}


		u32 outDecomp;
		if (Decompress(compressedDataStart,inputSize,output,&outDecomp))
		{
			printf("Problem during decompression\n");
			exit(-1);
		}
		printf("Decompressed length = $%04x\n",outDecomp);

		fwrite(output,1,outDecomp,fp);
		fclose(fp);
	}


	return 0;
}
