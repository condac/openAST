import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--hex", help="Input hex strings to decode Ex: 0xff, 0xde, 0xed")
parser.add_argument("--status-nr", help="Input the number status message counters (1-7)")
parser.add_argument("number", help="Number to encode to AMB format")
args = parser.parse_args()

get_bin = lambda x, n: format(x, 'b').zfill(n)

print(args)

def hexString(instring,offset) :
    offset1 = (offset-1)*8
    offset2 = (offset)*8
    instring = instring[offset1:offset2]
    value = int(instring,2)
    out = "0x"+format(value, '02X')

    return out

def XOR(in1, in2, in3, in4, in5):
    out = ""

    for i in range(8):
        test = int(in1[i]) + int(in2[i]) + int(in3[i]) + int(in4[i]) + int(in5[i])

        if (test % 2 == 0) :
            out = out+"0"
        else :
            out = out+"1"

    return out



def encodeOpenPT() :
    print("Encoding openPT")
    number = int(args.number)
    encode = get_bin(number,32) #Convert to binary string 24bit long
    encode2 = ""
    for i in range ( len ( encode ) ): # Reverse bit order
        encode2 = encode[i]+encode2

    preamble =  ""
    header = "10101000"

    tail = XOR(header, encode2[0:8], encode2[8:16], encode2[16:24], encode2[24:32])

    encodeIn = preamble+header+encode2+tail
    print(encodeIn)
    # Create 10 01 11 00 bit pairs
    prevBit = False
    encodeOut = ""
    for i in range ( len ( encodeIn ) ):
        if (prevBit) :
            if (encodeIn[i] == "0"):
                encodeOut = encodeOut+"11"
                prevBit = False
            else :
                encodeOut = encodeOut+"01"
                prevBit = True
        else :
            if (encodeIn[i] == "0"):
                encodeOut = encodeOut+"00"
                prevBit = False
            else :
                encodeOut = encodeOut+"10"
                prevBit = True
    print(encodeOut)
    print("                  { " +hexString(encodeOut,1), hexString(encodeOut,2),
                                            hexString(encodeOut,3), hexString(encodeOut,4),
                                            hexString(encodeOut,5), hexString(encodeOut,6),
                                            hexString(encodeOut,7), hexString(encodeOut,8),
                                            hexString(encodeOut,9), hexString(encodeOut,10),
                                            hexString(encodeOut,11), hexString(encodeOut,12)+ " }", sep=', ')

def encodeNumber() :
    number = int(args.number)
    if (args.status_nr == None):
        ghost = 0
    else:
        ghost = int(args.status_nr)

    ghost = get_bin(ghost, 7) # the fist bit in the counters is always 0, so we take 7 bits and add a 0 to the end
    #print(ghost)
    ghostbits = ghost+"0"
    #for i in range ( len ( ghost ) ): # Reverse bit order
    #    ghostbits = ghost[i]+ghostbits
    print(ghostbits)
    encode = get_bin(number,24) #Convert to binary string 24bit long
    print(encode)
    encode2 = "";
    countunknown = 0;
    for i in range ( len ( encode ) ): # Reverse bit order and insert "ghostbits" in every 4th position
        encode2 = encode[i]+encode2
        if (i==2 or i==5 or i==8 or i==11 or i==14 or i==17 or i==20 or i==23 or i==26 or i==29) :
            encode2 = ""+ghostbits[countunknown]+encode2
            countunknown = countunknown+1
    #print(encode2)

    #Here comes the magic part...

    encode2 = encode2+"00000000"+"00000000"; #Add the d9 d10 data that is always 0

    encodeMatrix = "00000000000000000000000000000000000000"+encode2; # 36 zero + message
    #print("      encode2: "+encode2);
    encodeOut = "";
    i = 36
    while (i<len(encodeMatrix)-1) :

        temp = (""+encodeMatrix[i]+
                encodeMatrix[i-1]+
                encodeMatrix[i-2]+
                encodeMatrix[i-3]+
                encodeMatrix[i-9]+
                encodeMatrix[i-14]+
                encodeMatrix[i-15]+
                encodeMatrix[i-17]+
                encodeMatrix[i-18]+
                encodeMatrix[i-19]+
                encodeMatrix[i-21]+
                encodeMatrix[i-22]+
                encodeMatrix[i-23] )

        count1 = 0;

        for y in range ( len ( temp ) ):
            if ( temp[y]=='1') :
                count1=count1+1


        if ( (count1 & 1) == 0 ) :
            # even... puts out 0
            if (encodeMatrix[i-1] == '1') :
                encodeOut+="01";
            else :
                encodeOut+="00";


        else :
            # odd... puts out 1
            if (encodeMatrix[i-1] == "1") :
                encodeOut+="10";
            else :
                encodeOut+="11";
        i = i+1
    encodeOut = encodeOut[6:]
    print(encodeOut)



    print("....................pre1  pre2  d1    d2    d3    d4    d5    d6    d7    d8    d9    d10")
    print("                  { 0xF9", "0x16", hexString(encodeOut,1), hexString(encodeOut,2),
                                            hexString(encodeOut,3), hexString(encodeOut,4),
                                            hexString(encodeOut,5), hexString(encodeOut,6),
                                            hexString(encodeOut,7), hexString(encodeOut,8),
                                            hexString(encodeOut,9), hexString(encodeOut,10)+ " }", sep=', ')

