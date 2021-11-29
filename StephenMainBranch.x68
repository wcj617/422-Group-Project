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
        
        MOVE.B  #1,WORD_LONG_SWITCH
        MOVE.L  #$00002000,A3
        MOVE.W  #$6000,(A3)+       * JSR test value
         
        
InputS  MOVE.B     #8,D3            *Read 8 digit hexdecimal value in D3;
        LEA        MessageSt,A1
        MOVE.B     #14,D0
        TRAP       #15
        MOVE.B     #2,D0                   *  Trap task 2 does the following:
        TRAP       #15             *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
        JMP        AtoH
        
InputE  CLR.L      D5
        CLR.L      D6      
        MOVE.B     #8,D3            *Read 8 digit hexdecimal value in D3;
        LEA        MessageEn,A1
        MOVE.B     #14,D0
        TRAP       #15  
        MOVE.B     #2,D0                   *  Trap task 2 does the following:
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

** Addr1 now contains the starting address
** Addr2 now contains the ending address
EndingAd          MOVE.L  D5,Addr2                            
                  MOVE.L  Addr1,A6
                  
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
                  JSR     START_DECODE 
                  
                  **  Check for bad data
                  MOVE.B  #$00,(A5)+   * Terminate string
                  LEA     PRINTER,A1   
                  MOVE.B  #13,D0       * Print
                  TRAP    #15
                  
                  LEA     NEWLINE,A1
                  MOVE.B  #13,D0
                  TRAP    #15
                  BRA     CHECK_ENDING
                  
** Convert hex to ascii and print memory addresses --------------------
** EXPECT: Clear registers, current address at A6, D2,D3,D4,D5 *************************************
**         D2 used to convert whatever you need to ascii, WORD_LONG_SWITCH determines length
PRINT_CURRENT_ADR
                  MOVE.L  A6,D2
                  MOVE.B  #0,D5
                  CMPI.B  #0,WORD_LONG_SWITCH
                  BEQ     SET_WORD_COUNTER
                  MOVE.B  #4,D6         * Loop 4 times for a long
                  BRA     CHECK_LOOP
                  
SET_WORD_COUNTER  MOVE.B  #2,D6         * Loop 2 times for a word
                  
CHECK_LOOP
                  CMP.B   D5,D6
                  BNE     CONVERT_HEX_TO_ASCII
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

** Calculate jump table offset and jump to opcode
START_DECODE
        MOVE.W      D7, D6                          
        ROL.W       #4, D6				            
        MOVE.W      D6, D5
        LEA         OPCODE_JUMP_TABLE, A0      	    
        ANDI.W      #$000F, D6
        MULU        #8, D6             	            
        JSR         0(A0,D6)          	            
        RTS        
*******************************************************************************************
                
OPCODE_JUMP_TABLE
                JSR     OPCODE0000                           * - ADDI
                RTS
                JSR     OPCODE0001                           * - MOVE.B 
                RTS
                JSR     OPCODE0010                           * - MOVE.L
                RTS
                JSR     OPCODE0011                           * - MOVE.W
                RTS
                JSR     OPCODE0100                           * - MOVEM, LEA, JSR, CLR, RTS, NOP
                RTS
                JSR     OPCODE0101                           * - BAD DATA ----------------------------------   
                RTS   
                JSR     OPCODE0110                           * - BCC, BLE, BGT
                RTS
                JSR     OPCODE0111                           * - MOVEQ
                RTS
                JSR     OPCODE1000                           * - DIVU
                RTS 
                JSR     OPCODE1001                           * - SUB
                RTS
                JSR     OPCODE1010                           * - BAD DATA ----------------------------------
                RTS  
                JSR     OPCODE1011                           * - CMP
                RTS
                JSR     OPCODE1100                           * - AND, MULS
                RTS
                JSR     OPCODE1101                           * - ADDA, ADD
                RTS
                JSR     OPCODE1110                           * - ASR, LSL, ROL
                RTS  
                JSR     OPCODE1111                           * - BAD DATA -------------------------------------
                RTS
*********************************************************
* 0100 Jump Table - USE FOR CLR, JSR, LEA, RTS - NOT MOVEM
THREE_TABLE     
                JSR     THREE000            - LEA                  
                RTS                                 
                JSR     THREE001            - LEA, CLR        
                RTS                                 
                JSR     THREE010            - LEA
                RTS                                 
                JSR     THREE011            - LEA        
                RTS                                 
                JSR     THREE100            - LEA, MOVEM        
                RTS                                 
                JSR     THREE101            - LEA
                RTS                                 
                JSR     THREE110            - LEA, MOVEM        
                RTS                                 
                JSR     THREE111            - LEA, JSR, NOP, RTS       
                RTS    
