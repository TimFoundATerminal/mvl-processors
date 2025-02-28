; Multiplication program for 6 × 7
LUI R0, 00    ; Initialize R0 to 0
LI R0, 06     ; Load 6 into R0
LUI R1, 00    ; Initialize R1 to 0
LI R1, 07     ; Load 7 into R1
LUI R2, 00    ; Initialize R2 (product) to 0
LUI R3, 00    ; Initialize R3 (counter) to 0

; Multiplication loop
ADD R2, R0    ; Add R0 to R2 (accumulate the product)
ADDI R3, 01   ; Increment counter
MV R4, R3   ; Copy into R4 to perform the compare
COMP R4, R1   ; Compare counter with multiplier
BNE R4, 1, -5 ; If counter != multiplier, loop back 4 instructions

HALT          ; End program
LUI R5, ff    ; Initialize R0 to 256