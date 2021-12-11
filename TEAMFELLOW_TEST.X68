*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

* Put program code here 

***-------NOP-------------------
    NOP
    
    
    
***---------- MOVE.B OPCODE-----------
     
     MOVE.B  D3, D2
     MOVE.B  (A1),D4     *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,D3
     MOVE.B  -(A1),D1   
     MOVE.B  $48,D2
     MOVE.B  #1,D1
     MOVE.B  #$AA,D1
*     MOVE.B  #$4444,D2
*     MOVE.B  #$4444888,D2
    
     MOVE.B  D3, (A2)
     MOVE.B  (A1),(A4)     *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,(A3)
     MOVE.B  -(A1),(A1)  
     MOVE.B  $48,(A2)
     MOVE.B  #1,(A1)
     MOVE.B  #$AA,(A1)
*     MOVE.B  #$4444,(D2)
*     MOVE.B  #$4444888,(D2)
    
     MOVE.B  D3, (A2)+
     MOVE.B  (A1),(A4)+     *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,(A3)+
     MOVE.B  -(A1),(A1)+  
     MOVE.B  $48,(A2)+
     MOVE.B  #1,(A1)+
     MOVE.B  #$AA,(A1)+   
                      
     MOVE.B  D3, -(A2)
     MOVE.B  (A1),-(A4)     *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,-(A3)
     MOVE.B  -(A1),-(A1)  
     MOVE.B  $48,-(A2)
     MOVE.B  #1,-(A1)
     MOVE.B  #$AA,-(A1) 
   
     MOVE.B  D3,$12 
     MOVE.B  (A1),$12      *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,$12 
     MOVE.B  -(A1),$12   
     MOVE.B  $48,$12 
     MOVE.B  #1,$12 
     MOVE.B  #$AA,$12    
    
     MOVE.B  D3,$1212 
     MOVE.B  (A1),$1212      *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,$1212 
     MOVE.B  -(A1),$1212   
     MOVE.B  $48,$1212 
     MOVE.B  #1,$1212 
     MOVE.B  #$AA,$1212
     
     MOVE.B  D3,$12124444 
     MOVE.B  (A1),$12124444      *DESTINATION CANT BE AN & #<DATA>
     MOVE.B  (A2)+,$12124444 
     MOVE.B  -(A1),$12124444   
     MOVE.B  $48,$12124444 
     MOVE.B  #1,$12124444 
     MOVE.B  #$AA,$12124444
     


***----------2. MOVE.W-------------------
     MOVE.W  D3, D2
     MOVE.W  (A1),D4     *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,D3
     MOVE.W  -(A1),D1   
     MOVE.W  $48,D2
     MOVE.W  #1,D1
     MOVE.W  #$AA,D1
     MOVE.W  #$4444,D2
*     MOVE.W  #$4444888,D2
    
     MOVE.W  D3, (A2)
     MOVE.W  (A1),(A4)     *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,(A3)
     MOVE.W  -(A1),(A1)  
     MOVE.W  $48,(A2)
     MOVE.W  #1,(A1)
     MOVE.W  #$AA,(A1)
     MOVE.W  #$4444,(A2)
*     MOVE.W  #$4444888,(D2)
    
     MOVE.W  D3, (A2)+
     MOVE.W  (A1),(A4)+     *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,(A3)+
     MOVE.W  -(A1),(A1)+  
     MOVE.W  $48,(A2)+
     MOVE.W  #1,(A1)+
     MOVE.W  #$AA,(A1)+   
                      
     MOVE.W  D3, -(A2)
     MOVE.W  (A1),-(A4)     *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,-(A3)
     MOVE.W  -(A1),-(A1)  
     MOVE.W  $48,-(A2)
     MOVE.W  #1,-(A1)
     MOVE.W  #$AA,-(A1) 
   
     MOVE.W  D3,$12 
     MOVE.W  (A1),$12      *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,$12 
     MOVE.W  -(A1),$12   
     MOVE.W  $48,$12 
     MOVE.W  #1,$12 
     MOVE.W  #$AA,$12    
    
     MOVE.W  D3,$1212 
     MOVE.W  (A1),$1212      *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,$1212 
     MOVE.W  -(A1),$1212   
     MOVE.W  $48,$1212 
     MOVE.W  #1,$1212 
     MOVE.W  #$AA,$1212
     
     MOVE.W  D3,$12124444 
     MOVE.W  (A1),$12124444      *DESTINATION CANT BE AN & #<DATA>
     MOVE.W  (A2)+,$12124444 
     MOVE.W  -(A1),$12124444   
     MOVE.W  $48,$12124444 
     MOVE.W  #1,$12124444 
     MOVE.W  #$AA,$12124444
     

 
