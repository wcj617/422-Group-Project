*-----------------------------------------------------------
* Title      :Group Project    
* Written by :David Woo, Stephen Swetonic, Josh Kweon, Laurence Monson
* Date       :12/4/2021 
* Description:Program that accepts a starting and ending address from the user,
*             Scans through instructions stored at those addresses, and prints
*             the dissasembled code line by line. After 25 lines have been printed,
*             allows the user to continue, restart, or end the program
*-----------------------------------------------------------
*   Main program
*--------------------------------------------------------------------

    ORG    $1000    
START:  
        LEA         MESSAGE_GREETING, A1                * Load the greeting and notes for address
        MOVE.B      #14,D0
        TRAP        #15 
   		MOVE.B      #0, LINE_COUNTERS            * SET Default values for a line counter and a bad data switch
        MOVE.B      #0, BAD_DATA_     

********************************************************************************************
* DESCRIPTION: Reading Addresses
* STARTING ADDRESS -------------------------------------------------------
READ_START_ADDRS
        CLR.L       D7
        LEA         MSG_STRT_ADDR, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         INPUT_HEX,A1            * Temp hold starting address
        MOVE.B      #2,D0                   * Read string from keyboard and store at A1
        TRAP        #15
        BRA         VALIDATE_ADDR 
* ENDING ADDRESS -------------------------------------------------------
READ_END_ADDRS
        LEA         MSG_END_ADDR, A1
        MOVE.B      #14, D0
        TRAP        #15
        LEA         INPUT_HEX,A1            * Temp hold ending address
        MOVE.B      #2,D0                   * Read string from keyboard and store at A1
        TRAP        #15  
        BRA         VALIDATE_ADDR 

********************************************************************************************
* Validating and storing addresses
* VALIDATE & STORE  ADDRESS ----------------------------------------------
VALIDATE_ADDR 
        CMPI.B      #4, D1                  
        BLT         BADSIZES_ADDR
        CMPI.B      #8, D1 
        BGT         BADSIZES_ADDR
        BRA         READ_HEXD
BADSIZES_ADDR
        LEA         ERROR_ADDRSIZE, A1      * Print Bad Size Error
        MOVE.B      #14,D0
        TRAP        #15
        CMP.B       #0,D3                   * D3 - HOLDS 0 if starting address has not being stored yet
        BEQ         READ_START_ADDRS
        BRA         READ_END_ADDRS 
INVALID_CHAR_ADDR                           * Print Invalid Character for Address
        LEA         ERROR_INVALIDCHAR, A1
        MOVE.B      #14,D0 
        TRAP        #15 
        CMP.B       #0,D3
        BEQ         READ_START_ADDRS 
        BRA         READ_END_ADDRS
* Read ASCII & Convert + Store as Hex ----------------------------------
READ_HEXD       
        CMPI.B      #$30,(A1)
        BLT         INVALID_CHAR_ADDR       * Wrong data
        CMPI.B      #$40,(A1)
        BLT         NUMBERS                        * Is number
        CMPI.B      #$47,(A1)
        BLT         LETTERS                 * Is Letter
        BRA         INVALID_CHAR_ADDR
NUMBERS      
        SUBI.B      #$30,(A1)               * Convert Numbers to Hex
        BRA         STORE_AS_HEX
LETTERS     
        SUBI.B      #$37,(A1)               * Convert Numbers to Hex
        BRA         STORE_AS_HEX
STORE_AS_HEX       
        ADD.B       (A1)+,D7                * Save data from A1 to D7
        CMPI.B      #0,(A1)                 * NO MORE TO READ SO CHECK IF ADDRESS IS ODD
        BEQ        IS_ODD_ADDR     
        LSL.L       #4,D7                   * Keep reading next character
        BRA         READ_HEXD

* Before storing address - check if odd --------------------------------------------------------
IS_ODD_ADDR                                    * Check if address is odd
        MOVE.L      #$00000002,D1  	        * Put 2 in D1 so we can use it to divide input by 2
        MOVE.L      D7,D6
        DIVU        D1,D6          	        * Divide the input address by 2
        SWAP        D6             	        * Store the remainder in D2
        CMP.B       #1,D6          	        * Is the remainder ==1
        BEQ         ADDR_IS_ODD     	        * Remainder is 1 so input fails odd test 
        CMP.B       #0,D3
            
        BRA         STORE_ADDR2MEM                           
ADDR_IS_ODD   
        LEA         ERROR_ODDADDR,A1  	    * Load ODD_ADD_MSG to A1
        MOVE.B      #14,D0          	    * Print odd address error message
        TRAP        #15                     
        CLR.L       D6
        CLR.L       D7      
        CMP.B       #0,D3
        BEQ        READ_START_ADDRS
        BRA         READ_END_ADDRS 

* STORE ADDRESSESSS INTO MEMORY ----------------------------------------------------------------              
STORE_ADDR2MEM
        CLR.L       D6
        CMP.B       #0,D3
        BNE         STORE_ENDADDR 
        
        CMP.L       #$00007000, D7
        BGT         CNTINUE_STORE_ADDR
        BEQ         CNTINUE_STORE_ADDR
    
        CLR.L       D6
        CLR.L       D7
        LEA         ERROR_SADDR_POINT, A1  	   
        MOVE.B      #14,D0                	    
        TRAP        #15  
        BRA        READ_START_ADDRS
        
CNTINUE_STORE_ADDR        
        MOVE.L      D7, START_ADDR            * Save in the memory address 
        MOVEA.L     D7, A6                      * Save starting at A6
        MOVE.B      #1, D3                      * Counter - for VALID STORE ADDRESS
        CLR.L       D7
        BRA         READ_END_ADDRS   
STORE_ENDADDR
        CMP.L       (START_ADDR), D7
        BLT         STRT_GT_END

STORE_E2MEM             
        MOVE.L      D7, END_ADDR
        CLR.L       D7
        JSR         SCREEN_CLEAR
        BRA         START_ADDRLOOP
STRT_GT_END                                            * Starting greater then ending
        LEA         ERROR_STRT_ADDR, A1
        MOVE.B      #14, D0
        TRAP        #15
        CLR.L       D7
        CLR.L       D3
        BRA        READ_START_ADDRS
  
        
********************************************************************************************
* OPCODE READ ------------------------------------------------------------

* Compare Current Address to Ending Adddres ------------------------------ 
START_ADDRLOOP
        JSR         RGSTR_CLEAR             * Clear registers
        MOVE.L      END_ADDR,A5               * Check current address against ending adress           
        CMP.L       A5,A6
        BGT         PROGRAM_END_PROMPT    

        MOVE.L      #$00000000, A5
        CMP.B       #25, LINE_COUNTERS           * Check line counter
        BNE         CNT_ADDRLOOP
        JSR         USER_RSPNS         
CNT_ADDRLOOP        
        ADD.B       #1, LINE_COUNTERS            * Update Line counter
        JSR         RGSTR_CLEAR             * Clear registers
        JSR        PRINT_CUR_ADDRS           * PRINT CURRENT ADDRESS
        
        LEA         PROGRAM_PRINTER, A5                  
        MOVE.W      (A6)+, D7
        JSR         BUILD_PRINTER                * FILL Printer
        
        CMP.B       #10, BAD_DATA_        * Check if Bad Data Switch is True
        BEQ         PRINT_BAD_DATA  
        MOVE.B      #$00,(A5)+                  * Add 00 to opcode printer to every printer
        LEA         PROGRAM_PRINTER, A1		            * Load Printer
        MOVEQ       #13,D0				
        TRAP        #15					

        BRA         START_ADDRLOOP
        
PRINT_BAD_DATA                                   
        JSR         RGSTR_CLEAR             * Clear registers
        LEA         PROGRAM_PRINTER, A5
        JSR		    SET_BAD_DATA		        
        MOVE.B      #$00,(A5)+                  * Add 00 to opcode printer to every printer
        LEA         PROGRAM_PRINTER,A1		            * Load printer
        MOVEQ       #13,D0				        
        TRAP        #15		
        MOVE.B      #$00, BAD_DATA_       * Reset SWITCH  
        BRA         START_ADDRLOOP		            * Continue reading opcodes
        
* BAD DATA PRINTER -----------------------------------------------------
SET_BAD_DATA
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

        BRA         WORD2ASCII                  * ALWAYS branch to Word to ASCII convertion
        
