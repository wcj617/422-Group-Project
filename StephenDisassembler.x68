*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* RTS Test
    CMP.W     $0000,#$4E75
    
* JSR Test
* Test for JSR
    MOVE.W    $0000,D0
    MOVE.W    D0,D1
    ASR.W     #6,D1
    CMP.W     #$013A,D1
    
* Test for adressing mode
    MOVE.W    D0,D1
    MOVE.W    D0,D2
    EOR.W     #%1111111111000111,D2
    AND.W     D1,D2
    CMP.B     #$10,D2
    BEQ       IND
    CMP.B     #$38,D2
    BEQ       DIR
    
* Test for address reg number (stored in D2)
IND MOVE.W    D0,D1
    MOVE.W    D0,D2
    EOR.W     #%1111111111111000,D2
    AND.W     D1,D2
    
* Test for direct memory address modes
DIR ASR.W     #1,D0
    BCS       LONG
    BRA       WORD
        
* Either add to the string or get direct address from memory
    
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