*  
***----------- MOVE.L---------------
 MOVE.W  D3, D2
     MOVE.L  (A1),D4     *DESTINATION CANT BE AN & #<DATA>
     MOVE.L  (A2)+,D3
     MOVE.L  -(A1),D1   
     MOVE.L  $48,D2
     MOVE.L  #1,D1
     MOVE.L  #$AA,D1
     MOVE.L  #$4444,D2
     MOVE.L  #$4444888,D2
    
     MOVE.L  D3, (A2)
     MOVE.L  (A1),(A4)     *DESTINATION CANT BE AN & #<DATA>
     MOVE.L  (A2)+,(A3)
     MOVE.L  -(A1),(A1)  
     MOVE.L  $48,(A2)
     MOVE.L  #1,(A1)
     MOVE.L  #$AA,(A1)
     MOVE.L  #$4444,(A2)
     MOVE.L  #$4444888,(A2)
    
     MOVE.L  D3, (A2)+
     MOVE.L  (A1),(A4)+     
     MOVE.L  (A2)+,(A3)+
     MOVE.L  -(A1),(A1)+  
     MOVE.L  $48,(A2)+
     MOVE.L  #1,(A1)+
     MOVE.L  #$AA,(A1)+ 
     MOVE.L  #$4444888,(A2)+  
                      
     MOVE.L  D3, -(A2)
     MOVE.L  (A1),-(A4)     *DESTINATION CANT BE AN & #<DATA>
     MOVE.L  (A2)+,-(A3)
     MOVE.L  -(A1),-(A1)  
     MOVE.L  $48,-(A2)
     MOVE.L  #1,-(A1)
     MOVE.L  #$AA,-(A1) 
     MOVE.L  #$4444888,-(A2)
   
     MOVE.L  D3,$12 
     MOVE.L  (A1),$12      *DESTINATION CANT BE AN & #<DATA>
     MOVE.L  (A2)+,$12 
     MOVE.L  -(A1),$12   
     MOVE.L  $48,$12 
     MOVE.L  #1,$12 
     MOVE.L  #$AA,$12 
     MOVE.L  #$4444888,$34   
    
     MOVE.L  D3,$1212 
     MOVE.L  (A1),$1212      *DESTINATION CANT BE AN & #<DATA>
     MOVE.L  (A2)+,$1212 
     MOVE.L  -(A1),$1212   
     MOVE.L  $48,$1212 
     MOVE.L  #1,$1212 
     MOVE.L  #$AA,$1212
     MOVE.L  #$4444888,$1234
     
     MOVE.L  D3,$12124444 
     MOVE.L  (A1),$12124444      *DESTINATION CANT BE AN & #<DATA>
     MOVE.L  (A2)+,$12124444 
     MOVE.L  -(A1),$12124444   
     MOVE.L  $48,$12124444 
     MOVE.L  #1,$12124444 
     MOVE.L  #$AA,$12124444
     MOVE.L  #$4444888,$12341234
   
****-----------MOVEQ ------------------
 
    MOVEQ    #1, D4   * BYTE AND An ONLY
    MOVEQ    #2, D4
    MOVEQ    #3,D4
    MOVEQ    #45, D5
    MOVEQ    #$12,D1
    MOVEQ    #$23,D3
    MOVEQ    #$12,D4
    MOVEQ    #255,D4 
    
*MOVEQ DON'T HAVE BAD OPCODE

