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
        
        MOVE.L  #$00002000,A3
        MOVE.W  #$4E91,(A3)+

        
        
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
** Compare starting and ending addresses -------------------------------
** EXPECT: D7 stores the opcode and A6 the current address
CHECK_ENDING
                  MOVE.L  Addr2,A5
                  CMPA.L  A6,A5
                  BEQ     ENDING
                  
                  MOVE.L  #$00000000,A5
                  CMP.B   #25,LINE_COUNTER
                  BNE     CONT_ADR_LOOP
                  ** JSR   User response
CONT_ADR_LOOP
                  ADD.B   #1,LINE_COUNTER
                  JSR     CLEAR_REGISTERS
                  JSR     PRINT_CURRENT_ADR
                  JSR     CLEAR_REGISTERS
                  
                  LEA     PRINTER,A5   * Reset printer back
                  MOVE.W  (A6)+,D7
                  JSR     OPCODE_JUMP_TABLE  
                  
                  **  Check for bad data
                  MOVE.B  #$00,(A5)+   * Terminate string
                  LEA     PRINTER,A1   
                  MOVE.B  #13,D0       * Print
                  TRAP    #15
                  BRA     CHECK_ENDING
                  
** Convert hex to ascii and print memory addresses --------------------
** EXPECT: Clear registers, current address at A6, D2,D3,D4,D5 *************************************
PRINT_CURRENT_ADR
                  MOVE.L  A6,D2
                  MOVE.B  #0,D5
                  MOVE.B  #4,D6  * Loop 4 times
                  
CHECK_LOOP
                  CMP.B   D5,D6
                  BNE     CONVERT_HEX_TO_ASCII
                  LEA     NEWLINE,A1
                  MOVE.B  #14,D0
                  TRAP    #15
                  RTS
                  
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
********************************************************************************************
                
OPCODE_JUMP_TABLE
                  JSR     OPCODE_RTS
                  RTS
                  JSR     OPCODE_JSR
                  RTS


OPCODE_RTS
                  CMPI.W   #$4E75,$0000

OPCODE_JSR
          MOVE.W    D7,D6
          ASR.W     #6,D6
          CMP.W     #$013A,D6
          BEQ       OPCODE_JSR_EA
          RTS
    
OPCODE_JSR_EA
          ** PRINT JSR
          MOVE.B    #'J',(A5)+
          MOVE.B    #'S',(A5)+
          MOVE.B    #'R',(A5)+
          MOVE.B    #' ',(A5)+
          MOVE.W    D7,D5
          MOVE.W    D7,D4
          EOR.W     #%1111111111000111,D4
          AND.W     D1,D4
          CMP.B     #$10,D4
          BEQ       OPCODE_JSR_IND
          CMP.B     #$38,D4
          BEQ       OPCODE_JSR_DIR
    
* Test for address reg number (stored in D2)
OPCODE_JSR_IND
          MOVE.B    #'(',(A5)+
          MOVE.B    #'A',(A5)+
          MOVE.W    D7,D5
          MOVE.W    D7,D4
          EOR.W     #%1111111111111000,D4
          AND.W     D4,D5
          ADDI.B    #$30,D5
          MOVE.B    D5,(A5)+
          MOVE.B    #')',(A5)+
          RTS
    
OPCODE_JSR_DIR 
          ** Get next word or long and print
          ASR.W     #1,D7

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
Addr1         DS.L    1
Addr2         DS.L    1
LINE_COUNTER  DS.L    1
PRINTER       DC.L    1  * Printer pointer
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
