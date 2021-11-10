*-----------------------------------------------------------
* Title      :HW3-Q4    
* Written by :David Woo 
* Date       :11/7/2021 
* Description:
*-----------------------------------------------------------
   



START   ORG    $4000                  ; first instruction of program

            MOVE.B  #8,D3   
                        LEA          MESSAGE1,A1  
                MOVE.B  #14,D0  
            TRAP    #15 

Input        MOVE.B  #2,D0        *Trap task 2 does the following:     
             TRAP    #15                  *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)  



AtoH                MOVE.B     (A1)+,D6        * move user input data from (A1) to D6          

                        CMPI.B      #$30,D6
                        BLT.B       ERR 
                        CMP.B       #$39,D6 
                        BGT.B       ALPHA    
                        SUBI.B      #$30,D6
                        BRA         Step2       
                        RTS     

ERR                 LEA         ERRM,A1 
                        MOVE.B    #14,D0    
                        TRAP        #15     
                        BRA         Input      
        
ALPHA             CMPI.B      #$41,D6     
                        BLT.B       ERR    
                        CMPI.B      #$46,D6     
                        BGT.B       ERR     
                        SUBI.B      #$37,D6    
                        BRA         Step2      
                        RTS     

Step2       ADD.B   D6,D5 
            SUBI.B  #1,D3  
            CMP.B   #$0,D3    
            BEQ     Step1        
            ASL.L   #$04,D5
            CMP.B   #$0,D3
            BNE     AtoH

Step1      MOVE.L   D5,Userinput    
           BRA      Step3
   
Step3               MOVE.L      Userinput,$A000          * store result in address $ A000 by hexidecimal        
            ANDI.L   #$80000000,$A000
            TST.L    $A000  
            BEQ      PRINT_POSTIVE
            BNE      PRINT_NEGATIVE    
            STOP     #$2700

Step4       MOVE.L   Userinput,D5   
            ASL.B    #$01,D5      
            ANDI.L   #$7F800000,D5
            LSR.L    #$08,D5
            LSR.L    #$08,D5
            LSR.L    #$07,D5   
            MOVE.B   D5,Exponent
            LEA      MESSAGE2,A1
            MOVE.B   #14,D0
            TRAP     #15
            CLR.L    D1
            MOVE.B   Exponent,D1
            MOVE.B   #3,D0
            TRAP     #15
            BRA      Step5      
            STOP     #$2700

Step5               MOVE.L      Userinput,D5
                        ASL.L          #$01,D5
                        ASL.L          #$08,D5
                        ANDI.L        #$FFFFFE00,D5
                        CLR.L         D3 
                        MOVE.B      #32,D3  

Step7               LSR.L         #$01,D5
                        SUBI.B       #1,D3
                        BTST.L       #$00,D5    
                        BNE            Step6    
                        CMP.B       #$0,D3    
                        BEQ           Step8         
                        JMP           Step7  
            STOP     #$2700

Step6               
                        MOVE.L      D5,Mantissa
                        LEA            MESSAGE3,A1
                        MOVE.B      #14,D0
                        TRAP          #15 
                        CLR.L         D1
                        MOVE.L      Mantissa,D1
                        MOVE.B      #3,D0
                        TRAP     #15
                        STOP     #$2700

Step8                              
             MOVE.B     #0,Mantissa
             LEA         MESSAGE3,A1
             MOVE.B      #14,D0
             TRAP        #15 
             CLR.L       D1
             MOVE.B      Mantissa,D1
             MOVE.B      #3,D0
            TRAP        #15
            STOP     #$2700       
PRINT_POSTIVE       LEA         Postive,A1  
                MOVE.B  #14,D0  
                TRAP    #15
                BRA     Step4   

PRINT_NEGATIVE     LEA          Negative,A1 
                MOVE.B  #14,D0  
                TRAP    #15
                BRA     Step4    
* Put program code here

CR      EQU         $0D         
LF      EQU         $0A

MESSAGE1    DC.B    'Please enter IEEE 32-bit floating point number in hexadecimal: ',0   
ERRM       DC.B  CR,LF,'Enter Valid hexadecimal value: ', 0  
Postive         DC.B    'Sign bit: +',CR,LF,0
Negative         DC.B    'Sign bit: -',CR,LF,0
MESSAGE2     DC.B    'Exponent: ',0
MESSAGE3     DC.B    CR,LF,'Mantissa: ',0
* Put variables and constants here

Userinput       DS.L       1    
Exponent       DS.W      1
Mantissa       DS.W      1

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
