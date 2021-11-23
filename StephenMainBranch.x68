*-----------------------------------------------------------
* Title      :Group Project    
* Written by :David Woo, Stephen Swetonic
* Date       :11/7/2021 
* Description:
*-----------------------------------------------------------
*   Main program
*--------------------------------------------------------------------


*--------------------------------------------------------------------
* User Input for staring address
*--------------------------------------------------------------------

START   ORG     $1000
        MOVE.B  #2,D4                  *for Starting and Ending address                      ; first instruction of program
        LEA     GREETING_MSG,A1
        MOVE.B  #14,D0
        TRAP    #15 
        
        
        
InputS  MOVE.B     #8,D3            *Read 8 digit hexdecimal value in D3;
        LEA        MessageSt,A1
        MOVE.B     #14,D0
        TRAP       #15
        MOVE.B     #2,D0                     Trap task 2 does the following:
        TRAP       #15             *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
        JMP        AtoH
        
InputE  CLR.L      D5
        CLR.L      D6      
        MOVE.B     #8,D3            *Read 8 digit hexdecimal value in D3;
        LEA        MessageEn,A1
        MOVE.B     #14,D0
        TRAP       #15  
        MOVE.B     #2,D0                     Trap task 2 does the following:
        TRAP       #15             *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
        JMP        AtoH
        
AtoH    MOVE.B      (A1)+,D6        * move user input data from (A1) to D6          
        CMPI.B      #$30,D6
        BLT.B       ERR 
        CMP.B       #$39,D6 
        BGT.B       ALPHA    
        SUBI.B      #$30,D6
        BRA         AddressCounting

ERR     LEA         ERRM,A1
        MOVE.B      #14,D0  
        TRAP        #15    
        BRA         InputS   
        
ALPHA   CMPI.B      #$41,D6 
        BLT.B       ERR
        CMPI.B      #$46,D6 
        BGT.B       ERR 
        SUBI.B      #$37,D6
        BRA         AddressCounting    
        RTS
        
AddressCounting   ADD.B   D6,D5 
                  SUBI.B  #1,D3  
                  CMP.B   #$0,D3    
                  BEQ     StartingAd          
                  ASL.L   #$04,D5
                  CMP.B   #$0,D3
                  BNE     AtoH

StartingAd        SUBI.B  #1,D4
                  CMP.B   #$0,D4
                  BEQ     EndingAd
                  MOVE.L  D5,Addr1
                  JMP     InputE

** Addr1 now contains the ending address
** Addr2 now contains the starting address
EndingAd          MOVE.L  D5,Addr2                            
                  MOVE.L  Addr1,A6
                  
** Use A6 for current address?
CHECK_ENDING
                  MOVE.L  Addr2,A5
                  CMPA.L  A6,A5
                  BEQ     ENDING
                  ADD.L   #$2,A6
                  BRA     PRINT_CURRENT_ADR
                  
                  
** EXPECT: Clear registers, current address at A6
PRINT_CURRENT_ADR
                  JSR     CLEAR_REGISTERS
                  MOVE.L  A6,D2
                  MOVE.B  #0,D5
                  MOVE.B  #4,D6  * Loop 4 times
                  
CHECK_LOOP
                  CMP.B   D5,D6
                  BNE     CONVERT_HEX_TO_ASCII
                  LEA     NEWLINE,A1
                  MOVE.B  #14,D0
                  TRAP    #15
                  BRA     CHECK_ENDING
                  
CONVERT_HEX_TO_ASCII
                  MOVE.L  D2,D3
                  EOR.L   #%00000000111111111111111111111111,D3  
                  AND.L   D2,D3
                  LSR.L   #8,D3
                  LSR.L   #8,D3
                  LSR.L   #8,D3      * D3 has leftmost byte
                  MOVE.B  D3,D4 
                  EOR.B   #%00001111,D4
                  AND.B   D3,D4   
                  LSR.B   #4,D4       * D4 has left 4 bits
                  JSR     CHECK_CHAR
                  MOVE.B  D3,D4
                  EOR.B   #%11110000,D4
                  AND.B   D3,D4      * D4 has right 4 bits
                  JSR     CHECK_CHAR
                  ASL.L   #8,D2       * Shift original left 1 byte
                  ADDI.B  #1,D5
                  BRA     CHECK_LOOP

CHECK_CHAR
                  CMP.B   #$A,D4
                  BLT     HEX_TO_NUM
                  ADDI.B  #$37,D4
                  MOVE.B  D4,D1
                  JSR     PRINT_CHAR
                  RTS
        
HEX_TO_NUM
                  ADDI.B  #$30,D4
                  MOVE.B  D4,D1
                  JSR     PRINT_CHAR
                  RTS
                  
PRINT_CHAR
                  MOVE.B  #6,D0
                  TRAP    #15
                  CLR.L   D1
                  RTS
                
** Jump Table **
                  JSR     OPCODE_RTS
                  JSR     OPCODE_JSR


OPCODE_RTS
                  CMPI.W   #$4E75,$0000

OPCODE_JSR

ENDING





CLEAR_REGISTERS
        CLR.L   D0
        CLR.L   D5
        CLR.L   D2
        CLR.L   D1
        CLR.L   D3
        CLR.L   D4
        CLR.L   D6
        MOVE.L  #$00000000,A1
        MOVE.L  #$00000000,A2
        MOVE.L  #$00000000,A3
        MOVE.L  #$00000000,A4
        MOVE.L  #$00000000,A5
        RTS
        
*---------------------------------------------------------------------
*Variable
*---------------------------------------------------------------------
Addr1       DS.L    1
Addr2       DS.L    1   
*---------------------------------------------------------------------
*MESSAGE
*---------------------------------------------------------------------
CR      EQU     $0D             ASCII code for Carriage Return
LF      EQU     $0A             ASCII code for Line Feed

GREETING_MSG    DC.B    'Welcome to A Disassembler for the Motorola MC68000 Microprocessor',CR,LF
                DC.B    'Type your address that must be 8 hexdecimal characters',CR,LF
                DC.B    'The Starting address must be greater than $00001000.',CR,LF
                DC.B    'The ending address must be greater than the starting address.',CR,LF 
                DC.B    'The address should be even number address!',CR,LF,0
                
NEWLINE         DC.B    CR,LF,0

MessageSt               DC.B         'Enter the starting address:',CR,LF,0    

MessageEn               DC.B         'Enter the Ending address:',CR,LF,0 

ERRM         DC.B     'Enter Valid hexadecimal value: ', 0
*---------------------------------------------------------------------          
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