* NOTE: D5 is use to load whatever you want to convert to ASCII
*     : D6, d3 are the variable for the counter
* WORD TO ASCII
WORD2ASCII                      	
    	ROL.W       #4,D5                       * ROL 4 Bits to get load it to d4       	       
    	MOVE.L      D5,D4               	        
    	ANDI.L      #$0000000F,D4               * Mask evertying except the 4 bits at the left     	        
    	CMPI.B      #$09,D4             	    * Check is number or letter        
    	BLE         CHECK_NUM                         
    	ADDI.B      #$37,D4                        
    	BRA        CHECK_LETTER
CHECK_NUM                                          * ADD 30 to D4 if num         
        ADDI.B      #$30,D4           	        
    	BRA         CHECK_LETTER
CHECK_LETTER
    	ADDI.B      #1,D6               	    * ADD 30 to D4 if letter   
    	MOVE.B      D4,(A5)+            	       
    	CMP.B       D3,D6               	
    	BLT         WORD2ASCII                 
    	RTS
    	
* LONG TO ASCII    	
LONG2ASCII                      	
    	ROL.L       #4,D5               	        
    	MOVE.L      D5,D4               	        
    	ANDI.L      #$0000000F,D4       	        
    	CMPI.B      #$09,D4             	          
    	BLE         CHECK_NUM_LONG 
    	ADDI.B      #$37,D4
    	BRA         CHECK_LTTR_LONG
CHECK_NUM_LONG 
    	ADDI.B      #$30,D4
    	BRA         CHECK_LTTR_LONG
CHECK_LTTR_LONG
    	ADDI.B      #1,D6
    	MOVE.B      D4,(A5)+ 
    	CMP.B       D3,D6               	
    	BLT         LONG2ASCII
    	RTS    	
    	
    	
* GO TO OPCODE AND FILL PRINTER -------------------------------------
BUILD_PRINTER
        MOVE.W      D7, D6                          
        ROL.W       #4, D6				            
        MOVE.W      D6, D5
        LEA         OPCODE_JMPTABLES, A0      	    
        ANDI.W      #$000F, D6
        MULU        #8, D6             	            
        JSR         0(A0,D6)          	            
        RTS        

********************************************************************************************
* JMP TABLES                                             
OPCODE_JMPTABLES
    JSR     OPCODE0000                           * - BAD DATA  
    RTS
    JSR     OPCODE0001                           * - MOVE.B 
    RTS
    JSR     OPCODE0010                           * - MOVE.L,MOVEA.L 
    RTS
    JSR     OPCODE0011                           * - MOVE.W,MOVEA.W 
    RTS
    JSR     OPCODE0100                           * - LEA, JSR, RTS, NOP, NOT    
    RTS
    JSR     OPCODE0101                           * - ADDQ ----------------------------------   
    RTS   
    JSR     OPCODE0110                           * - BCC, BLE, BGT
    RTS
    JSR     OPCODE0111                           * - MOVEQ
    RTS
    JSR     OPCODE1000                           * - OR   
    RTS 
    JSR     OPCODE1001                           * - SUB
    RTS
    JSR     OPCODE1010                           * - BAD DATA ----------------------------------
    RTS  
    JSR     OPCODE1011                           * - BAD DATA ----------------------------------
    RTS
    JSR     OPCODE1100                           * - AND
    RTS
    JSR     OPCODE1101                           * - ADDA, ADD
    RTS
    JSR     OPCODE1110                           * - ASL, ASR, LSL, LSR, ROL, ROR 
    RTS  
    JSR     OPCODE1111                           * - BAD DATA -------------------------------------
    RTS   

*********************************************************
* 0100 Jump Table - USE FOR CLR, JSR, LEA, RTS - NOT MOVEM
THREE_TABLE     
    JSR     THREE000            - LEA                  
    RTS                                 
    JSR     THREE001            - LEA       
    RTS                                 
    JSR     THREE010            - LEA
    RTS                                 
    JSR     THREE011            - LEA        
    RTS                                 
    JSR     THREE100            - LEA       
    RTS                                 
    JSR     THREE101            - LEA
    RTS                                 
    JSR     THREE110            - LEA        
    RTS                                 
    JSR     THREE111            - LEA, JSR, NOP, RTS       
    RTS    
* 0100 Jump Table - USE FOR JSR, LEA, RTS 
THREE_TABLE_2     
    JSR     THREE2000           - Bad Data                
    RTS                                 
    JSR     THREE2001           - Bad Data        
    RTS                                
    JSR     THREE2010           - Bad Data 
    RTS                                 
    JSR     THREE2011           - JSR        
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
* INVALID OPCODES
********************************************************
OPCODE1010  
    ADD.B       #10, BAD_DATA_              
    RTS                         
OPCODE1011
    ADD.B       #10, BAD_DATA_              
    RTS  
OPCODE1111 
    ADD.B       #10, BAD_DATA_            
    RTS                              
OPCODE0000
    ADD.B       #10, BAD_DATA_          
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
 
OPCODE0001_DECODE_MOVE   *** Do Source ***
    MOVE.W          D7, D4
    ANDI.W          #$0038, D4
    CMP.W           #$0000, D4
    BEQ             Dn_OP0001
    CMP.W           #$0008, D4
    BEQ             An_OP0001 
    CMP.W           #$0010, D4
    BEQ             ABS_An_OP0001
    CMP.W           #$0018, D4
    BEQ             ICRM_An_OP0001
    CMP.W           #$0020, D4
    BEQ             DCRM_An_OP0001
    CMP.W           #$0038, D4
    BEQ            EA_OP0001 
    ADD.B           #10, BAD_DATA_  
    RTS
   
CNT_OPCODE0001
    MOVE.B          #',',(A5)+
    MOVE.W          D7, D4
    MOVE.W          D7, D5
    ROL.W           #3,D5
    ANDI.W          #$01C0, D4
    CMP.W           #$0000, D4
    BEQ             DSTN_Dn_OP0001 
    CMP.W           #$0040, D4
    BEQ             DSTN_An_OP0001
    CMP.W           #$0080, D4
    BEQ             DSTN_ABS_An_OP0001
    CMP.W           #$00C0, D4
    BEQ             DSTN_INCM_An_OP0001
    CMP.W           #$0100, D4
    BEQ             DSTN_DCREM_An_OP0001 
    CMP.W           #$01C0, D4
    BEQ             DSTN_EA_OP0001 
    ADD.B           #10, BAD_DATA_  
    RTS
   
Dn_OP0001   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)     
    BRA            CNT_OPCODE0001
An_OP0001  
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)     
    BRA            CNT_OPCODE0001
ABS_An_OP0001
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    BRA             CNT_OPCODE0001
ICRM_An_OP0001
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    MOVE.B          #'+',(A5)+
    BRA             CNT_OPCODE0001
DCRM_An_OP0001
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    BRA             CNT_OPCODE0001
EA_OP0001 
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    CMP.W           #$0000, D4
    BEQ             EA_000_OP0001
    CMP.W           #$0001, D4
    BEQ             EA_001_OP0001
    CMP.W           #$0004, D4
    BEQ             EA_100_OP0001
    ADD.B           #10, BAD_DATA_  
    BRA            CNT_OPCODE0001
 
        *** Destination ***
DSTN_Dn_OP0001   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)     
    RTS
DSTN_An_OP0001
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)
    RTS
DSTN_ABS_An_OP0001
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)
    MOVE.B          #')',(A5)+
    RTS
DSTN_INCM_An_OP0001
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    MOVE.B          #'+',(A5)+
    RTS
DSTN_DCREM_An_OP0001 
    MOVE.B          #'-',(A5)+
    MOVE.B          #'(',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    ROL.W           #7,D4
    ANDI.W          #$0007, D4
    MOVE.W          D4, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    RTS
DSTN_EA_OP0001 
    MOVE.W          D7, D4
    ROL.w           #7,D4
    ANDI.W          #$0007, D4
    CMP.W           #$0000, D4
    BEQ             DSTN_EA_000_OP0001
    CMP.W           #$0001, D4
    BEQ             DSTN_EA_001_OP0001
    ADD.B           #10, BAD_DATA_  
    RTS
   
EA_000_OP0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                          
    MOVE.W      (A6)+,D5                         
    MOVE.B      #4,D3 
    JSR         WORD2ASCII
    BRA         CNT_OPCODE0001
EA_001_OP0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                         
    MOVE.L      (A6)+,D5                         
    MOVE.B      #8,D3
    JSR         LONG2ASCII    
    BRA         CNT_OPCODE0001
