*-----------------------------------------------------------
* Title      : Logical shift
* Written by : Laurence Monson
* Date       : 11/12/2021
* Description: program that 
*-----------------------------------------------------------
    ORG    $1000
Start       movea.l #$A000, a1
            move.w #%111000101101010, (a1) *shift d2 by count register 1 to the right, word level

            move.w (a1), d0 *get count/register
            rol.w #7, d0
            and.w #%000000000000111, d0
            move.w d0, count
             
            move.w (a1), d0 * get direction
            rol.w #8, d0
            and.w #%000000000000001, d0
            move.w d0, dr
            
            move.w (a1), d0 *get size
            ror.w 5, d0
            and.w #%000000000000011
            
            move.w (a1), d0 *get ir
            ror.w 4, d0
            and.w #%000000000000001
            
            
            
            

                  






    SIMHALT          
    END Start

*--Messages---------------------------------------------
CR                      EQU $0D 
LF                      EQU $0A
Count_msg               dc.b 'Count: ', 0
Count_Register_msg      dc.b 'Count Register: ', 0
Direction_msg           dc.b 'Direction: ', 0
Size                    dc.b 'Size: ', 0
Data_Register           dc.b 'Data register: ', 0

*--variables--------------------------------------------
count           ds.w 1
dr              ds.b 1
size            ds.w 1
ir              ds.b 1
register        ds.w 1
mode            ds.w 1
*--Labels-&-Constants------------------------------------
Dn_Mode             dc.w    000
An_Mode             dc.w    001        
Indirect_An_Mode    dc.w    010
Post_Increment      dc.w    011
ADD_Pre_Increment   dc.w    100
ADD_Absolute_Mode   dc.w    111

*------------Operation: <ea> + Dn -> Dn-----------------
Opmode_Byte1        dc.w    000
Opmode_Word1        dc.w    001
Opmode_Long1        dc.w    010
*------------Operation: Dn + <ea> -> Dn-----------------
Opmode_Byte2        dc.w    100
Opmode_Word2        dc.w    101
Opmode_Long2        dc.w    010

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
