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
        
        MOVE.B  #0,LINE_COUNTER
        MOVE.B  #0,BAD_DATA_SWITCH  
        
        MOVE.B  #1,WORD_LONG_SWITCH
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
                  JSR     CLEAR_REGISTERS             * Clear registers
                  MOVE.L  Addr2,A5
                  CMPA.L  A6,A5
                  BEQ     ENDING
                  
                  MOVE.L  #$00000000,A5
                  CMP.B   #25,LINE_COUNTER
                  BNE     CONT_ADR_LOOP
                  JSR     USER_RESPONSE
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

* BAD DATA PRINTER -----------------------------------------------------
BAD_DATA
        MOVE.B      #'B',(A5)+			        * SET UP 'BAD DATA'
        MOVE.B	    #'A',(A5)+			
        MOVE.B	    #'D',(A5)+			
        MOVE.B	    #' ',(A5)+			
        MOVE.B	    #'D',(A5)+			
        MOVE.B	    #'A',(A5)+			
        MOVE.B	    #'T',(A5)+			
        MOVE.B	    #'A',(A5)+			
        MOVE.B	    #' ',(A5)+			
        MOVE.B      #' ',(A5)+
        MOVE.B	    #'$',(A5)+			
        
        MOVE.B	    #0,D6                       * Set counters
        MOVE.B      #4,D3
        MOVE.W      D7,D5                       * Bad Code to D5 to convert to ASCII

        BRA         WORD_ASCII                  * ALWAYS branch to Word to ASCII convertion
        
* NOTE: D5 is use to load whatever you want to convert to ASCII
*     : D6, d3 are the variable for the counter
* WORD TO ASCII
WORD_ASCII                      	
    	ROL.W       #4,D5                       * ROL 4 Bits to get load it to d4       	       
    	MOVE.L      D5,D4               	        
    	ANDI.L      #$0000000F,D4               * Mask evertying except the 4 bits at the left     	        
    	CMPI.B      #$09,D4             	    * Check is number or letter        
    	BLE         IS_NUM                          
    	ADDI.B      #$37,D4                        
    	BRA         IS_LET
IS_NUM                                          * ADD 30 to D4 if num         
        ADDI.B      #$30,D4           	        
    	BRA         IS_LET
IS_LET
    	ADDI.B      #1,D6               	    * ADD 30 to D4 if letter   
    	MOVE.B      D4,(A5)+            	       
    	CMP.B       D3,D6               	
    	BLT         WORD_ASCII                 
    	RTS
    	
* LONG TO ASCII    	
LONG_ASCII                      	
    	ROL.L       #4,D5               	        
    	MOVE.L      D5,D4               	        
    	ANDI.L      #$0000000F,D4       	        
    	CMPI.B      #$09,D4             	          
    	BLE         IS_NUM_L
    	ADDI.B      #$37,D4
    	BRA         IS_LET_L
IS_NUM_L 
    	ADDI.B      #$30,D4
    	BRA         IS_LET_L
IS_LET_L
    	ADDI.B      #1,D6
    	MOVE.B      D4,(A5)+ 
    	CMP.B       D3,D6               	
    	BLT         LONG_ASCII
    	RTS    	
    	
    	

                  
** Convert hex to ascii and print memory addresses --------------------
** EXPECT: Clear registers, current address at A6, D2,D3,D4,D5 *************************************
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
                
OPCODE_JUMP_TABLE

        MOVE.W      D7, D6                          
        ROL.W       #4, D6				            
        MOVE.W      D6, D5
        LEA         OPCODE_JMP_TABLE, A0      	    
        ANDI.W      #$000F, D6
        MULU        #8, D6             	            
        JSR         0(A0,D6)          	            
        RTS        

********************************************************************************
* JMP TABLES                                             
OPCODE_JMP_TABLE
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
    JSR     OPCODE0111                           * - MOVEQ
    RTS
    JSR     OPCODE1010                           * - BAD DATA ----------------------------------
    RTS  
