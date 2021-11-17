*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

********************************************************************************************
* JMP TABLES                                             
OPCODE_JMP_TABLE
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
* 0100 Jump Table - USE FOR CLR, JSR, LEA, RTS - NOT MOVEM
THREE_TABLE_2     
    JSR     THREE2000           - CLR.B               
    RTS                                 
    JSR     THREE2001           - CLR.W       
    RTS                                
    JSR     THREE2010           - CLR.L, MOVEM.W
    RTS                                 
    JSR     THREE2011           - MOVEM.L, JSR        
    RTS                                 
    JSR     THREE2100           - Bad Data       
    RTS                                 
    JSR     THREE2101           - Bad Data
    RTS                                 
    JSR     THREE2110           - Bad Data
    RTS                                 
    JSR     THREE2111           - LEA     
    RTS    
********************************************************

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
