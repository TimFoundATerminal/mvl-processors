; Initialize memory addresses for matrices
LI R1, 100      ; Matrix A starts at memory address 100
LI R2, 104       ; Matrix B starts at memory address 104
LI R3, 108       ; Matrix C starts at memory address 108
LI R7, 1        ; Set constant 1 for iteration

; Load Matrices into memory
LI R0, 2            ;
STORE R0, R1, 0     ;
LI R0, 3            ;
STORE R0, R2, 0     ;
;STORE R0, R1, 2     ;
;STORE R0, R1, 3     ;

; Calculate c00 = a00×b00 + a01×b10
LOAD R4, R1, 0      ; R4 = a00
LI R6, 12           ;

HALT;
;;;
LOAD R5, R2, 0      ; R5 = b00

LI R0, 3        ;
STORE R0, R2, 0 ;
STORE R0, R2, 1 ;
STORE R0, R2, 2 ;
STORE R0, R2, 3 ;

LI R0, 0            ; Clear accumulator for multiplication

; Multiply R4 × R5 (a00 x b00)
MULT_1:
    MV R6, R4           ; Copy multiplier to R6
    MULT_LOOP_1:
        EQ R0, R6, R0   ; Check if multiplier is zero
        BEQ R0, MULT_END_1  ; If zero, exit multiplication
        ADD R0, R0, R5  ; Add multiplicand to result
        SUB R6, R6, R7  ; Decrement multiplier
        BNE R0, MULT_LOOP_1 ; Loop if not zero
MULT_END_1:

; Store intermediate result
MV R6, R0          ; Save a00×b00 to R6

; Calculate a01×b10
LOAD R4, R1, 1      ; R4 = a01
LOAD R5, R2, 2      ; R5 = b10
LI R0, 0            ; Clear accumulator

; Multiply R4 × R5 (a01 × b10)
MULT_2:
    MV R4, R6           ; Copy multiplier to R4
    MULT_LOOP_2:
        EQ R0, R4, R0   ; Check if multiplier is zero
        BEQ R0, MULT_END_2  ; If zero, exit multiplication
        ADD R0, R0, R5  ; Add multiplicand to result
        SUB R4, R4, R7  ; Decrement multiplier
        BNE R0, MULT_LOOP_2 ; Loop if not zero
MULT_END_2:

; Complete c00 calculation
ADD R0, R6, R0      ; R0 = a00×b00 + a01×b10
STORE R0, R3, 0     ; Store c00 to result matrix

HALT                ; End program