*********************************************************
* 0100 Jump Table - USE FOR CLR, JSR, LEA, RTS - NOT MOVEM
THREE_TABLE     
                        
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
******************* MOVE.B *************************************
OPCODE0001
    MOVE.B          #'M',(A5)+
    MOVE.B          #'O',(A5)+
    MOVE.B          #'V',(A5)+
    MOVE.B          #'E',(A5)+
    MOVE.B          #'.',(A5)+
    MOVE.B          #'B',(A5)+ 
    MOVE.B          #' ',(A5)+     
    MOVE.B          #' ',(A5)+     
    MOVE.B          #' ',(A5)+     
 
OPCODE_MOVE_DECODER    *** Do Source ***
    MOVE.W          D7, D4
    ANDI.W          #$0038, D4
    CMP.W           #$0000, D4
    BEQ             DN_CASE_0001
    CMP.W           #$0001, D4
    BEQ             AN_CASE_0001
    CMP.W           #$0010, D4
    BEQ             ABSOLUTE_AN_CASE_0001
    CMP.W           #$0018, D4
    BEQ             INCREMENT_AN_CASE_0001
    CMP.W           #$0020, D4
    BEQ             DECREMENT_AN_CASE_0001
    CMP.W           #$0038, D4
    BEQ             EA_CASE_0001
    ADD.B           #10, BAD_DATA_SWITCH  
    RTS
   
C_OPCODE0001
    MOVE.B          #',',(A5)+
    MOVE.W          D7, D4
    MOVE.W          D7, D5
    ROL.W           #3,D5
    ANDI.W          #$01C0, D4
    CMP.W           #$0000, D4
    BEQ             DESTINATION_DN_CASE_0001
    CMP.W           #$0080, D4
    BEQ             DESTINATION_ABSOLUTE_AN_0001
    CMP.W           #$00C0, D4
    BEQ             DESTINATION_INCREMENT_AN_0001
    CMP.W           #$0100, D4
    BEQ             DESTINATION_DECREMENT_AN_0001
    CMP.W           #$01C0, D4
    BEQ             DESTINATION_EA_CASE_0001
    ADD.B           #10, BAD_DATA_SWITCH  
    RTS
   
DN_CASE_0001   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)     
    BRA             C_OPCODE0001
AN_CASE_0001   
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)     
    BRA             C_OPCODE0001
ABSOLUTE_AN_CASE_0001
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    BRA             C_OPCODE0001
INCREMENT_AN_CASE_0001
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    MOVE.B          #'+',(A5)+
    BRA             C_OPCODE0001
DECREMENT_AN_CASE_0001
    MOVE.B          #'-',(A5)+
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    BRA             C_OPCODE0001
EA_CASE_0001 
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    CMP.W           #$0000, D4
    BEQ             EA_000_CASE_0001
    CMP.W           #$0001, D4
    BEQ             EA_001_CASE_0001
    CMP.W           #$0004, D4
    BEQ             EA_100_CASE_0001
    ADD.B           #10, BAD_DATA_SWITCH  
    BRA             C_OPCODE0001
 
        *** Destination ***
DESTINATION_DN_CASE_0001   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)     
    RTS
DESTINATION_ABSOLUTE_AN_0001
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    RTS
DESTINATION_INCREMENT_AN_0001
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    MOVE.B          #'+',(A5)+
    RTS
DESTINATION_DECREMENT_AN_0001 
    MOVE.B          #'-',(A5)+
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    RTS
DESTINATION_EA_CASE_0001 
    MOVE.W          D7, D4
    ROL.w           #7,D4
    ANDI.W          #$0007, D4
    CMP.W           #$0000, D4
    BEQ             DEA_000_CASE_0001
    CMP.W           #$0001, D4
    BEQ             DEA_001_CASE_0001
    ADD.B           #10, BAD_DATA_SWITCH  
    RTS
   
EA_000_CASE_0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                          
    MOVE.W      (A6)+,D5                         
    MOVE.B      #4,D3 
    JSR         WORD_ASCII
    BRA         C_OPCODE0001
EA_001_CASE_0001
    
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                         
    MOVE.L      (A6)+,D5                         
    MOVE.B      #8,D3
    JSR         LONG_ASCII    
    BRA         C_OPCODE0001
EA_100_CASE_0001
    MOVE.W      D7, D4
    ANDI.W      #$F000,D4
    MOVE.B      #'#',(A5)+
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6
    CMP.W       #$2000,D4
    BEQ         EA_100_CASE_0001_LONG
    MOVE.W      (A6)+,D5 
    MOVE.B      #4,D3 
    JSR         WORD_ASCII
    BRA         C_OPCODE0001 