EA_100_OP0001
    MOVE.W      D7, D4
    ANDI.W      #$F000,D4
    MOVE.B      #'#',(A5)+
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6
    CMP.W       #$2000,D4
    BEQ         EA_100_CASE_0001_LONG
    MOVE.W      (A6)+,D5 
    MOVE.B      #4,D3 
    JSR         WORD2ASCII
    BRA        CNT_OPCODE0001
EA_100_CASE_0001_LONG
    MOVE.L      (A6)+,D5 
    MOVE.B      #8,D3 
    JSR         LONG2ASCII
    BRA        CNT_OPCODE0001  
    
    
DSTN_EA_000_OP0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                          
    MOVE.W      (A6)+,D5                         
    MOVE.B      #4,D3 
    JSR         WORD2ASCII
    RTS
DSTN_EA_001_OP0001
    MOVE.B      #'$',(A5)+
    MOVE.B          #0,D6                         
    MOVE.L      (A6)+,D5                         
    MOVE.B      #8,D3
    JSR         LONG2ASCII    
    RTS

******************* MOVE.L *****************************************************************************
OPCODE0010

    MOVE.W           D7,D4        
    ANDI.W           #$01C0,D4
    *OPMODE FOR MOVEA  
     CMP.W            #$0040,D4
    BEQ              GET_MOVE_A_L     
    BRA              GET_MOVEL      

GET_MOVEL     
               MOVE.B          #'M',(A5)+   
               MOVE.B          #'O',(A5)+
               MOVE.B          #'V',(A5)+
               MOVE.B          #'E',(A5)+
               MOVE.B          #'.',(A5)+
               MOVE.B          #'L',(A5)+ 
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+
               BRA             OPCODE0001_DECODE_MOVE

GET_MOVE_A_L     
               MOVE.B          #'M',(A5)+  
               MOVE.B          #'O',(A5)+
               MOVE.B          #'V',(A5)+
               MOVE.B          #'E',(A5)+
               MOVE.B          #'A',(A5)+
               MOVE.B          #'.',(A5)+
               MOVE.B          #'L',(A5)+ 
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+
               BRA             OPCODE0001_DECODE_MOVE
    
******************* MOVE.W ****************************************************************************
OPCODE0011
              MOVE.W           D7,D4        
              ANDI.W           #$01C0,D4
              *OPMODE FOR MOVEA  
              CMP.W            #$0040,D4
              BEQ              GET_MOVE_A_W
              BRA              GET_MOVEW       

GET_MOVEW    
               MOVE.B                 #'M',(A5)+   
               MOVE.B          #'O',(A5)+
               MOVE.B          #'V',(A5)+
               MOVE.B          #'E',(A5)+
               MOVE.B          #'.',(A5)+
               MOVE.B          #'W',(A5)+ 
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+
               BRA             OPCODE0001_DECODE_MOVE

GET_MOVE_A_W 
               MOVE.B          #'M',(A5)+  
               MOVE.B          #'O',(A5)+
               MOVE.B          #'V',(A5)+
               MOVE.B          #'E',(A5)+
               MOVE.B          #'A',(A5)+
               MOVE.B          #'.',(A5)+
               MOVE.B          #'W',(A5)+ 
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+     
               MOVE.B          #' ',(A5)+
               BRA             OPCODE0001_DECODE_MOVE

******************* JSR RTS NOP LEA CLR MOVEM****************************************************************************       
OPCODE0100

    * CHECK IF JSR RTS NOP LEA CLR 
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE, A0
    JSR             00(A0,D6)   
    RTS
******************* ADDQ ****************************************************************************
OPCODE0101    
    MOVE.W          D7, D4
    ANDI.W          #$0100, D4
    CMP.W           #$0000, D4
    BEQ             CNT_OPCODE0101
    ADD.B           #10, BAD_DATA_             
    RTS
CNT_OPCODE0101      
    MOVE.B          #'A',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.B          #'Q',(A5)+
    MOVE.B          #'.',(A5)+      
    MOVE.W          D7, D4
    ANDI.W          #$00C0, D4
    CMP.W           #$0000, D4
    BEQ             ADDQ_B_0101
    CMP.W           #$0040, D4
    BEQ             ADDQ_W_0101
    CMP.W           #$0080, D4
    BEQ             ADDQ_L_0101
    ADD.B           #10, BAD_DATA_             
    RTS
ADDQ_B_0101
    MOVE.B          #'B',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #'#',(A5)+
    MOVE.B          #'$',(A5)+
    MOVE.W          (A6)+, D5
    MOVE.B          #0 , D6
    MOVE.B          #4, D3
    JSR             WORD_0101
    *MOVE.W          D4, (A5)+
    BRA             CNT_NEXT_OPCODE0101
ADDQ_W_0101
    MOVE.B          #'W',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #'#',(A5)+
    MOVE.B          #'$',(A5)+
    MOVE.W          (A6)+, D5
    MOVE.B          #0 , D6
    MOVE.B          #4, D3
    JSR             WORD_0101
    *MOVE.W          D4, (A5)+ 
    BRA             CNT_NEXT_OPCODE0101
ADDQ_L_0101
    MOVE.B          #'L',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #'#',(A5)+
    MOVE.B          #'$',(A5)+
    *MOVE.L          (A6)+, D5
    MOVE.L          (A6)+, D5
    MOVE.B          #0 , D6
    MOVE.B          #4, D3
    JSR             WORD_0101
    *MOVE.W          D4, (A5)+ 
    BRA             CNT_NEXT_OPCODE0101
CNT_NEXT_OPCODE0101
    MOVE.B          #',',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0038, D4
    CMP.W           #$0000, D4
    BEQ             Dn_OP0101
    CMP.W           #$0010, D4
    BEQ             ABS_An_OP0101
    CMP.W           #$0018, D4
    BEQ             ICMT_An_OP0101
    CMP.W           #$0020, D4
    BEQ             DCMT_An_OP0101
    CMP.W           #$0038, D4
    BEQ             EA_OP0101
    ADD.B           #10, BAD_DATA_   
    RTS
Dn_OP0101    
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    LSL.W           #3, D4
    MOVE.W          D4, D5
    MOVE.W          D4, D6
    LSR.W           #3, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)      
    RTS
ABS_An_OP0101
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    RTS
ICMT_An_OP0101
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    MOVE.B          #'+',(A5)+
    RTS
DCMT_An_OP0101  
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    MOVE.B          #')',(A5)+
    RTS
EA_OP0101  
    MOVE.W          D7, D4
    ANDI.W          #$0007, D4
    CMP.W           #$0000, D4
    BEQ             EA_0000_OP0101
    CMP.W           #$0001, D4
    BEQ             EA_0010_OP0101
    ADD.B           #10, BAD_DATA_   
    RTS 
EA_0000_OP0101
    MOVE.B      #'$',(A5)+
    MOVE.B	    #0,D6                           
    MOVE.W      (A6)+,D5                          
    MOVE.B      #4,D3  
    JSR         WORD2ASCII
    RTS 
EA_0010_OP0101
    MOVE.B      #'$',(A5)+
    MOVE.B	    #0,D6                          
    MOVE.L      (A6)+,D5                          
    MOVE.B      #8,D3
    JSR         LONG2ASCII 
    RTS  
WORD_0101                      	
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    CMP.W           #$0000, D4
    BEQ             DATA_8 *8
    CMP.W           #$0200, D4
    BEQ             DATA_1 * 1
    CMP.W           #$0400, D4
    BEQ             DATA_2  * 2
    CMP.W           #$0600, D4
    BEQ             DATA_3  *3
    CMP.W           #$0800, D4
    BEQ             DATA_4 *4
    CMP.W           #$0A00, D4
    BEQ             DATA_5  *5
    CMP.W           #$0C00, D4
    BEQ             DATA_6 *6
    CMP.W           #$0E00, D4
    BEQ             DATA_7 *7
    ADD.B           #10, BAD_DATA_ 
    RTS
       
DATA_8
    MOVE.B          #'8',(A5)+
    RTS 
DATA_1
    MOVE.B          #'1',(A5)+
    RTS
DATA_2
    MOVE.B          #'2',(A5)+
    RTS
DATA_3
    MOVE.B          #'3',(A5)+
    RTS
DATA_4
    MOVE.B          #'4',(A5)+
    RTS
DATA_5
    MOVE.B          #'5',(A5)+
    RTS
