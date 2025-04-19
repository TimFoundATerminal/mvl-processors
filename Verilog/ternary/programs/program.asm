; Example program
LUI R0, 1    ; Load upper immediate 0x01 into R0
LI R0, 8     ; Load immediate 0x08 into lower byte of R0
LUI R1, 1    ; Load upper immediate 0x01 into R0
LI R1, 8    ; Load immediate 0x08 into lower byte of R0

MV R2, R1     ;

AND R2, R0    ; Increment Register 0

MV R3, R2     ;

ADD R3, R1    ;

HALT          ;