EA_100_CASE_0001_LONG
    MOVE.L      (A6)+,D5 
    MOVE.B      #8,D3 
    JSR         LONG_ASCII
    BRA         C_OPCODE0001  
    
    
DEA_000_CASE_0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                          
    MOVE.W      (A6)+,D5                         
    MOVE.B      #4,D3 
    JSR         WORD_ASCII
    RTS
DEA_001_CASE_0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                         
    MOVE.L      (A6)+,D5                         
    MOVE.B      #8,D3
    JSR         LONG_ASCII    
    RTS

******************* MOVE.L *****************************************************************************
OPCODE0010
    MOVE.B          #'M',(A5)+
    MOVE.B          #'O',(A5)+
    MOVE.B          #'V',(A5)+
    MOVE.B          #'E',(A5)+
    MOVE.B          #'.',(A5)+
    MOVE.B          #'L',(A5)+ 
    MOVE.B          #' ',(A5)+     
    MOVE.B          #' ',(A5)+     
    MOVE.B          #' ',(A5)+
    BRA             OPCODE_MOVE_DECODER     
******************* MOVE.W ****************************************************************************
OPCODE0011
    MOVE.B          #'M',(A5)+
    MOVE.B          #'O',(A5)+
    MOVE.B          #'V',(A5)+
    MOVE.B          #'E',(A5)+
    MOVE.B          #'.',(A5)+
    MOVE.B          #'W',(A5)+ 
    MOVE.B          #' ',(A5)+     
    MOVE.B          #' ',(A5)+     
    MOVE.B          #' ',(A5)+
    BRA             OPCODE_MOVE_DECODER 
******************* JSR RTS NOP LEA CLR MOVEM****************************************************************************    
OPCODE0100
    * CHECK IF MOVEM
    MOVE.W          D7,D4
    ANDI.W          #$0B80, D4
    CMP.W           #$0880, D4
    BEQ             COPCODE0100
    CLR.L           D4  

    * CHECK IF JSR RTS NOP LEA CLR 
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE, A0
    JSR             00(A0,D6)   
    RTS
    
    * DO MOVEM
COPCODE0100
    JSR             GEN_0100_BAD
    CMP.B           #10, BAD_DATA_SWITCH
    BEQ             LEAVE_0100
    MOVE.B          #'M',(A5)+
    MOVE.B          #'O',(A5)+
    MOVE.B          #'V',(A5)+
    MOVE.B          #'E',(A5)+
    MOVE.B          #'M',(A5)+
    MOVE.B          #'.',(A5)+
    JSR             GET_SIZE_0100
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+


    MOVE.W          D7,D4
    ANDI.W          #$0400, D4
    CMP.W           #$0000, D4
    BEQ             REG_MEM
    CMP.W           #$0400, D4
    BEQ             MEM_REG
 
REG_MEM  *<LIST>, <EA>
    CLR.L           D0
    CLR.L           D1
    MOVE.W          D7,D4
    ANDI.W          #$0038, D4
    CMP.W           #$0018, D4         
    BEQ             BAD_DATA_S
    MOVE.W          (A6)+, D4 
*LOOP    
REG_MEM_LOOP
    CMP.B           #16, D0
    BEQ             C_REG_MEM_EA
    CMP.B           #8, D1
    BNE             C_RM_LOOP
    CLR.L           D1
C_RM_LOOP
    CMP.B           #7, D0
    BLE             DO_DN
    ROL.W           #1,D4
    BCC             LOOP_COUNTER
    JSR             ADD_AN
    MOVE.B          #'/',(A5)+
    BRA             LOOP_COUNTER
DO_DN
    ROL.W           #1,D4
    BCC             LOOP_COUNTER    
    JSR             ADD_DN
    MOVE.B          #'/',(A5)+
LOOP_COUNTER
    ADD.B           #1, D0
    ADD.B           #1, D1
    BRA             REG_MEM_LOOP
*END LOOP    
    