DATA_6
    MOVE.B          #'6',(A5)+
    RTS
DATA_7
    MOVE.B          #'7',(A5)+
    RTS



******************* BCC, BLE, BGT ****************************************************************************
OPCODE0110                                               
    MOVE.W          D5, D6                      *D5:XXX6 -> D6:XXX6      
    ROL.W           #4, D6                      *D6:XX6X 
    MOVE.W          D6, D5                      *D6:XX6X -> D5:XX6X
    ANDI.W          #$000F, D6                  *D6:000X
    CMP.W           #$F,D6                      *D6:000F
    BEQ            OPCODE0110_GET_BLE              *Go to BLE OPcode
    CMP.W           #$E,D6                      *D6:000E
    BEQ             OPCODE0110_GET_BGT               *Go to BGT OPcode
    CMP.W           #$4,D6                      *D6:0004
    BEQ             OPCODE0110_GET_BCC              *Go to BCC Opcode
    ADD.B           #10, BAD_DATA_        *If none of those, then it is something we haven't decoded      
    RTS  
OPCODE0110_GET_BLE
    MOVE.B	        #'B',(A5)+			        
    MOVE.B	        #'L',(A5)+			
    MOVE.B	        #'E',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+   
    BRA             OP0110_DISPMNT         *To check how far away the to branch to
OPCODE0110_GET_BGT    
    MOVE.B	        #'B',(A5)+			
    MOVE.B	        #'G',(A5)+			
    MOVE.B	        #'T',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+
    BRA             OP0110_DISPMNT
OPCODE0110_GET_BCC
    MOVE.B	        #'B',(A5)+			
    MOVE.B	        #'C',(A5)+			
    MOVE.B	        #'C',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+			
    MOVE.B	        #' ',(A5)+
OP0110_DISPMNT
    MOVE.W          D7,D6                           *D7:6XXX  -> D6:6XXX
    MOVE.L          A6,D5                           *Save current address to D5
    MOVE.B          #0,D0                           *Set counter
    MOVE.B          #8,D1                           *Max Counter 
    ANDI.W          #$00FF, D6                      *D6:00XX
    CMP.W           #$00,D6                         *XX:00, then check the next 2 bytes from current address
    BEQ             OP0110_DISPMNT_W    
    CMP.W           #$FF,D6                         *XX:FF, then check the next 4 bytes from current address
    BEQ             OP0110_DISPMNT_L  
    BRA             OP011_TSCMPLMNT_B   *XX:00<XX<FF, then must do twos complement because we have to subtract
OP0110_DISPMNT_W
    MOVE.W          (A6)+,D6                        *Save the next word size from current address
    MOVE.B          #16,D1                          *Set counter for word-bit size
    MOVE.W          D6,D4                           *Copy D6 to D4
    ANDI.W          #$8000,D4   
    CMP.W           #$8000,D4                       *Checking to see if I need to go backwards
    BEQ             OP011_TSCMPLMNT_W   
    ADD.W           D6,D5                           *Else, add the value with current address
    BRA             PRINT_W_OPCODE0110                *print word

OP0110_DISPMNT_L                        *same as OPCODE0110_DISPLACEMENT_WORD but for Long
    MOVE.L          (A6)+,D6                        
    MOVE.B          #32,D1
    MOVE.L          D6,D4
    ANDI.L          #$80000000,D4
    CMP.L           #$80000000,D4
    BEQ             OP011_TSCMPLMNT_W
    ADD.L           D6,D5
    BRA             PRINT_W_OPCODE0110
* OPCODE011_TWOSCOMPLEMENT-----------------------------------------
OP011_TSCMPLMNT_B
    ROL.B       #1,D6                               *Check bit by bit for byte size        
    BCS         OP011_TSCMPLMNT_ONE
    BRA         OP011_TSCMPLMNT_Z
OP011_TSCMPLMNT_W
    ROL.W       #1,D6                               *Check bit by bit for word size
    BCS         OP011_TSCMPLMNT_ONE
    BRA         OP011_TSCMPLMNT_Z    
OP011_TSCMPLMNT_L
    ROL.L       #1,D6                               *Check bit by bit for long size
    BCS         OP011_TSCMPLMNT_ONE
OP011_TSCMPLMNT_Z
    ADDI.B      #1,D6                               *Add one if its zero
    BRA         OP011_TSCMPLMNT_LOOP
OP011_TSCMPLMNT_ONE    
    SUBI.B      #1,D6                               *Sub one if its one
OP011_TSCMPLMNT_LOOP
    ADDI.B      #1,D0                               *increase the counter
    CMP.B       D0,D1                               *check if it is done
    BEQ         OP011_TSCMPLMNT_ADDONE    
    CMP.B       #8,D1                               *check the counter size to jump to byte,word, or long
    BEQ         OP011_TSCMPLMNT_B
    CMP.B       #16,D1
    BEQ         OP011_TSCMPLMNT_W
    CMP.B       #32,D1
    BEQ         OP011_TSCMPLMNT_L
OP011_TSCMPLMNT_ADDONE
    ADDI.W      #$1,D6                              *complete twos complement by adding $1 to the value             
    SUB.L       D6,D5                               *Sub the current address with the new value to get the address to branch
* OPCODE011_TWOSCOMPLEMENT-----------------------------------------
PRINT_W_OPCODE0110
    CMP.L           #$FFFF,D5                       *check to see if the address exceeds word size
    BGT             PRINT_L_OPCODE0110           *if it does, print long
    MOVE.B          #4,D3                           *setting the max time for loop
    CLR.L           D6                              *clear it because WORD_ASCII uses D6 
    JSR             WORD2ASCII
    RTS
PRINT_L_OPCODE0110
    MOVE.B          #8,D3                           *setting the max 
    CLR.L           D6
    JSR             LONG2ASCII
    RTS 
**************** MOVEQ *********************************************************************************************************
OPCODE0111
    MOVE.W      D7, D4
    ANDI.W      #$0100, D4
    CMP.W       #$0000, D4
    BEQ          GET_MOVEQ                          * Check bad casses for BAD DATA for MOVEQ
    ADD.B       #10, BAD_DATA_  
    RTS   
GET_MOVEQ
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
    JSR             LONG2ASCII
 
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
    LEA             RGSTRS, A0
    JSR             00(A0,D6)
    RTS
********************OR******************************************************************************************    
OPCODE1000
    MOVE.W      D5,D4                   *D5:XXXC
    MOVE.W      D4,D5
    ROL.W       #3,D4
    ANDI.W      #$7,D4                      *Saving register into D4
    LSL.W       #4,D5                       *D5[opmode][EAmode][EAregister][register]
    BCC         OPCODE1000_EA_SOURCE
    
    JSR     OP1000_GET_SIZE                *EA_DESTINATION
    JSR     OP1000_EA_MODE
    JSR     OP1000_EA_RGSTR
    
    CMP.B   #$0,D6
    BEQ     OP1000_INVL_EA_SRC
    CMP.B   #$1,D6
    BEQ     OP1000_INVL_EA_SRC
    CMP.B   #$7,D6
    BNE     OPCODE1000_EA_DEST_VALID
    CMP.B   #%100,D5
    BEQ     OP1000_INVL_EA_SRC
        
OPCODE1000_EA_DEST_VALID
    JSR     OPCODE1000_AND
    ROR.W   #3,D4
    MOVE.W  D4,D5
    JSR     SRT_EA_000
    
    MOVE.B      #',',(A5)+
    MOVE.W      D7,D6
    ROR.W       #3,D6
    LEA         SRT_EAMODE,A0
    MOVE.W      D6,D5
    ANDI.W      #$7,D6
    MULU        #6,D6
    JSR         00(A0,D6)
    RTS
    
OPCODE1000_EA_SOURCE
    JSR     OP1000_AND_B
    JSR     OP1000_INVL_EA_SRC
    JSR     OP1000_INVL_EA_SRC
    CMP.B   #$1,D6
    BEQ     OP1000_INVL_EA_SRC
    JSR     OPCODE1000_AND
    MOVE.W      D7,D6
    ROR.W       #3,D6
    LEA         SRT_EAMODE,A0
    MOVE.W      D6,D5
    ANDI.W      #$7,D6
    MOVE.B      #$1,D3
    MULU        #6,D6
    JSR         00(A0,D6)
    
    MOVE.B      #',',(A5)+
    ROR.W       #3,D4
    MOVE.W      D4,D5
    JSR         SRT_EA_000
    RTS