def decodeHex() :
    words = args.hex.split(",")

    numbers = []
    numbersBinary = ""
    for word in words :
        numbers.append(int(word,16))
        numbersBinary = numbersBinary + get_bin(int(word,16),8)


    decode = ""
    for index in range ( len ( numbersBinary ) ):
        if (index % 2 != 0) :

            if ( numbersBinary[index-1] == numbersBinary[index] ) :
                decode+="0"

            else :
                decode+="1"



    if ( decode[:8] == "00110111") :
        print("Valid header found")
        ifhead = 8
    else :
        print("No header or invalid header")
        ifhead = 0
    slask = ""

    ghost = ""

    ghost = decode[ifhead+0]+ghost

    slask = decode[ifhead+1]+slask
    slask = decode[ifhead+2]+slask
    slask = decode[ifhead+3]+slask

    ghost = decode[ifhead+4]+ghost

    slask = decode[ifhead+5]+slask
    slask = decode[ifhead+6]+slask
    slask = decode[ifhead+7]+slask

    ghost = decode[ifhead+8]+ghost

    slask = decode[ifhead+9]+slask
    slask = decode[ifhead+10]+slask
    slask = decode[ifhead+11]+slask

    ghost = decode[ifhead+12]+ghost

    slask = decode[ifhead+13]+slask
    slask = decode[ifhead+14]+slask
    slask = decode[ifhead+15]+slask

    ghost = decode[ifhead+16]+ghost

    slask = decode[ifhead+17]+slask
    slask = decode[ifhead+18]+slask
    slask = decode[ifhead+19]+slask

    ghost = decode[ifhead+20]+ghost

    slask = decode[ifhead+21]+slask
    slask = decode[ifhead+22]+slask
    slask = decode[ifhead+23]+slask

    ghost = decode[ifhead+24]+ghost

    slask = decode[ifhead+25]+slask
    slask = decode[ifhead+26]+slask
    slask = decode[ifhead+27]+slask

    ghost = decode[ifhead+28]+ghost

    slask = decode[ifhead+29]+slask
    slask = decode[ifhead+30]+slask
    slask = decode[ifhead+31]+slask


    foo = int(slask, 2)
    print(" binary : "+numbersBinary)
    print(" binary : ", sep='', end='')
    for index in range ( len ( decode ) ):
        print(";", sep='', end='')
        print(decode[index], sep='', end='')
    print(" ")
    print(" decoded: "+decode)
    print(" decoded int: "+str(foo) )
    print(" ghost: "+ghost)


if (args.hex != None) :
    print("decoding hex string")
    decodeHex()
if (args.number != None) :
    print("Encoding number")
    encodeNumber()
    encodeOpenPT()