C_REG_MEM_EA                                    *<EA>
    MOVE.B          #' ',-(A5)
    MOVE.B          #',',(A5)+
    MOVE.B          #'$',(A5)+
    JSR             GENERAL_EA_CASES
    RTS      
MEM_REG                                         *<EA>,*<LIST>
    CLR.L           D0
    CLR.L           D1
    MOVE.W          D7,D4
    ANDI.W          #$0038,D4
    CMP.W           #$0020,D4         
    BEQ             BAD_DATA_S
    MOVE.B          #'$', (A5)+
    JSR             GENERAL_EA_CASES
    MOVE.B          #',', (A5)+   
    MOVE.W          (A6)+, D4 


*MEM_REG_LOOP
MEM_REG_LOOP
    CMP.B           #16, D0
    BEQ             LEAVE_0100
    CMP.B           #8, D1
    BNE             C_MR_LOOP
    CLR.L           D1
C_MR_LOOP
    CMP.B           #8, D0
    BLE             DO_DN_POST
    ROR.W           #1,D4
    BCC             LOOP_COUNTER_POST
    JSR             ADD_AN
    MOVE.B          #'/',(A5)+
    BRA             LOOP_COUNTER_POST
DO_DN_POST
    ROR.W           #1,D4
    BCC             LOOP_COUNTER_POST    
    JSR             ADD_DN
    MOVE.B          #'/',(A5)+
LOOP_COUNTER_POST
    ADD.B           #1, D0
    ADD.B           #1, D1
    BRA             MEM_REG_LOOP
*END MEM_REG_LOOP


ADD_AN
    MOVE.B      #'A',(A5)+
    MOVE.B      D1, D2
    ADDI.B      #$30,D2
    MOVE.B      D2, (A5)+
    CLR.L       D2
    RTS 
ADD_DN
    MOVE.B      #'D',(A5)+
    MOVE.B      D1, D2
    ADDI.B      #$30,D2
    MOVE.B      D2, (A5)+
    CLR.L       D2
    RTS 

GENERAL_EA_CASES                                * (XXX).W, (XXX).L, (An)
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             EA_MODE, A0
    JSR             00(A0,D6) 
    RTS
    
GEN_0100_BAD                                * Check Bad Cases for MOVEM 
    MOVE.W          D7,D4 
    ANDI.W          #$0038,D4
    CMP.W           #$0000,D4
    BEQ             BAD_DATA_S
    CMP.W           #$0008,D4
    BEQ             BAD_DATA_S
    CMP.W           #$0028,D4
    BEQ             BAD_DATA_S
    CMP.W           #$0030,D4
    BEQ             BAD_DATA_S
    MOVE.W          D7,D4 
    ANDI.W          #$003F,D4
    CMP.W           #$003A,D4
    BEQ             BAD_DATA_S
    CMP.W           #$003B,D4
    BEQ             BAD_DATA_S
    CMP.W           #$003B,D4
    BEQ             BAD_DATA_S
    RTS
BAD_DATA_S
    ADD.B           #10, BAD_DATA_SWITCH   
    RTS     
LEAVE_0100
    RTS   
GET_SIZE_0100
    MOVE.W          D7,D4
    ANDI.W          #$0040, D4
    CMP.W           #$0000, D4
    BEQ             SIZE_0100_W
    MOVE.B          #'L',(A5)+
    RTS
SIZE_0100_W
    MOVE.B          #'W',(A5)+
    RTS            
*********************************************************
* INVALID OPCODES
OPCODE0101       
    ADD.B       #10, BAD_DATA_SWITCH           
    RTS
OPCODE1010  
    ADD.B       #10, BAD_DATA_SWITCH              
    RTS                         
OPCODE1111 
    ADD.B       #10, BAD_DATA_SWITCH               
    RTS                          
********************************************************    

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
          ** Get next word or long and print
          ASR.W     #1,D7

ENDING



* JUMP TABLE SUBROUTINES FOR OPCODE 0100 EXCEPT MOVEM ------------------------  
THREE001
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS    
THREE010
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS
THREE011
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS
THREE100
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS
THREE101
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS
THREE110
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS
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
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6)   
    RTS
IS_NOP
    MOVE.B  #'N',(A5)+						* Insert R into output
    MOVE.B  #'O',(A5)+						* Insert T into output
    MOVE.B  #'P',(A5)+						* Insert S into output
    RTS  