* PRINT_SIZE----------------------     
OPCODE1000_AND
    MOVE.B      #'O',(A5)+
    MOVE.B      #'R',(A5)+

    MOVE.B      #'.',(A5)+
    JSR         OPCODE1000_PRINTSIZE
    RTS
OPCODE1000_PRINTSIZE
    CMP.B       #0,D3
    BEQ         OP1000_PRINTSIZE_B 
    CMP.B       #1,D3
    BEQ         OP1000_PRINTSIZE_W
    CMP.B       #2,D3
    BEQ         OP1000_PRINTSIZE_L

OP1000_PRINTSIZE_B    
    MOVE.B      #'B',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    RTS         
OP1000_PRINTSIZE_W
    MOVE.B      #'W',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    RTS
OP1000_PRINTSIZE_L
    MOVE.B      #'L',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    RTS
* MODE_REGISTER----------------------    
OP1000_EA_RGSTR
    MOVE.W  D7,D5
    ANDI.W  #$7,D5
    RTS
OP1000_EA_MODE
    MOVE.W  D6,D5
    ROL.W   #5,D6
    ANDI.W  #$7,D6
    RTS
OP1000_INVL_EA_SRC
    ADD.B       #10, BAD_DATA_        
    RTS 
* MODE_REGISTER----------------------
OP1000_GET_SIZE
    MOVE.W      D5,D6
    ROL.W       #2,D5
    ANDI.W      #$3,D5
    CMP.W       #$0,D5
    BEQ         OP1100_AND_B
    CMP.W       #$1,D5
    BEQ         OP1100_AND_W
    CMP.W       #$2,D5
    BEQ         OP1100_AND_L
    ADD.B       #10, BAD_DATA_               
    RTS

OP1000_AND_B
    MOVE.B      #0,D3
    RTS
OP1000_AND_W
    MOVE.B      #1,D3
    RTS
OP1000_AND_L
    MOVE.B      #2,D3
    RTS    

******************* SUB ****************************************************************************
OPCODE1001
    MOVE.W      D7, D4
    ANDI.W      #$01C0, D4 
  
    *OPMODE FOR SUB
    CMP.W       #$0000, D4
    BEQ        EA_Dn_OP1001_B
    CMP.W       #$0100, D4
    BEQ        DN_EA_OP1001_B
   
    CMP.W       #$0040, D4
    BEQ         EA_Dn_OP1001_W
    CMP.W       #$0140, D4
    BEQ         Dn_EA_OP1001_W
   
    CMP.W       #$0080, D4
    BEQ        EA_Dn_OP1001_L
    CMP.W       #$0180, D4
    BEQ         Dn_EA_OP1001_L
 
    ADD.B       #10, BAD_DATA_ 
    RTS   
 
*BYTE CASE   
EA_Dn_OP1001_B
    JSR             GET_SUB
    MOVE.B          #'B',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
 
DN_EA_OP1001_B
    JSR             GET_SUB
    MOVE.B          #'B',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)   
    MOVE.B          #',',(A5)+
 
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
    LEA             SRT_EAMODE, A0
    JSR             00(A0,D6) 
    RTS
 
 
EA_Dn_OP1001_W
    JSR            GET_SUB
    MOVE.B          #'W',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
Dn_EA_OP1001_W
    JSR            GET_SUB
    MOVE.B          #'W',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)   
    MOVE.B          #',',(A5)+
 
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    RTS
EA_Dn_OP1001_L
    JSR             GET_SUB
    MOVE.B          #'L',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
Dn_EA_OP1001_L
    JSR             GET_SUB
    MOVE.B          #'L',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)   
    MOVE.B          #',',(A5)+
 
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    RTS

GET_SUB
    MOVE.B          #'S',(A5)+
    MOVE.B          #'U',(A5)+
    MOVE.B          #'B',(A5)+
    MOVE.B          #'.',(A5)+
    RTS
        


*******************  AND *****************************************************************************************************
OPCODE1100      *AND
    MOVE.W          D5,D4                   *D5:XXXC

  
    MOVE.W      D4,D5
    ROL.W       #3,D4
    ANDI.W      #$7,D4                      *Saving register into D4
    LSL.W       #4,D5                       *D5[opmode][EAmode][EAregister][register]
    BCC         OPCODE1100_EA_SOURCE
    
    JSR     OP1100_GET_SIZE                *EA_DESTINATION
    JSR     OP1100_EA_MODE
    JSR     OP1100_EA_RGSTR
    
    CMP.B   #$0,D6
    BEQ     OP1100_INVL_EA_SRC
    CMP.B   #$1,D6
    BEQ     OP1100_INVL_EA_SRC
    CMP.B   #$7,D6
    BNE     OPCODE1100_EA_DEST_VALID
    CMP.B   #%100,D5
    BEQ     OP1100_INVL_EA_SRC
        
OPCODE1100_EA_DEST_VALID
    JSR     OPCODE1100_AND
    ROR.W   #3,D4
    MOVE.W  D4,D5
    JSR     SRT_EA_000
    
    MOVE.B      #',',(A5)+
    MOVE.W      D7,D6
    ROR.W       #3,D6
    LEA         SRT_EAMODE,A0
    MOVE.W      D6,D5
    ANDI.W      #$7,D6
    MULU        #6,D6
    JSR         00(A0,D6)
    RTS
    
OPCODE1100_EA_SOURCE
    JSR     OP1100_AND_B
    JSR     OP1100_INVL_EA_SRC
    JSR     OP1100_INVL_EA_SRC
    CMP.B   #$1,D6
    BEQ     OP1100_INVL_EA_SRC
    JSR     OPCODE1100_AND
    MOVE.W      D7,D6
    ROR.W       #3,D6
    LEA         SRT_EAMODE,A0
    MOVE.W      D6,D5
    ANDI.W      #$7,D6
    MOVE.B      #$1,D3
    MULU        #6,D6
    JSR         00(A0,D6)
    
    MOVE.B      #',',(A5)+
    ROR.W       #3,D4
    MOVE.W      D4,D5
    JSR         SRT_EA_000
    RTS
* PRINT_SIZE----------------------     
OPCODE1100_AND
    MOVE.B      #'A',(A5)+
    MOVE.B      #'N',(A5)+
    MOVE.B      #'D',(A5)+
    MOVE.B      #'.',(A5)+
    JSR         OPCODE1100_PRINTSIZE
    RTS
OPCODE1100_PRINTSIZE
    CMP.B       #0,D3
    BEQ         OP1100_PRINTSIZE_B 
    CMP.B       #1,D3
    BEQ         OP1100_PRINTSIZE_W
    CMP.B       #2,D3
    BEQ         OP1100_PRINTSIZE_L

OP1100_PRINTSIZE_B    
    MOVE.B      #'B',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    RTS         
OP1100_PRINTSIZE_W
    MOVE.B      #'W',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    RTS
OP1100_PRINTSIZE_L
    MOVE.B      #'L',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    RTS
* MODE_REGISTER----------------------    
OP1100_EA_RGSTR
    MOVE.W  D7,D5
    ANDI.W  #$7,D5
    RTS
OP1100_EA_MODE
    MOVE.W  D6,D5
    ROL.W   #5,D6
    ANDI.W  #$7,D6
    RTS
OP1100_INVL_EA_SRC
    ADD.B       #10, BAD_DATA_        
    RTS 
* MODE_REGISTER----------------------
OP1100_GET_SIZE
    MOVE.W      D5,D6
    ROL.W       #2,D5
    ANDI.W      #$3,D5
    CMP.W       #$0,D5
    BEQ         OP1100_AND_B
    CMP.W       #$1,D5
    BEQ         OP1100_AND_W
    CMP.W       #$2,D5
    BEQ         OP1100_AND_L
    ADD.B       #10, BAD_DATA_               
    RTS

OP1100_AND_B
    MOVE.B      #0,D3
    RTS
OP1100_AND_W
    MOVE.B      #1,D3
    RTS
OP1100_AND_L
    MOVE.B      #2,D3
    RTS    

    
