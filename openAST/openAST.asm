/*
 * openAST.asm
 * open source AMB Simulated transponder
 *  Created: 2014-07-21 16:09:20
 *   Author: condac
 *
 *    Notes: This is the old AMB system not compatible with the new current RC4 system

 Copyright (C) 2014  condac

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


 .include "tn25def.inc" 
 .def slask=r16 // slask = temp
 .def timerstop=r17
 .def timerstart=r18
 .def pre1=r19
 .def pre2=r20
 .def d1=r21
 .def d2=r22
 .def d3=r23
 .def d4=r24
 .def d5=r25
 .def d6=r26
 .def d7=r27
 .def d8=r28
 .def d9=r29
 .def d10=r30
 .def d11=r31


reset:
	rjmp start
start:
	//Setup timer to flip OC1A and OC1A inverted
	// To take advantage of the inverted pin of the timer output we must be in PWM mode

	ldi  timerstop, 0b0101_0000
	ldi  timerstart, 0b0101_0001 // set COM1A0 PWM1A CS10  COM1A0 tells the timer to Toggle the value on OC1A pins (page 89 attiny25 datasheet)
	out  TCCR1,timerstart        //                       CS10 set timer prescale to 1
							     //						 PWM1A enable pwm output
								 // The timer needs to count to 255 before it starts to reset after 4 counts instead, don't know why

	ldi  slask, 0x02 // set the counter trigger value, the value the timer will count to before toggle the timer pin
	out  OCR1A,slask
	ldi  slask, 0x03 // set the counter trigger value, the value the timer will count to before toggle the timer pin
	out  OCR1C,slask

	in slask,TIFR 
	sbr slask,TOV1
	out TIFR,slask 

	ldi  slask, 0x07
	out	 DDRB, slask   // PORTB => output

	// Set transponder code

	ldi  pre1, 0xF9  // Header bit 1-8  // Never change
	ldi  pre2, 0x16  // Header bit 9-16 // Never change
		
	ldi  d1,  0xE1
	ldi  d2,  0xCB
	ldi  d3,  0xFD
	ldi  d4,  0x29
	ldi  d5,  0x28
	ldi  d6,  0x13
	ldi  d7,  0x1d
	ldi  d8,  0x13
	ldi  d9,  0x3f
	ldi  d10, 0x00
	ldi  d11, 0x00 // End
	


	sts  0x0159, d11

	rjmp loop
	


loop:
	///////////////////////////////////////////////////MAIN LOOOP ///////////////////////////////////////////////////////
	// start radio
	out  TCCR1,timerstart // Start radio

	nop

	// wait a bit for radio to start
	ldi  slask, 0b0011_0000
	rcall pre_delay

	// send data
	rcall pre_delay
	rcall send_data
	//rcall pre_delay
	//rcall send_data
	//rcall pre_delay
	//rcall send_data
	// small delay and then send again
	//rcall pre_delay
	//rcall send_data

    // small delay and then send again
	//rcall pre_delay
	//rcall send_data

	
	out  TCCR1,timerstop // Shut down radio
	ldi  slask, 0b0100_0000 // set COM1A0 (bit4) to 0 to disconnect timer pins
	out  TCCR1,slask
	cbi  PORTB, 0  // set both output to 0 to avoid current drain
	cbi  PORTB, 1  // set both output to 0 to avoid current drain

	
	lds  slask, 0x0160 // load led counter from ram
	lds  d11, 0x0161
	cbi  PORTB, 2
	inc  slask
	BREQ ledtimer
ledreturn:
    SBRC d11,0 ; Skip the next instruction if bit is 0
	sbi  PORTB, 2  // set led
	nop
	sts  0x0160, slask
	sts  0x0161, d11
	lds  d11, 0x0159
	clv 

	// time between each send 3ms
	rcall delay_loop
	rcall delay_loop
	rcall delay_loop

    rcall delay_loop
	rcall delay_loop
	rcall delay_loop
	rcall delay_loop
	/*
    rcall delay_loop	
	rcall delay_loop
	rcall delay_loop
	rcall delay_loop

    rcall delay_loop
	rcall delay_loop
	rcall delay_loop
	rcall delay_loop
	
    rcall delay_loop
	*/
	rjmp loop
	///////////////////////////////////////////////////END  MAIN LOOOP ///////////////////////////////////////////////////////

test:
		// interupt timer
	ldi  slask, 0b0101_0000 // stop timer
	out  TCCR1,slask
	ldi  slask, 0b0101_0001 // start timer
	out  TCCR1,slask

delay_loop:  // Time between each signal burst
   nop
   dec   slask       
   brne   delay_loop 
   ret

pre_delay: // Time to spool up radio signal
   dec   slask       
   brne   pre_delay 
   ret

cycle_delay:
	// When this is empty the cycle time makes it 11 cycles between each number
	// to get 16 cycles we add 5 extra nop
	nop
	nop
	nop
	nop
	nop

	ret
ledtimer: 
	inc d11
	rjmp ledreturn

send_data:
   	// Start header signal

	SBRC pre1,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
    nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

/// PRE2

	SBRC pre2,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	
	SBRC pre1,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
    nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre1,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

/// PRE2

	SBRC pre2,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC pre2,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

 // Start Data

// D1
	//nop // debugtest

	SBRC d1,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d1,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D2

	
	SBRC d2,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d2,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D3

	
	SBRC d3,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d3,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d3,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	
	SBRC d3,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d3,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d3,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d3,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d3,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D4

	
	SBRC d4,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d4,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D5

	
	SBRC d5,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d5,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D6

	
	SBRC d6,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d6,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D7
	SBRC d7,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d7,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	//nop

	//D8
	SBRC d8,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	
	SBRC d8,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d8,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d8,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d8,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d8,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d8,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d8,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	
	//D9
	SBRC d9,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d9,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	
	//D10
	SBRC d10,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d10,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	//D11
	SBRC d11,7 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,6 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,5 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,4 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,3 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,2 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,1 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay

	SBRC d11,0 ; Skip the next instruction if bit is 0
    out  TCCR1,timerstop// if 1
	nop
	out  TCCR1,timerstart// if 0 and after if 1
	rcall cycle_delay
	
	ret