IS_RTS
    MOVE.B  #'R',(A5)+						* Insert R into output
    MOVE.B  #'T',(A5)+						* Insert T into output
    MOVE.B  #'S',(A5)+						* Insert S into output
    RTS       
*-------------------------------------------------------------------------------  
THREE2000
    MOVE.W      D7,D4
    ANDI.W      #$0F00,D4
    CMP.W       #$0200,D4
    BNE         ERROR
    MOVE.B      #'C',(A5)+
    MOVE.B      #'L',(A5)+
    MOVE.B      #'R',(A5)+
    MOVE.B      #'.',(A5)+
    MOVE.B      #'B',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         EA_MODE, A0
    JSR         00(A0,D6)   
    RTS
ERROR
    ADDI.B      #10,BAD_DATA_SWITCH  
    RTS
THREE2001
    MOVE.W      D7,D4
    ANDI.W      #$FF00,D4
    CMP.W       #$4200,D4
    BNE         ERROR

    MOVE.B      #'C',(A5)+
    MOVE.B      #'L',(A5)+
    MOVE.B      #'R',(A5)+
    MOVE.B      #'.',(A5)+
    MOVE.B      #'W',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         EA_MODE, A0
    JSR         00(A0,D6)   
       
    RTS

THREE2010
    MOVE.W      D7, D6
    
    ANDI.W      #$FE00, D6
    CMP.W       #$4200, D6
    BEQ         IS_CLR
    CMP.W       #$4E00, D6
    BNE         ERROR
    
    MOVE.B      #'J',(A5)+
    MOVE.B      #'S',(A5)+
    MOVE.B      #'R',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+    
    MOVE.B      #' ',(A5)+ 
    BRA         THREE2010_EA   
    
IS_CLR
    MOVE.B      #'C',(A5)+
    MOVE.B      #'L',(A5)+
    MOVE.B      #'R',(A5)+
    MOVE.B      #'.',(A5)+
    MOVE.B      #'L',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
THREE2010_EA    
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         EA_MODE, A0
    JSR         00(A0,D6)  
    RTS
THREE2011
    ADDI.B      #10,BAD_DATA_SWITCH
    RTS
THREE2100
    ADDI.B      #10,BAD_DATA_SWITCH
    RTS
THREE2101
    ADDI.B      #10,BAD_DATA_SWITCH
    RTS
THREE2110
    ADDI.B      #10,BAD_DATA_SWITCH
    RTS
THREE2111 
    MOVE.B      #'L',(A5)+
    MOVE.B      #'E',(A5)+
    MOVE.B      #'A',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         EA_MODE, A0
    JSR         00(A0,D6)  
    MOVE.B      #',',(A5)+
    
    CLR.L       D5
    MOVE.W      D7, D5
    ROL.L       #4, D5
    JSR         EAMODE001 
    RTS

EAMODE000
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'D',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         REGISTER, A0
    JSR         00(A0,D6)
    MOVEM.L     (SP)+,D0-D7
    RTS   
EAMODE001
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         REGISTER, A0
    JSR         00(A0,D6)
    MOVEM.L     (SP)+,D0-D7
    RTS       		
EAMODE010 
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'(',(A5)+  
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         REGISTER, A0
    JSR         00(A0,D6)
    MOVE.B      #')',(A5)+
    MOVEM.L     (SP)+,D0-D7
    RTS		
EAMODE011
    MOVEM.L     D0-D7,-(SP) 
    MOVE.B      #'(',(A5)+  
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         REGISTER, A0
    JSR         00(A0,D6)
    MOVE.B      #')',(A5)+
    MOVE.B      #'+',(A5)+
    MOVEM.L     (SP)+,D0-D7
    RTS
EAMODE100
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'-',(A5)+
    MOVE.B      #'(',(A5)+  
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         REGISTER, A0
    JSR         00(A0,D6)
    MOVE.B      #')',(A5)+
    MOVEM.L     (SP)+,D0-D7
    RTS      		
EAMODE101
    ADD.B       #10, BAD_DATA_SWITCH             
    RTS      		
EAMODE110
    ADD.B       #10, BAD_DATA_SWITCH             
    RTS     		
