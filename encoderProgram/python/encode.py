import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--foo', help='foo help')
parser.add_argument("--hex", help="Input hex strings to decode Ex: 0xff, 0xde, 0xed")
args = parser.parse_args()

get_bin = lambda x, n: format(x, 'b').zfill(n)

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

ghost = decode[ifhead+32]+ghost


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
