/*
 * Program to Decode and encode old transponder format for rc cars
 * 
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
package rctcode;

public class RCtcode {

    public static void main(String[] args) {

        int numberToEncode = 3456789; // input number to encode to transponder format
        
        if (args[0] != null) {
            numberToEncode = Integer.parseInt(args[0]);
        }
        
        String unknown = "0000000000"; // the unknown bits
        
        
        String known = "1110000111001011111111010010100100101000000100110001110100010011001111110000";
        
        int ifhead = 0; //0 or 8

        String decode = "";
        for (int i=1;i<known.length();i++) {
            if (known.charAt(i-1) == known.charAt(i)) {
                decode+="0";
            }
            else {
                decode+="1";
            }
            i++;
        }
        
        String slask = "";
        
        slask = decode.charAt(ifhead+1)+slask;
        slask = decode.charAt(ifhead+2)+slask;
        slask = decode.charAt(ifhead+3)+slask;
        
        slask = decode.charAt(ifhead+5)+slask;
        slask = decode.charAt(ifhead+6)+slask;
        slask = decode.charAt(ifhead+7)+slask;
        
        slask = decode.charAt(ifhead+9)+slask;
        slask = decode.charAt(ifhead+10)+slask;
        slask = decode.charAt(ifhead+11)+slask;
        
        slask = decode.charAt(ifhead+13)+slask;
        slask = decode.charAt(ifhead+14)+slask;
        slask = decode.charAt(ifhead+15)+slask;
        
        slask = decode.charAt(ifhead+17)+slask;
        slask = decode.charAt(ifhead+18)+slask;
        slask = decode.charAt(ifhead+19)+slask;
        
        slask = decode.charAt(ifhead+21)+slask;
        slask = decode.charAt(ifhead+22)+slask;
        slask = decode.charAt(ifhead+23)+slask;
        
        slask = decode.charAt(ifhead+25)+slask;
        slask = decode.charAt(ifhead+26)+slask;
        slask = decode.charAt(ifhead+27)+slask;
        
        slask = decode.charAt(ifhead+29)+slask;
        slask = decode.charAt(ifhead+30)+slask;
        slask = decode.charAt(ifhead+31)+slask;
        
        
        
        
        int foo = Integer.parseInt(slask, 2);
        System.out.println("known decoded: "+decode);
        System.out.println("known decoded int: "+foo);
        
        String encode = String.format("%24s", Integer.toBinaryString(numberToEncode)).replace(' ', '0'); 
        
        String encode2 = "";
        int countunknown = 0;
        for (int i=0;i<encode.length();i++) {
            encode2 = encode.charAt(i)+encode2;
            if (i==2 || i==5 || i==8 || i==11 || i==14 || i==17 || i==20 || i==23 || i==26 || i==29) {
                encode2 = ""+unknown.charAt(countunknown)+encode2;
                countunknown++;
            }
        }
        encode2 += "00000000";
        String encodeMatrix = "00000000000000000000000000000000000000"+encode2; // 36 zero + message
        System.out.println("      encode2: "+encode2);
        String encodeOut = "";
        for (int i=36;i<encodeMatrix.length()-1;i++) {
            String temp = ""+encodeMatrix.charAt(i)+
                    encodeMatrix.charAt(i-1)+
                    encodeMatrix.charAt(i-2)+
                    encodeMatrix.charAt(i-3)+
                    encodeMatrix.charAt(i-9)+
                    encodeMatrix.charAt(i-14)+
                    encodeMatrix.charAt(i-15)+
                    encodeMatrix.charAt(i-17)+
                    encodeMatrix.charAt(i-18)+
                    encodeMatrix.charAt(i-19)+
                    encodeMatrix.charAt(i-21)+
                    encodeMatrix.charAt(i-22)+
                    encodeMatrix.charAt(i-23)+
                    encodeMatrix.charAt(i-36);
            int count1 = 0;
            for (int y=0;y<temp.length();y++) {
                if ( temp.charAt(y)=='1') {
                    count1++;
                }
            }
            //System.out.println("FF: "+FF+" : "+count1);
            if ( (count1 & 1) == 0 ) { 
                //even... puts out 0
                if (encodeMatrix.charAt(i-1) == '1') {
                    encodeOut+="01";
                } else {
                    encodeOut+="00";
                }
                
            } else { 
                //odd... puts out 1
                if (encodeMatrix.charAt(i-1) == '1') {
                    encodeOut+="10";
                } else {
                    encodeOut+="11";
                }
            }
        }
        System.out.println("    encodeOut:  "+encodeOut.substring(6));
        
        String encode2HEX = encodeOut.substring(6);
        int count = 1;
        for (int i=0;i<encode2HEX.length();i=i+8) {
            if (i+8>=encode2HEX.length()) {
                break;
            }
            int number = Integer.parseInt(encode2HEX.substring(i, i+8), 2);
            String Hex=Integer.toHexString(number);
            System.out.println(" 	ldi  d"+count+",  0x"+Hex);
            count++;
        }
    }
}