EAMODE111
    MOVEM.L     D0-D7,-(SP)
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         REGISTER, A0
    JSR         00(A0,D6)
    MOVEM.L     (SP)+,D0-D7
    RTS 		
**************** MOVEQ *********************************************************************************************************
OPCODE0111
    MOVE.W      D7, D4
    ANDI.W      #$0100, D4
    CMP.W       #$0000, D4
    BEQ         P_IS_MOVEQ                          * Check bad casses for BAD DATA for MOVEQ
    ADD.B       #10, BAD_DATA_SWITCH  
    RTS   
P_IS_MOVEQ
    MOVE.B          #'M',(A5)+
    MOVE.B          #'O',(A5)+
    MOVE.B          #'V',(A5)+
    MOVE.B          #'E',(A5)+
    MOVE.B          #'Q',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    MOVE.W          D7, D4
    ANDI.W          #$00FF, D4
    MOVE.B          #'#',(A5)+
    MOVE.B          #'$',(A5)+
    MOVE.B              #0,D6                         
    MOVE.L          D4,D5                         
    MOVE.B          #8,D3
    JSR             LONG_ASCII 
 
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
   
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             REGISTER, A0
    JSR             00(A0,D6)
    RTS 
* CLEAR REGISTERS --------------------------------------------------------
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
* SUB ROUTINES USED FOR MANY OPCODES
*********************************************************
EA_MODE
    JMP    EAMODE000      		* EA 000
    JMP    EAMODE001      		* EA 001
    JMP    EAMODE010      		* EA 010
    JMP    EAMODE011      		* EA 011
    JMP    EAMODE100      		* EA 100
    JMP    EAMODE101      		* EA 101
    JMP    EAMODE110     		* EA 110
    JMP    EAMODE111     		* EA 111
*********************************************************   
REGISTER
    JMP    REGISTER000      	* Register 000
    JMP    REGISTER001      	* Register 001
    JMP    REGISTER010      	* Register 010
    JMP    REGISTER011      	* Register 011
    JMP    REGISTER100      	* Register 100
    JMP    REGISTER101      	* Register 101
    JMP    REGISTER110      	* Register 110
    JMP    REGISTER111      	* Register 111
* Registers ------------------------------------------------
REGISTER000
    MOVE.W      D5, D6                     
    ROL.W       #8, D6
    ROL.W       #5, D6

    ANDI.W      #$0007, D6
    CMP.B       #$7,D6
    BEQ         ReadNextW
    BRA         CREGISTER000
ReadNextW
    MOVE.B	    #0,D6                           * Set 0
    MOVE.B      #'$',(A5)+
    MOVE.W      (A6)+,D5                           * Bad Code to D5
    MOVE.B      #4,D3
    JSR         WORD_ASCII
    RTS
CREGISTER000
    MOVE.B      #'0',(A5)+
    RTS
    
REGISTER001
    MOVE.W      D5, D6                     
    ROL.W       #8, D6
    ROL.W       #5, D6

    ANDI.W      #$0007, D6
    CMP.B       #$7,D6
    BEQ         ReadNextL
    BRA         CREGISTER001  
ReadNextL
    MOVE.B	    #0,D6                           * Set 0
    MOVE.B      #'$',(A5)+
    MOVE.L      (A6)+,D5                           * Bad Code to D5
    MOVE.B      #8,D3
    JSR         LONG_ASCII
    RTS
CREGISTER001  
    MOVE.B      #'1',(A5)+
    RTS
    
REGISTER010
    MOVE.B      #'2',(A5)+
    RTS
REGISTER011
    MOVE.B      #'3',(A5)+
    RTS
REGISTER100
    MOVE.W      D5, D6                     
    ROL.W       #8, D6
    ROL.W       #5, D6

    ANDI.W      #$0007, D6
    CMP.B       #$7,D6
    BEQ         SIZE100
    BRA         CREGISTER100
SIZE100
    CMP.B       #$1,D3
    BEQ         ReadNextW_100
    CMP.B       #0,D3
    BEQ         ReadNextL_100
ReadNextW_100
    MOVE.B      #'#',(A5)+
    MOVE.B      #'$',(A5)+
    MOVE.B      #0,D6
    MOVE.W      (A6)+,D5
    MOVE.B      #4,D3
    JSR         WORD_ASCII
    RTS