*************** ADD & ADDA ***************************************************************************
OPCODE1101
    MOVE.W      D7, D4
    ANDI.W      #$01C0, D4 
  
    *OPMODE FOR ADD
    CMP.W       #$0000, D4
    BEQ         EA_Dn_OP1101_B
    CMP.W       #$0100, D4
    BEQ         Dn_EA_OP1101_B
   
    CMP.W       #$0040, D4
    BEQ         EA_Dn_OP1101_W
    CMP.W       #$0140, D4
    BEQ         Dn_EA_OP1101_W
   
    CMP.W       #$0080, D4
    BEQ         EA_Dn_OP1101_L
    CMP.W       #$0180, D4
    BEQ         Dn_EA_OP1101_L
   
    **OPMODE FOR ADDA
    CMP.W       #$00C0, D4
    BEQ         EA_An_OP1101_W
    CMP.W       #$01C0, D4
    BEQ         EA_An_OP1101_L
 
    ADD.B       #10, BAD_DATA_ 
    RTS   
 
*BYTE CASE   
EA_Dn_OP1101_B
    JSR             GET_ADD
    MOVE.B          #'B',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
 
Dn_EA_OP1101_B
    JSR             GET_ADD
    MOVE.B          #'B',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)   
    MOVE.B          #',',(A5)+
 
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    RTS
 
* WORD EA - DN Case
EA_Dn_OP1101_W
    JSR            GET_ADD
    MOVE.B          #'W',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
Dn_EA_OP1101_W
    JSR             GET_ADD
    MOVE.B          #'W',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)   
    MOVE.B          #',',(A5)+
 
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    RTS
EA_Dn_OP1101_L
    JSR             GET_ADD
    MOVE.B          #'L',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
Dn_EA_OP1101_L
    JSR             GET_ADD
    MOVE.B          #'L',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    
    MOVE.B          #'D',(A5)+
    MOVE.W          D7, D4
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6)   
    MOVE.B          #',',(A5)+
 
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6) 
    RTS
    
    
EA_An_OP1101_W
    JSR            GET_ADDA
    MOVE.B          #$1, D3
    MOVE.B          #'W',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR             00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    MOVE.W          D7, D5
    ROL.W           #7,D5
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
    
EA_An_OP1101_L
    JSR             GET_ADDA
    MOVE.B          #'L',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
    MOVE.B          #' ',(A5)+
   
    MOVE.W          D5, D6                    
    ROL.W           #3, D6
    MOVE.W          D6, D5
 
    MOVE.W          D5, D6                    
    ROL.W           #3, D6
    MOVE.W          D6, D5
   
    MOVE.W          D5, D6                    
    ROL.W           #3, D6
    MOVE.W          D6, D5
    CLR.L           D3
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             SRT_EAMODE, A0
    JSR             00(A0,D6) 
    
    MOVE.B          #',',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.W          D7, D4
    MOVE.W          D7, D5
    ROL.W           #7,D5
    ANDI.W          #$0E00, D4
    LSR.W           #4, D4
    LSR.W           #4, D4
    LSR.W           #1, D4
    MOVE.W          D4, D6
    ANDI.W          #$0007, D6
    MULU            #6, D6
    LEA             RGSTRS, A0
    JSR             00(A0,D6) 
    RTS
 
GET_ADD
    MOVE.B          #'A',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.B          #'.',(A5)+
    RTS
   
GET_ADDA
    MOVE.B          #'A',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.B          #'D',(A5)+
    MOVE.B          #'A',(A5)+
    MOVE.B          #'.',(A5)+
    RTS   

*************** ASL, ASR, LSL, LSR, ROL, ROR *************************************************
OPCODE1110    
    * Check for Memory Shift
    MOVE.W      D7,D4
    ANDI.W      #$0FC0, D4
    CMP.W       #$07C0, D4
    BEQ         CHECK_ROL_LGCL
    CMP.W      #$06C0, D4
    BEQ         CHECK_ROR_LGCL
    CMP.W       #$01C0, D4
    BEQ         CHECK_ASL_LGCL
    CMP.W       #$00C0, D4
    BEQ        CHECK_ASR_LGCL
    CMP.W       #$03C0, D4
    BEQ         CHECK_LSL_LGCL
    CMP.W       #$02C0, D4
    BEQ         CHECK_LSR_LGCL
   
    CLR.L       D4
   
    * Check for Register Shift
    MOVE.W      D7, D4
    ANDI.W      #$0118, D4
    CMP.W       #$0118, D4
    BEQ         GET_ROL
    CMP.W       #$0018,D4
    BEQ         GET_ROR
    CMP.W       #$0100, D4
    BEQ         GET_ASL
    CMP.W       #$0000, D4
    BEQ         GET_ASR
    CMP.W       #$0108, D4
    BEQ         GET_LSL
    CMP.W       #$0008, D4
    BEQ         GET_LSR

   
    * Otherwise is bad data
    ADD.B       #10, BAD_DATA_              
    RTS
   
CHECK_ROL_LGCL
    MOVE.B  #'R',(A5)+
    MOVE.B  #'O',(A5)+
    MOVE.B  #'L',(A5)+
    MOVE.B  #'.',(A5)+
    MOVE.B  #'W',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6)
    RTS
CHECK_ROR_LGCL
    MOVE.B  #'R',(A5)+
    MOVE.B  #'O',(A5)+
    MOVE.B  #'R',(A5)+
    MOVE.B  #'.',(A5)+
    MOVE.B  #'W',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6)
    RTS

CHECK_ASL_LGCL  
    MOVE.B  #'A',(A5)+
    MOVE.B  #'S',(A5)+
    MOVE.B  #'L',(A5)+
    MOVE.B  #'.',(A5)+
    MOVE.B  #'W',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6)
    RTS

CHECK_ASR_LGCL  
    MOVE.B  #'A',(A5)+
    MOVE.B  #'S',(A5)+
    MOVE.B  #'R',(A5)+
    MOVE.B  #'.',(A5)+
    MOVE.B  #'W',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6)
    RTS
CHECK_LSL_LGCL
    MOVE.B  #'L',(A5)+
    MOVE.B  #'S',(A5)+
    MOVE.B  #'L',(A5)+
    MOVE.B  #'.',(A5)+
    MOVE.B  #'W',(A5)+  
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6)
    RTS
   
CHECK_LSR_LGCL
    MOVE.B  #'L',(A5)+
    MOVE.B  #'S',(A5)+
    MOVE.B  #'R',(A5)+
    MOVE.B  #'.',(A5)+
    MOVE.B  #'W',(A5)+  
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
    MOVE.B  #' ',(A5)+
   
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
    LEA             SRT_EAMODE, A0
    JSR         00(A0,D6)
    RTS

   
   
GET_ROL
    MOVE.B  #'R',(A5)+
    MOVE.B  #'O',(A5)+
    MOVE.B  #'L',(A5)+
    MOVE.B  #'.',(A5)+
    JSR     SIZE_SHIFT
    RTS
GET_ROR
    MOVE.B  #'R',(A5)+
    MOVE.B  #'O',(A5)+
    MOVE.B  #'R',(A5)+
    MOVE.B  #'.',(A5)+
    JSR     SIZE_SHIFT
    RTS
GET_ASL
    MOVE.B  #'A',(A5)+
    MOVE.B  #'S',(A5)+
    MOVE.B  #'L',(A5)+
    MOVE.B  #'.',(A5)+
    JSR     SIZE_SHIFT
    RTS
GET_ASR
    MOVE.B  #'A',(A5)+
    MOVE.B  #'S',(A5)+
    MOVE.B  #'R',(A5)+
    MOVE.B  #'.',(A5)+
    JSR     SIZE_SHIFT
    RTS
GET_LSL
    MOVE.B      #'L',(A5)+
    MOVE.B      #'S',(A5)+
    MOVE.B      #'L',(A5)+
    MOVE.B      #'.',(A5)+            
    JSR         SIZE_SHIFT
    RTS
GET_LSR
    MOVE.B      #'L',(A5)+
    MOVE.B      #'S',(A5)+
    MOVE.B      #'R',(A5)+
    MOVE.B      #'.',(A5)+            
    JSR         SIZE_SHIFT
    RTS
SIZE_SHIFT
    MOVE.W      D7, D4
    ANDI.W      #$00C0, D4
    CMP.W       #$0000, D4
    BEQ         SIZESHIFT_B
    CMP.W       #$0040, D4
    BEQ         SIZESHIFT_W
    CMP.W       #$0080, D4
    BEQ         SIZESHIFT_L
   
    ADD.B       #10, BAD_DATA_              
    RTS
   
SIZESHIFT_B
    MOVE.B      #'B',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    BRA         SHIFT__IR
SIZESHIFT_W
    MOVE.B      #'W',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    BRA         SHIFT__IR    
