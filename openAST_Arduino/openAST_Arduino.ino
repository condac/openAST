
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

 
char timerstop = 0b01010000;
char timerstart = 0b01010001;

  char  pre1 = 0xF9;  // Header bit 1-8  // Never change
  char  pre2 = 0x16;  // Header bit 9-16 // Never change

  char  d1 =  0xFF;
  char  d2 =  0x00;
  char  d3 =  0xAA;
  char  d4 =  0xFF;
  char  d5 =  0x00;
  char  d6 =  0xAA;
  char  d7 =  0x1d;
  char  d8 =  0x13;
  char  d9 =  0x3f;
  char  d10 = 0x00;
  

void setup() {
  pinMode(0,OUTPUT);
  pinMode(1,OUTPUT);
  pinMode(2,OUTPUT);
  // put your setup code here, to run once:
  /*
ldi  timerstop, 0b0101_0000
  ldi  timerstart, 0b0101_0001 // set COM1A0 PWM1A CS10  COM1A0 tells the timer to Toggle the value on OC1A pins (page 89 attiny25 datasheet)
  out  TCCR1,timerstart        //                       CS10 set timer prescale to 1
                   //            PWM1A enable pwm output
                 // The timer needs to count to 255 before it starts to reset after 4 counts instead, don't know why

  ldi  slask, 0x02 // set the counter trigger value, the value the timer will count to before toggle the timer pin
  out  OCR1A,slask
  ldi  slask, 0x03 // set the counter trigger value, the value the timer will count to before toggle the timer pin
  out  OCR1C,slask
  */

  
  //asm("ldi  (timerstop), 0b01010000");
  //asm("ldi  (timerstart), 0b01010001");
  TCCR1 = 0b01010001;
  OCR1A = 0x02;
  OCR1C = 0x03;


}

void loop() {

  digitalWrite(2,LOW);
  while (true) {

    sendData();
    digitalWrite(2,LOW);
    delayMicroseconds(2000+random(1000));
  }
  
  
  
  //delay(100);
}

void cycle_delay() {
  asm("nop");
  asm("nop");
  asm("nop");
}

void sendByte(char inData) {

  if( (inData & (1 << 7)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  if( (inData & (1 << 6)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  
  if( (inData & (1 << 5)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  
  if( (inData & (1 << 4)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  
  if( (inData & (1 << 3)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  
  if( (inData & (1 << 2)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  
  if( (inData & (1 << 1)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();

  
  if( (inData & (1 << 0)) ) {
    TCCR1 = timerstop;
  }
  TCCR1 = timerstart; //  asm("out  TCCR1,timerstart"); // if 0 and after if 1
  cycle_delay();
  
 
}
void sendData() {
  digitalWrite(2,HIGH); // stop led while sending data
  
  TCCR1 = timerstart;


  noInterrupts();
  
  sendByte(0x00);
  sendByte(pre1);
  sendByte(pre2);
  sendByte(d1);
  sendByte(d2);
  sendByte(d3);
  sendByte(d4);
  sendByte(d5);
  sendByte(d6);
  sendByte(d7);
  sendByte(d8);
  sendByte(d9);
  sendByte(d10);
  
  TCCR1 = timerstop; //out  TCCR1,timerstop // Shut down radio
                     //ldi  slask, 0b0100_0000 // set COM1A0 (bit4) to 0 to disconnect timer pins
  TCCR1 = 0b01000000;//out  TCCR1,slask
  interrupts();

  
  
  digitalWrite(0,LOW);//cbi  PORTB, 0  // set both output to 0 to avoid current drain
  digitalWrite(1,LOW);//cbi  PORTB, 1  // set both output to 0 to avoid current drain
  
}

