; Compare 3 values (8, 15, 15)
LUI R0, 00    ; Initialize R0 to 1
LI R0, 08     ; Load 0 into R0
LUI R1, 00    ; Initialize R1 to 0
LI R1, 0F     ; Load 7 into R1
LUI R2, 00    ; Initialize R2 to 1
LI R2, 0F     ; Initialize R2 to 1

; 2 Comparisons
MV R3, R0
COMP R3, R1   ; Compare R0 with R1
MV R4, R1
COMP R4, R2   ; Compare R1 with R2
HALT          ; End program