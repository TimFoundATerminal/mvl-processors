; Multiplication program for 6 × 7
LUI R0, 0    ; Initialize R0 to 0
LI R0, 6     ; Load 6 into R0
LUI R1, 0    ; Initialize R1 to 0
LI R1, 7     ; Load 7 into R1
LUI R2, 0    ; Initialize R2 (product) to 0
LUI R3, 0    ; Initialize R3 (counter) to 0

; Multiplication loop
ADD R2, R0    ; Add R0 to R2 (accumulate the product)
ADDI R3, 1    ; Increment counter
MV R4, R3     ; Copy into R4 to perform the compare
EQ R4, R1     ; Compare counter with multiplier
BNE R4, -4    ; If counter != multiplier, loop back 4 instructions

HALT            ;