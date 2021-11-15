*-----------------------------------------------------------
* Title      :Group Project    
* Written by :David Woo 
* Date       :11/7/2021 
* Description:
*-----------------------------------------------------------
*   Main program
*--------------------------------------------------------------------


*--------------------------------------------------------------------
* User Input for staring address
*--------------------------------------------------------------------

START   ORG     $1000                      ; first instruction of program
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
        
InputE  MOVE.B     #8,D3            *Read 8 digit hexdecimal value in D3;
        LEA        MessageEn,A1
        MOVE.B     #14,D0
        TRAP       #15  
        MOVE.B     #2,D0                     Trap task 2 does the following:
        TRAP       #15             *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
        JMP        AtoH
        
AtoH    MOVE.B     (A1)+,D6        * move user input data from (A1) to D6          

        CMPI.B      #$30,D6
        BLT.B       ERR 
        CMP.B       #$39,D6 
        BGT.B       ALPHA    
        SUBI.B      #$30,D6
        BRA         AddressCounting       
        RTS     

ERR     LEA         ERRM,A1
        MOVE.B      #14,D0  
        TRAP        #15    
        BRA         Input   
        
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
                ASL.B   #$04,D5
                CMP.B   #$0,D3
                BNE     AtoH

StartingAd                MOVE.L    D5,Addr1
                                JMP         InputE

EndingAd                 MOVE.L    D5,Addr2                            

        
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

MESSAGE1    DC.B    'Welcome to A Disassembler for the Motorola MC68000 Microprocessor',CR,LF
            DC.B    'Type your address that must be 8 hexdecimal characters',CR,LF
            DC.B    'The Starting address must be greater than $00001000.',CR,LF
            DC.B    'The ending address must be greater than the starting address.',CR,LF 
            DC.B    'The address should be even number address!',CR,LF,0

MessageSt      DC.B         'Enter the starting address',CR,LF,0    

MessageEn     DC.B          'Enter the Ending address',CR,LR,0

ERRM         DC.B     'Enter Valid hexadecimal value: ', 0
*---------------------------------------------------------------------          
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
