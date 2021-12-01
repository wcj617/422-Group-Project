*-----------------------------------------------------------
* Title      : Logical shift
* Written by : Laurence Monson
* Date       : 11/12/2021
* Description: program that decodes logical shift instruction
*               given that the first bits are $E and prints
*               the fields
*-----------------------------------------------------------
    ORG    $1000
Start       movea.l #$A000, a1
            move.w #%111000101101010, (a1) *shift d2 by count register 1 to the right, word level

            move.w (a1), d0 *get count/register
            rol.w #7, d0
            and.w #$0007, d0
            move.w d0, count
             
            move.w (a1), d0 * get direction
            rol.w #8, d0
            and.w #$0001, d0
            move.w d0, dr
            
            move.w (a1), d0 *get size
            ror.w 6, d0
            and.w #$0003, d0
            move.w d0, size
            
            move.w (a1), d0 *get ir
            ror.w 5, d0
            and.w #$0001, d0
            move.w d0, ir
            
            move.w (a1), d0 *get mode
            ror.w 3, d0
            and.w #$0007, d0
            move.w d0, mode
            
            move.w (a1), d0 *get register
            and.w #$0007, d0
            move.w d0, register
            
            LEA Count_msg, a1
            move.b #14, d0
            TRAP #15
            move.l count, d1
            move.b #3, d0
            TRAP #15
            LEA LINEBREAK, a1
            move.b #14, d0
            TRAP #15

            LEA Count_msg, a1
            move.b #14, d0
            TRAP #15
            move.l count, d1
            move.b #3, d0
            TRAP #15
            LEA LINEBREAK, a1
            move.b #14, d0
            TRAP #15            
            
            
            
            

                  






    SIMHALT          
    END Start

*--Messages---------------------------------------------
CR                      EQU $0D 
LF                      EQU $0A
LINEBREAK               dc.b CR, LF, 0
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



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
