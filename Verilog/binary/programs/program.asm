; Example program
LUI R1, AA    ; Load upper immediate 0xAA00 into R1
LI R1, 55     ; Load immediate 0x55 into lower byte of R1
MV R2, R1     ; Copy R1 to R2
ADD R3, R2    ; Add R2 to R3
STORE R3, R1, 4   ; Store R3 at address R1+4
LOAD R4, R1, 4    ; Load from address R1+4 into R4
NOT R5, R4    ; Invert R4 into R5
COMP R5, R3   ; Compare R5 and R3