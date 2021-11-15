*-----------------------------------------------------------
* Tiitle      : Hello World
* Written by : Josh Kweon
* Date       : 10/14/2021
* Description: Hello World
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
             LEA         MESSAGE, A1
             MOVE.B  #14, D0
             TRAP      #15
        
             MOVE.B  #9, D0
             TRAP      #15
        
CR         EQU       $0D
LF          EQU       $0A

MESSAGE DC.B    'HELLO WORLD', CR, LF
                 DC.B    'My name is Josh Kweon.', CR, LF
                 DC.B    'This is the test file for project.', CR, LF, CR, LF
                 DC.B    'Thank you for listening.', CR, LF, 0
 

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