****---------- ADD--------------------------

    ADD.B   $11,D5
    ADD.B   $1111,D5
    ADD.B   $11111111,D5
    ADD.B   $1111,D5
    ADD.W   $11111111,D5
    ADD.B   $48,D2
    ADD.B   #$DA,D3
    ADD.B   D3,(A6)+
    ADD.B   D1,(A2)
    ADD.B   D5,-(A0)
    ADD.B   #$40,D2
    ADD.B   D1,$E115
    ADD.B   D5,$E1234567
	
    ADD.W   #101,A6
    ADD.W   $48,D3
    ADD.W   #$AA,D6
    ADD.W   D3,(A5)+
    ADD.W   D5,(A2)
    ADD.W   D2,-(A0)
    ADD.W   (A1),A5
    ADD.W   (A1)+,A1
    ADD.W   -(A1),A6
    ADD.W   #$40,D7
    ADD.W   D0,A2
    ADD.W   D0,$E115
    ADD.W   D0,$E1234567
    ADD.W   D5,$11
    ADD.W    D5,$11111111
    	
    ADD.L   #101,A6
    ADD.L   $48,D3
    ADD.L   #$AA,D6
    ADD.L   D3,(A5)+
    ADD.L   D5,(A2)
    ADD.L   D2,-(A0)
    ADD.L   (A1),A5
    ADD.L   (A1)+,A1
    ADD.L   -(A1),A6
    ADD.L   #$40,D7
    ADD.L   D0,A2
    ADD.L   D0,$E115
    ADD.L   D0,$E1234567
    ADD.L   D5,$11
    ADD.L    D5,$11111111

*
****---------- ADDA-------------------------
*
    ADDA.W  D0,A0
    ADDA.W  A2,A1
    ADDA.W  (A0),A1    
    ADDA.W  (A0)+,A1 
    ADDA.W  $12,A5
    ADDA.W  $123,A5
    ADDA.W  $123,A5
    ADDA.W  #12,A5
    ADDA.W  #$12,A5
    ADDA.W  #$1235,A5
    ADDA.W  #$1235,A5
    
    ADDA.L  D0,A0
    ADDA.L  A2,A1
    ADDA.L  (A0),A1    
    ADDA.L  (A0)+,A1 
    ADDA.L  $12,A5
    ADDA.L  $123,A5
    ADDA.L  $123,A5
    ADDA.L  #12,A5
    ADDA.L  #$12,A5
    ADDA.L  #$1235,A5
    ADDA.L #$1235,A5

****----------16. SUB-------------------------
    SUB.B   D1,D0
*    SUB.B   A4,D0
    SUB.B   (A4)+,D0 
    SUB.B   -(A5),D0
    SUB.B   $11,D0
    SUB.B   $1234,D2
    SUB.B   $AAAABBBB,D5
    SUB.B   #1,D7
    SUB.B   #12,D7  
*    SUB.B   #1212,D7
*    SUB.B   #12121234,D7

    SUB.W   D1,D0
    SUB.W   A4,D0
    SUB.W   (A4)+,D0 
    SUB.W   -(A5),D0
    SUB.W   $11,D0
    SUB.W   $1234,D2
    SUB.W   $AAAABBBB,D5
    SUB.W   #1,D7
    SUB.W   #12,D7  
    SUB.W   #1212,D7
*    SUB.B   #12121234,D7

    SUB.L   D1,D0
    SUB.L   A4,D0
    SUB.L   A4,D0
    SUB.L   (A4)+,D0 
    SUB.L   -(A5),D0
    SUB.L   $11,D0
    SUB.L   $1234,D2
    SUB.L   $AAAABBBB,D5
    SUB.L   #1,D7
    SUB.L   #12,D7  
    SUB.L   #1212,D7
    SUB.L   #12121234,D7         
****----------- LEA----------------
    LEA     (A3),A0         (An),An
    LEA     (A3),A3
    LEA     $9800,A1
    LEA     $0001,A2
    LEA     $4000,A7
    LEA     $1230,A5
    LEA     $1301,A5
    LEA     $01001,A1    
    LEA     $1,A4
    LEA     $123456,A7   
****----------- AND-------------------
     AND.B  D3, D2
     AND.B  (A1),D4     *DESTINATION CANT BE AN & #<DATA>
     AND.B  (A2)+,D3
     AND.B  -(A1),D1   
     AND.B  $48,D2
     AND.B  #1,D1
     AND.B  #$AA,D1
*     AND.B.B  #$4444,D2
*     MOVE.B  #$4444888,D2
    
    
*     MOVE.B  #$4444,(D2)
*     MOVE.B  #$4444888,(D2)
    
     AND.B    D3, (A2)+
     AND.B  #1,-(A1)
     AND.B  #$AA,-(A1) 
   
     AND.B  D3,$12 
     AND.B #1,$12 
     AND.B  #$AA,$12    
     AND.B  D3,$1212 

     AND.B  #1,$1212 
     AND.B  #$AA,$1212   
     AND.B  D3,$12124444 
     AND.B  #1,$12124444 
     AND.B  #$AA,$12124444    