SIZESHIFT_L
    MOVE.B      #'L',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+
    BRA         SHIFT__IR

SHIFT__IR
    MOVE.W      D7, D4
    ANDI.W      #$0020, D4
    CMP.W       #$0020, D4
    BEQ         SHIFT_Dn_RGSTR              ******
    CMP.W       #$0000, D4
    BEQ         SHIFT_NUMBER
   
SHIFT_Dn_RGSTR
    MOVE.B      #'D',(A5)+
    MOVE.W      D7, D4
    ANDI.W      #$0E00, D4
    LSR.W       #6, D4
    MOVE.W      D4, D5
    MOVE.W      D4, D6
    LSR.W       #3, D6
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)  

    MOVE.B      #',',(A5)+  
    MOVE.B      #'D',(A5)+
    MOVE.W      D7, D4
    ANDI.W      #$0007, D4
    LSL.W       #3, D4
    MOVE.W      D4, D5
    MOVE.W      D4, D6
    LSR.W       #3, D6
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)  
   
    RTS
   
SHIFT_NUMBER
    MOVE.B      #'#',(A5)+
    MOVE.W      D7, D4
    ANDI.W      #$0E00, D4
    ROR.W       #8, D4
    LSR.B       #1, D4
    ADDI.B      #$30,D4
    MOVE.B      D4,(A5)+
   
    MOVE.B      #',',(A5)+  
    MOVE.B      #'D',(A5)+
    MOVE.W      D7, D4
    ANDI.W      #$0007, D4
    LSL.W       #3, D4
    MOVE.W      D4, D5
    MOVE.W      D4, D6
    LSR.W       #3, D6
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    RTS


    

                             
* SUB ROUTINES USED FOR MANY OPCODES
*********************************************************
SRT_EAMODE
    JMP    SRT_EA_000		* EA 000
    JMP    SRT_EA_001		* EA 001
    JMP    SRT_EA_010		* EA 010
    JMP    SRT_EA_011		* EA 011
    JMP    SRT_EA_100		* EA 100
    JMP    SRT_EA_101		* EA 101
    JMP    SRT_EA_110		* EA 110
    JMP    SRT_EA_111		* EA 111
*********************************************************   
RGSTRS
    JMP    RGSTR000         	* Register 000
    JMP    RGSTR001         	* Register 001
    JMP    RGSTR010         	* Register 010
    JMP    RGSTR011         	* Register 011
    JMP    RGSTR100         	* Register 100
    JMP    RGSTR101         	* Register 101
    JMP    RGSTR110         	* Register 110
    JMP    RGSTR111         	* Register 111


* JUMP TABLE SUBROUTINES FOR OPCODE 0100 EXCEPT MOVEM ------------------------  
THREE000
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6) 
    RTS
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
    BEQ             CHECK_RTS                          * If so go to the ITSARTS function
    CMP.W           #$4E71, D7
    BEQ            CHECK_NOP
CHECK_JSR
    MOVE.W          D5, D6                     
    ROL.W           #3, D6
    MOVE.W          D6, D5
    ANDI.W          #$0007, D6
    MULU            #8, D6
    LEA             THREE_TABLE_2, A0
    JSR             00(A0,D6)   
    RTS
CHECK_NOP
    MOVE.B  #'N',(A5)+						* Insert R into output
    MOVE.B  #'O',(A5)+						* Insert T into output
    MOVE.B  #'P',(A5)+						* Insert S into output
    RTS  
CHECK_RTS
    MOVE.B  #'R',(A5)+						* Insert R into output
    MOVE.B  #'T',(A5)+						* Insert T into output
    MOVE.B  #'S',(A5)+						* Insert S into output
    RTS       
*-------------------------------------------------------------------------------  
THREE2000
    ADDI.B      #10,BAD_DATA_
    RTS
ERROR
    ADDI.B      #10,BAD_DATA_  
    RTS
THREE2001
    ADDI.B      #10,BAD_DATA_
    RTS

THREE2010
    MOVE.W      D7, D6
    
    ANDI.W      #$FE00, D6
    CMP.W       #$4200, D6
    BEQ         ERROR
    CMP.W       #$4E00, D6
    BNE         ERROR
    
    MOVE.B      #'J',(A5)+
    MOVE.B      #'S',(A5)+
    MOVE.B      #'R',(A5)+
    MOVE.B      #' ',(A5)+
    MOVE.B      #' ',(A5)+    
    MOVE.B      #' ',(A5)+ 
    BRA         THREE2010_EA   
    
THREE2010_EA    
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         SRT_EAMODE, A0
    JSR         00(A0,D6)  
    RTS
THREE2011
    ADDI.B      #10, BAD_DATA_
    RTS
THREE2100
    ADDI.B      #10,BAD_DATA_
    RTS
THREE2101
    ADDI.B      #10,BAD_DATA_
    RTS
THREE2110
    ADDI.B      #10,BAD_DATA_
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
    LEA         SRT_EAMODE, A0
    JSR         00(A0,D6)  
    MOVE.B      #',',(A5)+
    
    CLR.L       D5
    MOVE.W      D7, D5
    ROL.L       #4, D5
    JSR         SRT_EA_001
    RTS

SRT_EA_000
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'D',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    MOVEM.L     (SP)+,D0-D7
    RTS   
SRT_EA_001
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    MOVEM.L     (SP)+,D0-D7
    RTS       		
SRT_EA_010 
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'(',(A5)+  
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    MOVE.B      #')',(A5)+
    MOVEM.L     (SP)+,D0-D7
    RTS		
SRT_EA_011
    MOVEM.L     D0-D7,-(SP) 
    MOVE.B      #'(',(A5)+  
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    MOVE.B      #')',(A5)+
    MOVE.B      #'+',(A5)+
    MOVEM.L     (SP)+,D0-D7
    RTS
SRT_EA_100
    MOVEM.L     D0-D7,-(SP)
    MOVE.B      #'-',(A5)+
    MOVE.B      #'(',(A5)+  
    MOVE.B      #'A',(A5)+  
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    MOVE.B      #')',(A5)+
    MOVEM.L     (SP)+,D0-D7
    RTS      		
SRT_EA_101
    ADD.B       #10, BAD_DATA_          
    RTS      		
SRT_EA_110
    ADD.B       #10, BAD_DATA_             
    RTS     		
SRT_EA_111
    MOVEM.L     D0-D7,-(SP)
    MOVE.W      D5, D6                     
    ROL.W       #3, D6
    MOVE.W      D6, D5
    ANDI.W      #$0007, D6
    MULU        #6, D6
    LEA         RGSTRS, A0
    JSR         00(A0,D6)
    MOVEM.L     (SP)+,D0-D7
    RTS 		
* Registers ------------------------------------------------
RGSTR000
    MOVE.W      D5, D6                     
    ROL.W       #8, D6
    ROL.W       #5, D6

    ANDI.W      #$0007, D6
    CMP.B       #$7,D6
    BEQ         READ_NEXT_W
    BRA         CNT_RGSTR000
READ_NEXT_W
    MOVE.B	    #0,D6                           * Set 0
    MOVE.B      #'$',(A5)+
    MOVE.W      (A6)+,D5                           * Bad Code to D5
    MOVE.B      #4,D3
    JSR         WORD2ASCII
    RTS
CNT_RGSTR000
    MOVE.B      #'0',(A5)+
    RTS
    
RGSTR001
    MOVE.W      D5, D6                     
    ROL.W       #8, D6
    ROL.W       #5, D6

    ANDI.W      #$0007, D6
    CMP.B       #$7,D6
    BEQ         READ_NEXT_L
    BRA         CNT_RGSTR001 
READ_NEXT_L
    MOVE.B	    #0,D6                           * Set 0
    MOVE.B      #'$',(A5)+
    MOVE.L      (A6)+,D5                           * Bad Code to D5
    MOVE.B      #8,D3
    JSR         LONG2ASCII
    RTS
CNT_RGSTR001  
    MOVE.B      #'1',(A5)+
    RTS
    
RGSTR010
    MOVE.B      #'2',(A5)+
    RTS
RGSTR011
    MOVE.B      #'3',(A5)+
    RTS
RGSTR100
    MOVE.W      D5, D6                     
    ROL.W       #8, D6
    ROL.W       #5, D6

    ANDI.W      #$0007, D6
    CMP.B       #$7,D6
    BEQ         SIZE_RGSTR100
    BRA         CNT_RGSTR100    