** 0100 Jump Table - USE FOR CLR, JSR, LEA, RTS - NOT MOVEM
*THREE_TABLE_2     
*                JSR     THREE2000           - CLR.B               
*                RTS                                 
*                JSR     THREE2001           - CLR.W       
*                RTS                                
*                JSR     THREE2010           - CLR.L, MOVEM.W
*                RTS                                 
*                JSR     THREE2011           - MOVEM.L, JSR        
*                RTS                                 
*                JSR     THREE2100           - Bad Data       
*                RTS                                 
*                JSR     THREE2101           - Bad Data
*                RTS                                 
*                JSR     THREE2110           - Bad Data
*                RTS                                 
*                JSR     THREE2111           - LEA     
*                RTS    

************* JSR, RTS, NOP, LEA, CLR, MOVEM  *****************
OPCODE0100
    * CHECK IF MOVEM
    MOVE.W          D6,D4
    ANDI.W          #$0B80, D4
    CMP.W           #$0880, D4
*    BEQ             COPCODE0100
    CLR.L           D4  

    * CHECK IF JSR RTS NOP LEA CLR 
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE, A0  * Jump to three table based on next 3 bits
    JSR             00(A0,D6)   
    RTS
    
***** BRA  (can be BCC) *****
OPCODE0110
    MOVE.W          D5,D6
    ROL.W           #4,D6
    MOVE.W          D6,D5
    ANDI.W          #$000F,D6
    CMP.W           #$0,D6     * Check if next 4 bits = #$0
    BEQ             OPCODE_BRA
    ADD.B           #10,BAD_DATA_SWITCH
    RTS
    
OPCODE0000                           * - ADDI
OPCODE0001                           * - MOVE.B 
OPCODE0010                           * - MOVE.L
OPCODE0011                           * - MOVE.W
OPCODE0101                           * - BAD DATA ----------------------------------    
OPCODE0111                           * - MOVEQ
OPCODE1000                           * - DIVU
OPCODE1001                           * - SUB
OPCODE1011                           * - CMP                                                              * - ADDA, ADD
OPCODE1100
OPCODE1101
OPCODE1110                           * - ASR, LSL, ROL
THREE000                                                        
THREE001               
THREE010 
THREE011           
THREE100               
THREE101        
THREE110                
         
***INVALID OPCODES
OPCODE0101       
    ADD.B       #10, BAD_DATA_SWITCH           
    RTS
OPCODE1010  
    ADD.B       #10, BAD_DATA_SWITCH              
    RTS                         
OPCODE1111 
    ADD.B       #10, BAD_DATA_SWITCH               
    RTS   
    
    
OPCODE_BRA
          MOVE.B    #'B',(A5)+
          MOVE.B    #'R',(A5)+
          MOVE.B    #'A',(A5)+
          MOVE.B    #' ',(A5)+
          MOVE.B    #' ',(A5)+
          MOVE.B    #' ',(A5)+
          
OPCODE0110_DISPLACEMENT
    MOVE.W          D7,D6                           *D7:6XXX  -> D6:6XXX
    MOVE.L          A6,D5                           *Save current address to D5
    MOVE.B          #0,D0                           *Set counter
    MOVE.B          #8,D1                           *Max Counter 
    ANDI.W          #$00FF, D6                      *D6:00XX
    CMP.W           #$00,D6                         *XX:00, then check the next 2 bytes from current address
    BEQ             OPCODE0110_DISPLACEMENT_WORD    
    CMP.W           #$FF,D6                         *XX:FF, then check the next 4 bytes from current address
    BEQ             OPCODE0110_DISPLACEMENT_LONG
    BRA             OPCODE011_TWOSCOMPLEMENT_BYTE   *XX:00<XX<FF, then must do twos complement because we have to subtract

OPCODE0110_DISPLACEMENT_WORD
    MOVE.W          (A6)+,D6                        *Save the next word size from current address
    MOVE.B          #16,D1                          *Set counter for word-bit size
    MOVE.W          D6,D4                           *Copy D6 to D4
    ANDI.W          #$8000,D4   
    CMP.W           #$8000,D4                       *Checking to see if I need to go backwards
    BEQ             OPCODE011_TWOSCOMPLEMENT_WORD   
    ADD.W           D6,D5                           *Else, add the value with current address
    BRA             OPCODE0110_PRINT                *print word