*********************OR*******************************************
     OR.B  D0,D1
*    OR.B  A2,D2   EA CAN'T BE AN
     OR.B  (A3),D1
*    OR.B  (A4)+,(A6)+   DESTINATION IS NOT DN, AN,(AN) #<DATA>
     OR.B  -(A6),D3
     OR.B  $22,D4
     OR.B  $2222,D5
     OR.B  $22448888,D6
     
     OR.B  D0,(A3)
*    OR.B  A2,D2     
*    OR.B  (A3),(A3)      INVALID
*    OR.B  (A4)+,(A6)+    DESTINATION IS NOT DN, AN, #<DATA>
*    OR.B  -(A6),(A3)
     OR.B  $22,D4
     OR.B  $2222,D5
     OR.B  $22448888,D6
     OR.B  #$2,D6
     OR.B  #$22,D4
     OR.B  #$22,D5       ONLY WORK ON BYTE 
 
     OR.B  D0,-(A3)     * OTHER EA NOT WORK FOR -(A3)
     OR.B  D0,-(A3)
     OR.B  #$2,-(A3)
     OR.B  #$22,-(A3)
     OR.B  #$22,-(A3) 
     
     OR.B  D0,$12  * OTHER EA IS NOT WORK FOR DESTINATION $12
   
     OR.W  D0,D1
     OR.W (A3),D1
     OR.W  -(A6),D3
     OR.W $22,D4
     OR.W  $2222,D5
     OR.W  $22448888,D6
     
     OR.W  D0,(A3)
     OR.W  $22,D4
     OR.W  $2222,D5
     OR.W  $22448888,D6
     OR.W  #$2,D6
     OR.W  #$22,D4
     OR.W  #$22,D5       ONLY WORK ON BYTE 
 
     OR.W  D0,-(A3)     * OTHER EA NOT WORK FOR -(A3)
     OR.W  D0,-(A3)
     OR.W  #$2,-(A3)
     OR.W  #$22,-(A3)
     OR.W  #$22,-(A3) 
 
     OR.W  D0,$12  * OTHER EA IS NOT WORK FOR DESTINATION $12
     
     
     OR.L  D0,D1
     OR.L (A3),D1
     OR.L -(A6),D3
     OR.L $22,D4
     OR.L  $2222,D5
     OR.L  $22448888,D6
     
     OR.L  D0,(A3)
     OR.L  $22,D4
     OR.L  $2222,D5
     OR.L  $22448888,D6
     OR.L #$2,D6
     OR.L  #$22,D4
     OR.L  #$22,D5       ONLY WORK ON BYTE 
 
     OR.L  D0,-(A3)     * OTHER EA NOT WORK FOR -(A3)
     OR.L  D0,-(A3)
     OR.L  #$2,-(A3)
     OR.L  #$22,-(A3)
     OR.L  #$22,-(A3) 
 
     OR.L  D0,$12  * OTHER EA IS NOT WORK FOR DESTINATION $12
*****--------------NOT---------------------------****************
    NOT   D3    * NOT An AND #<DATA>  
    NOT   (A2) 
    NOT   (A3)+ 
    NOT   -(A4)
    NOT   $12 
    NOT   $1234 
    NOT   $44445555
***----------23. LSL----------------------------
    LSL.B   D0,D2
    lSR.B   #7,D4  ;  bad case for LSL
    LSL.B   #8,D4
    
    LSL.W   $0FF00000 ; 
    LSL.W   (a4)+
    LSL.W   -(a6)
    LSL.B   #3, D0
    LSL.B   #4, D1
    LSL.B   D4, D0
    
     
    LSL.W   #7,D1
    LSL.W   #6,D2
    LSL.W   D1, D0
    LSL.W   (A5)
    LSL.W   (A7)+
    LSL.W   -(A4)
    LSL.W   $9
    LSL.W   $19
    LSL.W   $191
    LSL.W   $1919
    LSL.W   $0FF00000
    LSL.W   $55555555  
    
    LSL.L   #8,D2
    LSL.L   #7,D6
    LSL.L   D3, D6
    LSL.L   D0,D2
