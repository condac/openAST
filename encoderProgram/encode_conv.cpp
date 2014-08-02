/*
 * Program to Decode and encode old transponder format for rc cars
 * 
  Copyright (C) 2014  OM2KW 

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <string>
#define	OUT_LEN	13					//v0.01
#define POLY	0x1000EEC20F	//v0.01

//int _tmain(int argc, _TCHAR* argv[]) {
int main( int argc,					// Number of strings in array argv
          char *argv[],			// Array of command-line argument strings
					char *envp[] ) {  // Array of environment variable strings

	unsigned long inp= 0;
	unsigned long long fflop= 0, temp= 0, temp1;
	unsigned char out[OUT_LEN], lastByte=0;
	unsigned int gInt;
	unsigned int i, j, k;
	
//	inp= 8361115;
	inp= 0;
	lastByte= 0;
	gInt= 0;
	//	inp= 0xB6DB6D; lastByte= 0xad;

	printf("\r\n\r\nByteStream Encoder v0.01\r\n");
	printf("PLEASE USE WITH CAUTION, PLEASE CREATE NUMBERS ONLY OF YOUR TRANSPONDERS\r\n");
	printf("Usage: bse txNumber [ghostInt] [lastByte]\r\n");
	
	if(argc< 2) {
		printf("No txNumber at input\r\n");	
		return(-1);
	}

	if(argc> 1) {
		inp= std::stoull(argv[1]);
		printf("nr: %08d\t\n", inp);
	}

	if(argc> 2) {
		gInt= std::stoull(argv[2]);
		printf("gInt: %03d\r\n", gInt);
	}

	if(argc> 3) {
		lastByte= std::stoull(argv[3]);
		printf("lastByte: %02d\r\n", lastByte);
	}


	inp|= unsigned long long(lastByte<<24);		//add last byte to number input
	j=0;
	for(i= 0; i< 36 ; i++) {
		temp<<=1;
		if(j< 3) {														//this is not ghost bit
			temp|= ((inp& 0x04000000)>>26);			//add bit from number to stream
			inp<<=1;
		} 
		else {																//this is ghost bit 
			temp|= (gInt& 0x0100)>> 8;					//add ghost bit to stream
			gInt<<=1;
		}
		if(j< 3) j++; else j= 0;
//		printf("%1d", (temp&0x01));
	}
//	printf("\r\nTEMPH: 0x%08x\r\n", temp>> 32);	//printf can not print 64bit at once
//	printf("TEMPL: 0x%08x\r\n", temp& 0xffffffff);
//	printf("\r\n");

	j=0;k=3;
	fflop|= (temp&0x01);										//add in stream to ff 
	temp>>=1;																//shift in stream	
	for(i= 0; i< 36; i++)	{
		fflop<<=1;														//shift flipflops
		fflop|= (temp&0x01);									//add in stream to ff 
		temp1= fflop& POLY;										//mask ff with polynomial
		temp1^= temp1 >> 1;										//calculate parity (number of 1's in stream)
		temp1^= temp1 >> 2;
		temp1= (temp1 & 0x1111111111111111UL) * 0x1111111111111111UL;
		temp1= (temp1 >> 60) & 0x01;

		out[k]<<=1;														//shift output
		out[k]|= temp1;												//add to output
		out[k]<<=1;														//shift output		
		out[k]|= (temp1^ ((fflop>>1)&0x01));	//add to output

		if(j< 3) j++;
		else {
			//printf("OUT[%02d]= 0x%02x\r\n",k, out[k]);
			j=0;
			k++;
		}
		/*
		printf("IN: %01d= ", temp&0x01);
		printf("%01d ", temp1);
		printf("%01d ", temp1^ ((fflop>>1)&0x01) );
		printf("FF= 0x%08x\r\n", fflop&0xff);
		*/
		temp>>=1;															//shift in stream	
	}

	out[0]= 0x00;
	out[1]= 0xf9;
	out[2]= 0x16;
	printf("Output:\r\n");
	printf("stream= {");
	for(i= 0; i< 10; i++)
		printf("0x%02x, ", out[i]);
	printf("0x%02x };\r\n\r\n", out[i+1]);
	return 0;
}