OPCODE0110_DISPLACEMENT_LONG                        *same as OPCODE0110_DISPLACEMENT_WORD but for Long
    MOVE.L          (A6)+,D6                        
    MOVE.B          #32,D1
    MOVE.L          D6,D4
    ANDI.L          #$80000000,D4
    CMP.L           #$80000000,D4
    BEQ             OPCODE011_TWOSCOMPLEMENT_WORD
    ADD.L           D6,D5
    BRA             OPCODE0110_PRINT
* OPCODE011_TWOSCOMPLEMENT-----------------------------------------
OPCODE011_TWOSCOMPLEMENT_BYTE
    ROL.B       #1,D6                               *Check bit by bit for byte size        
    BCS         OPCODE011_TWOSCOMPLEMENT_ONE
    BRA         OPCODE011_TWOSCOMPLEMENT_ZERO
OPCODE011_TWOSCOMPLEMENT_WORD
    ROL.W       #1,D6                               *Check bit by bit for word size
    BCS         OPCODE011_TWOSCOMPLEMENT_ONE
    BRA         OPCODE011_TWOSCOMPLEMENT_ZERO    
OPCODE011_TWOSCOMPLEMENT_LONG
    ROL.L       #1,D6                               *Check bit by bit for long size
    BCS         OPCODE011_TWOSCOMPLEMENT_ONE
OPCODE011_TWOSCOMPLEMENT_ZERO
    ADDI.B      #1,D6                               *Add one if its zero
    BRA         OPCODE011_TWOSCOMPLEMENT_LOOP
OPCODE011_TWOSCOMPLEMENT_ONE    
    SUBI.B      #1,D6                               *Sub one if its one
OPCODE011_TWOSCOMPLEMENT_LOOP
    ADDI.B      #1,D0                               *increase the counter
    CMP.B       D0,D1                               *check if it is done
    BEQ         OPCODE011_TWOSCOMPLEMENT_ADD_ONE    
    CMP.B       #8,D1                               *check the counter size to jump to byte,word, or long
    BEQ         OPCODE011_TWOSCOMPLEMENT_BYTE
    CMP.B       #16,D1
    BEQ         OPCODE011_TWOSCOMPLEMENT_WORD
    CMP.B       #32,D1
    BEQ         OPCODE011_TWOSCOMPLEMENT_LONG
OPCODE011_TWOSCOMPLEMENT_ADD_ONE
    ADDI.W      #$1,D6                              *complete twos complement by adding $1 to the value             
    SUB.L       D6,D5                               
    
OPCODE0110_PRINT
    CMP.L           #$FFFF,D5                       *check to see if the address exceeds word size
    BGT             OPCODE0110_PRINT_LONG           *if it does, print long
    MOVE.B          #0,WORD_LONG_SWITCH
    CLR.L           D6                              *clear it because WORD_ASCII uses D6 
    JSR             PRINT_CURRENT_ADR
    RTS
OPCODE0110_PRINT_LONG
    MOVE.B          #1,WORD_LONG_SWITCH
    JSR             PRINT_CURRENT_ADR
    RTS 
    
*RTS
OPCODE_RTS
          CMPI.W    #$4E75,$0000
          BEQ       OPCODE_RTS_PRINT
          RTS
OPCODE_RTS_PRINT
          MOVE.B    #'R',(A5)+
          MOVE.B    #'T',(A5)+
          MOVE.B    #'S',(A5)+
          RTS
*********
*JSR
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
          ** Get next word or long and print
          ASR.W     #1,D7
*******************

THREE111
    CMP.W           #$4E75, D7                      * Is this an RTS function
    BEQ             IS_RTS                          * If so go to the ITSARTS function
    CMP.W           #$4E71, D7
    BEQ             IS_NOP
IS_JSR
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
*    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6)   
    RTS
IS_NOP
    MOVE.B  #'N',(A5)+						
    MOVE.B  #'O',(A5)+					
    MOVE.B  #'P',(A5)+						
    RTS  
IS_RTS
    MOVE.B  #'R',(A5)+						
    MOVE.B  #'T',(A5)+						
    MOVE.B  #'S',(A5)+						
    RTS  

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
WORD_LONG_SWITCH  DS.L   1   * 0 for word, 1 for long
BAD_DATA_SWITCH DS.L    1 
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
