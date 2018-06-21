NEW! Arduino code
=================

I strongly recomend switching to the arduino based code. All future changes will be made here. It is much more easy to work with now that I have managed to get the critical timings right to send a correct signal. 

To add support for attiny in Arduino follow this guide https://create.arduino.cc/projecthub/arjun/programming-attiny85-with-arduino-uno-afb829

Do note that if you try to program your attiny mounted in the transponder you need to desolder the resistor on the antenna loop or the device will not respond correctly ( giving wrong board id errors and not responding well at all etc...) And you still need to supply the chip with an own oscilator source because it do not like to use the 20mhz crystal in programming mode for some reason.


openAST
=======

open source Axx Simulated transponder


This is for an attiny25 running at 20MHz

set fuse to -U lfuse:w:0xff:m in avrdude


To use the java program to encode run:

    cd encoderProgram/java/dist
    java -jar rctcode.jar 3456789

    encode2: 0101001000010111011001000101010000000000
    encodeOut:  1110000111001011111111010010100100101000000100110001110100010011001111110000
        ldi  d1,  0xe1
        ldi  d2,  0xcb
        ldi  d3,  0xfd
        ldi  d4,  0x29
        ldi  d5,  0x28
        ldi  d6,  0x13
        ldi  d7,  0x1d
        ldi  d8,  0x13
        ldi  d9,  0x3f
And the last lines you can paste in the asm file when you build your program and you have it ready to go. 


To decode, input a binary string as argument (at least 12 char) 

    java -jar rctcode.jar 1110000111001011111111010010100100101000000100110001110100010011001111110000
      known decoded: 01010010000101110110010001010100000000
      known decoded int: 3456789