**-----------------  LSR TEST GROUP 1110 -------------------
    LSR.B   #5, D0
    LSR.B   #7, D1
    LSR.B   D7, D3
    
     
    LSR.W   #2,D1
    LSR.W   #1,D2
    LSR.W   D6, D0
    LSR.W   (A1)
    LSR.W   (A3)+
    LSR.W   -(A4)
    LSR.W   $9
    LSR.W   $19
    LSR.W   $191
    LSR.W   $1919
    LSR.W   $0FF00000
    LSR.W   $55555555  
    
    LSR.L   #8,D2
    LSR.L   #7,D6
    LSR.L   D3, D6
    
    

**-----------------  ASL TEST GROUP 1110 -------------------
    ASL.B   #3, D0
    ASL.B   #4, D1
    ASL.B   D4, D0
    
     
    ASL.W   #7,D1
    ASL.W   #6,D2
    ASL.W   D1, D0
    ASL.W   (A5)
    ASL.W   (A7)+
    ASL.W   -(A4)
    ASL.W   $9
    ASL.W   $19
    ASL.W   $191
    ASL.W   $1919
    ASL.W   $0FF00000
    ASL.W   $55555555  
    
    ASL.L   #8,D2
    ASL.L   #7,D6
    ASL.W   D3, D6

***----------22. ASR----------------------------    
* ASR.B EA - EA IS NOT DN, AN, #<DATA>
* ASR.B #DATA, DN   
    ASR.B   #3, D0
    ASR.B   #4, D1
    
    ASR.W   $55555555   
    ASR.W   #7,D1
    ASR.W   #6,D2
    ASR.W   (A5)
    ASR.W   (A7)+
    ASR.W   -(A4)
    ASR.W   $9
    ASR.W   $19
    ASR.W   $191
    ASR.W   $1919
    ASR.W   $0FF00000
   
    ASR.L   #8,D2
    ASR.L   #7,D6

***-----------24. ROL-----------------
   
    ROL.B   D0,D2
    ROL.B   D6,D2
    ROL.B   #6,D0
    ROL.B   #7,D4  ;  bad case for LSL
    ROL.B   #8,D4
    
    ROL.W   D7, D3
    ROL.W   D6, D0  
    ROL.W   (A1)
    ROL.W   (4)
    ROL.W   (A1)+
    ROL.W   -(a6)
    ROL.W   (a4)+  
    ROL.W   #2,D1
    ROL.W   #1,D2   
    ROL.W   #5, D0
    ROL.W   #7, D1
    ROL.W   $0FF0
    ROL.W   $0FF0000 
    
    ROL.L   #8,D2
    ROL.L   #7,D6
    ROL.L   D3, D6


****----------10. BCC PASS---------------------- 
   CMP.B    D0,D2
   BCC      AAAA    
    
****----------11. BLE PASS---------------------  
AAAA 
    CMP.W    #1,D4
    BLE      BBBB
        
****----------12. BGT PASS----------------------
BBBB   
    CMP.B    $5, D4
    BGT      CCCC
CCCC  
    MOVEA.W   #4,A4
    
****----------13. BEQ PASS----------------------
    MOVE.B  #4,D4
    CMP.B   #4,D4
    BEQ     DDDD

****----------14. BRA PASS----------------------
DDDD
    BRA     EEEE
    
EEEE
    MOVE.B   #4,D4
    


 

**-----------------  ROR TEST GROUP 1110 -------------------
    ROR.B   #5, D0
    ROR.B   #7, D1
    ROR.B   D7, D3
    
     
    ROR.W   #2,D1
    ROR.W   #1,D2
    ROR.W   D6, D0
    ROR.W   (A1)
    ROR.W   (A3)+
    ROR.W   -(A4)
    ROR.W   $9
    ROR.W   $19
    ROR.W   $191
    ROR.W   $1919
    ROR.W   $0FF00000
    ROR.W   $55555555  
    
    ROR.L   #8,D2
    ROR.L   #7,D6
    ROR.L   D3, D6
            

   
***-------6. JRS-------------
    JSR      $0000
    JSR      $A000
    JSR      (A4)
    JSR     $1234
    JSR     (A1)
    JSR     (A2)
    JSR     (A3)
    JSR     (A4)
    JSR     (A5)
    JSR     JUMP1
    JSR     JUMP2
    JSR     (A1)        (An)
 
JUMP1    *For JSR & RTS test
   MOVE.B  D1, D1
   RTS

JUMP2   
    RTS *For JSR & RTS test  
    
****-------8. RTS-------------------
   JSR      $0000 
   JSR      $A000
   JSR      (A4)

    

      






    
    


    END    START        ; last line of source


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
