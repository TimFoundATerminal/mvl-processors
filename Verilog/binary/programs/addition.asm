; Example program
LUI R0, 01    ; Load upper immediate 0x01 into R0
LI R0, 08     ; Load immediate 0x08 into lower byte of R0
LUI R1, 00    ; Load upper immediate 0x00 into R1
LI R1, 09     ; Load immediate 0x08 into lower byte of R1
MV R2, R0     ; Copy R0 to R2
ADD R2, R1    ; Add R2 to R0
HALT          ;