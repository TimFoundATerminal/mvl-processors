; Branch instruction test program
; Set up initial register values
LUI R0, 00    ;
LI R0, 01     ; R0 = 0x8000 (LSB = 1)
LUI R1, 00    ; R1 = 0x0000 (LSB = 0)

; Test BEQ with expected branches
BEQ R0, 1, 03    ; Should branch when MSB=1 and immediate[7]=1
LUI R2, FF       ; Should be skipped if branch works
LUI R4, 22       ; Should be executed after branch

BEQ R1, 0, 03    ; Should branch when MSB=0 and immediate[7]=0
LUI R3, EE       ; Should be skipped if branch works
LUI R5, 33       ; Should be executed after branch

; Test BEQ with expected non-branches
BEQ R0, 0, 03    ; Should NOT branch when MSB=1 and immediate[7]=0
LUI R6, 44       ; Should be executed
LUI R7, 55       ; Should be executed

BEQ R1, 1, 03    ; Should NOT branch when MSB=0 and immediate[7]=1
LUI R0, 66       ; Should be executed
LUI R1, 77       ; Should be executed

; Test BNE with expected branches
BNE R0, 0, 03    ; Should branch when MSB=1 and immediate[7]=0
LUI R2, 88       ; Should be skipped if branch works
LUI R3, 99       ; Should be executed after branch

BNE R1, 1, 03    ; Should branch when MSB=0 and immediate[7]=1
LUI R4, AA       ; Should be skipped if branch works
LUI R5, BB       ; Should be executed after branch

; Test BNE with expected non-branches
BNE R0, 1, 03    ; Should NOT branch when MSB=1 and immediate[7]=1
LUI R6, CC       ; Should be executed
LUI R7, DD       ; Should be executed

BNE R1, 0, 03    ; Should NOT branch when MSB=0 and immediate[7]=0
LUI R0, EE       ; Should be executed
LUI R1, FF       ; Should be executed

; Test backward branches
BEQ R0, 1, -6    ; Should branch backward when condition is true
BNE R1, 1, -6    ; Should branch backward when condition is true

HALT