ReadNextL_100
    MOVE.B      #'#',(A5)+
    MOVE.B      #'$',(A5)+    
    MOVE.B      #0,D6
    MOVE.L      (A6)+,D5
    MOVE.B      #8,D3
    JSR         LONG_ASCII
    RTS
CREGISTER100    
    MOVE.B      #'4',(A5)+
    RTS
REGISTER101
    MOVE.B      #'5',(A5)+
    RTS
REGISTER110
    MOVE.B      #'6',(A5)+
    RTS
REGISTER111
    MOVE.B      #'7',(A5)+
    RTS
*---------------------------------------------------------------
******************* USER_RESPONSE **********************************************************************
* Expect:       DO, D1, A1 to be empty
* Prompt User for Enter, R, or Q -----------------------------------------
USER_RESPONSE
        LEA         PROMPTOPTIONS, A1            * Load the prompt message
        MOVE.B      #14,D0
        TRAP        #15 
        MOVE.B      #$00, LINE_COUNTER            * Reset Line Count 
        MOVE.B      #5, D0                      * Log keyboard input
        TRAP        #15                 
        CMP.B       #$D, D1                     * Compare the key press with ENTER
        BEQ         CLEAR_SCREEN                  
        CMP.B       #$72, D1                    * Compare the key press with R
        BEQ         RESTART             
        CMP.B       #$52, D1                    * Compare the key press with r
        BEQ         RESTART             
        CMP.B       #$71, D1                    * Compare the key press with q
        BEQ         END_PROGRAM             
        CMP.B       #$51, D1                    * Compare the key press with Q
        BEQ         END_PROGRAM            
        CMP.B       #$5D, D1                    * Check the key press with ENTER
        BNE         USER_RESPONSE              
CLEAR_SCREEN
        MOVE.B  #11, D0                         * Task 11 - Clear screen
        MOVE.W  #$FF00, D1          
        TRAP    #15                 
        CLR.L   D1
        CLR.L   D0
        RTS                 
*------------------ RESTART ----------------------------------------------------------------
RESTART
        JSR         CLEAR_SCREEN
        JSR         CLEAR_REGISTERS
        MOVEA.L     #$01000000,A7       Reset stack pointer
        MOVEA.L     #$01000000,A6       Reset stack pointer
        BRA         START
        
********************************************************************************************
END_PROGRAM_MSG
        LEA         RESTART_PROGRAM_MSG, A1            * Load the prompt message
        MOVE.B      #14,D0
        TRAP        #15 
        MOVE.B      #$00, LINE_COUNTER            * Reset Line Count 
        MOVE.B      #5, D0                      * Log keyboard input
        TRAP        #15                            
        CMP.B       #$59, D1                    * Compare the key press with Y
        BEQ         RESTART             
        CMP.B       #$79, D1                    * Compare the key press with y
        BEQ         RESTART             
        CMP.B       #$4E, D1                    * Compare the key press with N
        BEQ         END_PROGRAM             
        CMP.B       #$6E, D1                    * Compare the key press with n
        BEQ         END_PROGRAM
        BRA         END_PROGRAM_MSG
        
END_PROGRAM
        JSR         CLEAR_SCREEN        
        SIMHALT             ; halt simulator      
*---------------------------------------------------------------------
*Variable
*---------------------------------------------------------------------
Addr1               DS.L    1
Addr2               DS.L    1
LINE_COUNTER        DS.L    1
PRINTER             DC.L    1  * Printer pointer
WORD_LONG_SWITCH    DS.L    1   * 0 for word, 1 for long
BAD_DATA_SWITCH     DS.L    1 
PROMPTOPTIONS       DC.B    'Press: ENTER to Continue || Q or q to Quit || R OR r to Restart',CR,LF,CR,LF,0
RESTART_PROGRAM_MSG DC.B    'Press: Y/y to restart || N/n to end program',CR,LF,CR,LF,0

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

MessageSt               DC.B         'Enter the starting address: ',0    

MessageEn               DC.B         'Enter the Ending address: ',0 

ERRM         DC.B     'Enter Valid hexadecimal value: ',0
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