SIZE_RGSTR100
    CMP.B       #$1,D3
    BEQ         READ_NEXT_W_100
    CMP.B       #0,D3
    BEQ         READ_NEXT_L_100
READ_NEXT_W_100
    MOVE.B      #'#',(A5)+
    MOVE.B      #'$',(A5)+
    MOVE.B      #0,D6
    MOVE.W      (A6)+,D5
    MOVE.B      #4,D3
    JSR         WORD2ASCII
    RTS
READ_NEXT_L_100
    MOVE.B      #'#',(A5)+
    MOVE.B      #'$',(A5)+    
    MOVE.B      #0,D6
    MOVE.L      (A6)+,D5
    MOVE.B      #8,D3
    JSR         LONG2ASCII
    RTS
CNT_RGSTR100    
    MOVE.B      #'4',(A5)+
    RTS
RGSTR101
    MOVE.B      #'5',(A5)+
    RTS
RGSTR110
    MOVE.B      #'6',(A5)+
    RTS
RGSTR111
    MOVE.B      #'7',(A5)+
    RTS
*---------------------------------------------------------------


********************************************************************************************
* PRINT CURRENT ADDRESS IN ASCII -----------------------------------------
PRINT_CUR_ADDRS
        MOVE.L      A6,D2                       * Move current address into D2
        MOVE.B      #0,D5                       * Set counter to read all hex
        MOVE.B      #8,D6                       
CNVRT_HEX2ASCII
        CMP.B       D5,D6                       * Check if last hex character is read
        BNE         SET_CNTR_4               * Set counter to read 4 bits
        MOVE.B      #6, D0
        MOVE.B      #32, D1
        TRAP        #15
        TRAP        #15
        TRAP        #15
        RTS
SET_CNTR_4
        MOVE.B      #0,D3                       
        MOVE.B      #4,D4    
CUR_ADDR_LOOP
        CMP.B       D3,D4                       * Read one character at a time
        BEQ         STORE_A_CHARACTER
        LSL.L       #1,D2
        BCC         ADD_ZERO
        ADDI.B      #1,D1
        BRA         INCREMENT_BIT_LOOP
ADD_ZERO
        ADDI.B      #0,D1
INCREMENT_BIT_LOOP
        ADDI.B      #1,D3
        LSL.L       #1,D1
        BRA         CUR_ADDR_LOOP
STORE_A_CHARACTER                                   * Store hex character
        LSR.L       #1,D1
        CMP.B       #$A,D1
        BLT         HEX2ASCII_NUM
        ADDI.B      #$37,D1                     * HEX_TO_ASCII_LETTER
        BRA        ICMT_NEXT_HEXLOOP
HEX2ASCII_NUM
        ADDI.B      #$30,D1
ICMT_NEXT_HEXLOOP
        ADDI.B      #1,D5
        MOVE.B      #6,D0
        TRAP        #15
        CLR.L       D1
        BRA         CNVRT_HEX2ASCII

******************* USER_RESPONSE **********************************************************************
* Expect:       DO, D1, A1 to be empty
* Prompt User for Enter, R, or Q -----------------------------------------
USER_RSPNS
        LEA         USER_OPTION, A1            * Load the prompt message
        MOVE.B      #14,D0
        TRAP        #15 
        MOVE.B      #$00, LINE_COUNTERS            * Reset Line Count 
        MOVE.B      #5, D0                      * Log keyboard input
        TRAP        #15                 
        CMP.B       #$D, D1                     * Compare the key press with ENTER
        BEQ         SCREEN_CLEAR                  
        CMP.B       #$72, D1                    * Compare the key press with R
        BEQ         RE_PROGRAM
        CMP.B       #$52, D1                    * Compare the key press with r
        BEQ         RE_PROGRAM
        CMP.B       #$71, D1                    * Compare the key press with q
        BEQ         HALT_PROGRAM             
        CMP.B       #$51, D1                    * Compare the key press with Q
        BEQ         HALT_PROGRAM            
        CMP.B       #$5D, D1                    * Check the key press with ENTER
        BNE         USER_RSPNS              
SCREEN_CLEAR
        MOVE.B  #11, D0                         * Task 11 - Clear screen
        MOVE.W  #$FF00, D1          
        TRAP    #15                 
        CLR.L   D1
        CLR.L   D0
        RTS                 
*------------------ RESTART ----------------------------------------------------------------
RE_PROGRAM
        JSR        SCREEN_CLEAR
        JSR         RGSTR_CLEAR
        MOVEA.L     #$01000000,A7       Reset stack pointer
        MOVEA.L     #$01000000,A6       Reset stack pointer
        BRA         START
        
********************************************************************************************
* CLEAR REGISTERS --------------------------------------------------------
RGSTR_CLEAR
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

********************************************************************************************
********************************************************************************************
********************************************************************************************
PROGRAM_END_PROMPT
        LEA         MSG_RESTART, A1            * Load the prompt message
        MOVE.B      #14,D0
        TRAP        #15 
        MOVE.B      #$00, LINE_COUNTERS            * Reset Line Count 
        MOVE.B      #5, D0                      * Log keyboard input
        TRAP        #15                            
        CMP.B       #$59, D1                    * Compare the key press with Y
        BEQ         RE_PROGRAM
        CMP.B       #$79, D1                    * Compare the key press with y
        BEQ         RE_PROGRAM
        CMP.B       #$4E, D1                    * Compare the key press with N
        BEQ         HALT_PROGRAM             
        CMP.B       #$6E, D1                    * Compare the key press with n
        BEQ         HALT_PROGRAM
        BRA         PROGRAM_END_PROMPT
        
HALT_PROGRAM
        JSR         SCREEN_CLEAR        
        SIMHALT             ; halt simulator
********************************************************************************************
********************************************************************************************
********************************************************************************************


********************************************************************************************
* VARIABLES & MESSAGES ---------------------------------------------------------------------
CR        EQU       $0D
LF        EQU       $0A

* MESSAGES ---------------------------------------------------------------------------------------------
MESSAGE_GREETING   DC.B    '       HELLO THERE, WELCOME TO AWESOME DISASSEMBLER'
                DC.B    CR,LF,'Note: Addressess must be in HEX'
                DC.B    CR,LF,'Note: Addressess must be in caps'
                DC.B    CR,LF,'    : Starting Address must be greater than 7000',CR,LF,CR,LF,CR,LF,0 
MSG_STRT_ADDR     DC.W    'ENTER A STARTING ADDRESS (ON CAPS): ',0
MSG_END_ADDR     DC.W    'ENTER A ENDING ADDRESS   (ON CAPS): ',0
USER_OPTION    DC.B    'Press: ENTER to Continue || Q or q to Quit || R OR r to Restart',CR,LF,CR,LF,0
MSG_RESTART DC.B    'Press: Y/y to restart || N/n to end program',CR,LF,CR,LF,0
* ERROR MSG --------------------------------------------------------------------------------------------
ERROR_STRT_ADDR        DC.B    'ERROR: INVALID STARTING ADDRESS VERSUS ENDING.',CR,LF,CR,LF,0
ERROR_ADDRSIZE      DC.B    'ERROR: INVALID ADDRESS SIZE',CR,LF,CR,LF,0
ERROR_INVALIDCHAR         DC.B    'ERROR: INVALID ADDRESS CHARACTER',CR,LF,CR,LF,0
ERROR_STRTGEND               DC.B    'ERROR: STARTING ADDRESS > ENDING ADDRESS',CR,LF,CR,LF,0
ERROR_ODDADDR         DC.B    'ERROR: ODD ADDRESS',CR,LF,CR,LF,0
ERROR_SADDR_POINT     DC.B    'ERROR: Invalid starting adress - must be greater than 7000',CR,LF,CR,LF,0
* VARIABLES --------------------------------------------------------------------------------------------
LINE_COUNTERS      DS.L    1 *holds line number of the instruction, up to a maximum of 25 on a screen
BAD_DATA_  DS.L    1         * stores whether or not the current opcode is bad data, switches addr_loop to print bad data
SIZE            DS.B    1 
INPUT_HEX       DS.L    1   * Use to temp hold starting and ending address
START_ADDR    DS.L    1   *Used to store starting address * 1 is the size, if I change to 4 then array size changes
END_ADDR      DS.L    1   *Used to store ending address
PROGRAM_PRINTER         DC.L    1 * used to store characters to print on the screen
        
        END    START







































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
