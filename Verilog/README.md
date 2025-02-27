# Ternary Encoding

```verilog
10 = Negative (-1)
00 = Zero (0)
01 = Positive (+1)
11 = Invalid (should not occur)
```

```verilog
parameter VPOS = 5.0;   // Positive voltage (+1)
parameter VZERO = 0.0;  // Zero voltage (0)
parameter VNEG = -5.0;  // Negative voltage (-1)

// Threshold voltages for state detection
parameter VTHRESH_POS = 2.5;   // Threshold for detecting positive
parameter VTHRESH_NEG = -2.5;  // Threshold for detecting negative

// Power supply rails
parameter VDD = 5.0;    // Positive supply
parameter VSS = -5.0;   // Negative supply
```

## RISC Instruction Set Plan

### Ternary

23 Instructions
3 trit opcode
6 trit operand
2 trit register address (8 registers total < 9)

| Num | Type | 9-trit instructions | Operation |
| --- | ---- | ------------------- | --------- |
| 0 | R | MV Ta,Tb | TRF[Ta] = TRF[Tb] |
| 1 | R | PTI Ta,Tb | TRF[Ta] = PTI(TRF[Tb]) |
| 2 | R | NTI Ta,Tb | TRF[Ta] = NTI(TRF[Tb]) |
| 3 | R | STI Ta,Tb | TRF[Ta] = STI(TRF[Tb]) |
| 4 | R | AND Ta,Tb | TRF[Ta] = TRF[Ta] & TRF[Tb] |
| 5 | R | OR Ta,Tb | TRF[Ta] = TRF[Ta]  TRF[Tb] |
| 6 | R | XOR Ta,Tb | TRF[Ta] = TRF[Ta] +o TRF[Tb] |
| 7 | R | ADD Ta,Tb | TRF[Ta] = TRF[Ta] + TRF[Tb] |
| 8 | R | SUB Ta,Tb | TRF[Ta] = TRF[Ta] - TRF[Tb] |
| 9 | R | SR Ta,Tb | TRF[Ta] = TRF[Ta] >> TRF[Tb][1:0] |
| 10 | R | SL Ta,Tb | TRF[Ta] = TRF[Ta] << TRF[Tb][1:0] |
| 11 | R | COMP Ta,Tb | TRF[Ta] = compare(TRF[Ta],TRF[Tb]) |
| 12 | I | ANDI Ta,imm | TRF[Ta] = TRF[Ta] & imm[2:0] |
| 13 | I | ADDI Ta,imm | TRF[Ta] = TRF[Ta] + imm[2:0] |
| 14 | I | SRI Ta,imm | TRF[Ta] = TRF[Ta] >> imm[1:0] |
| 15 | I | SLI Ta,imm | TRF[Ta] = TRF[Ta] << imm[1:0] |
| 16 | I | LUI Ta,imm | TRF[Ta] = {imm[3:0],00000} |
| 17 | I | LI Ta,imm | TRF[Ta] = {TRF[Ta][8:5],imm[4:0]} |
| 18 | B | BEQ Ta,B,imm | PC = PC + imm[3:0] if TRF[Ta][0] == B |
| 19 | B | BNE Ta,B,imm | PC = PC + imm[3:0] if TRF[Ta][0] != B |
| 20 | B | JAL Ta,imm | TRF[Ta] = PC+1, PC = PC + imm[4:0] |
| 21 | B | JALR Ta,Tb,imm | TRF[Ta] = PC+1, PC = PC + imm[4:0] |
| 22 | M | LOAD Ta,Tb,imm | TRF[Ta] = TDM[TRF[Tb]+imm[2:0]] | How is there space for opcode (3) + 2x Register Address (4) + Imm (3) within 9 trits?
| 23 | M | STORE Ta,Tb,imm | TDM[TRF[Tb]+imm[2:0]] = TRF[Ta] |

Decoding Patterns
- INS Ta,Tb
- INS Ta,Tb,imm
- INS Ta,imm
- INS Ta,B,imm

### Binary

$9ln3/ln2 = 14.25 2.s.f.$

Plan
- 5 bit opcode
- 3 bit register address (Ta,Tb)

- 11 bit operand

| Num | Type | 16-bit instructions | Operation |
| --- | ---- | ------------------- | --------- |
| 0  | R | MV Ta,Tb | TRF[Ta] = TRF[Tb] |
| 2  | R | NOT Ta,Tb | TRF[Ta] = NOT(TRF[Tb]) |
| 4  | R | AND Ta,Tb | TRF[Ta] = TRF[Ta] & TRF[Tb] |
| 5  | R | OR Ta,Tb | TRF[Ta] = TRF[Ta]  TRF[Tb] |
| 6  | R | XOR Ta,Tb | TRF[Ta] = TRF[Ta] +o TRF[Tb] |
| 7  | R | ADD Ta,Tb | TRF[Ta] = TRF[Ta] + TRF[Tb] |
| 8  | R | SUB Ta,Tb | TRF[Ta] = TRF[Ta] - TRF[Tb] |
| 11 | R | COMP Ta,Tb | TRF[Ta] = compare(TRF[Ta],TRF[Tb]) |
| 12 | I | ANDI Ta,imm | TRF[Ta] = TRF[Ta] & imm[4:0] |
| 13 | I | ADDI Ta,imm | TRF[Ta] = TRF[Ta] + imm[4:0] |
| 14 | I | SRI Ta,imm | TRF[Ta] = TRF[Ta] >> imm[3:1] |
| 15 | I | SLI Ta,imm | TRF[Ta] = TRF[Ta] << imm[3:1] |
| 16 | I | LUI Ta,imm | TRF[Ta] = {imm[7:0],00000000} |
| 17 | I | LI Ta,imm | TRF[Ta] = {TRF[Ta][15:8],imm[7:0]} |
| 18 | B | BEQ Ta,B,imm | PC = PC + imm[6:0] if TRF[Ta][0] == B |
| 19 | B | BNE Ta,B,imm | PC = PC + imm[6:0] if TRF[Ta][0] != B |
| 22 | M | LOAD Ta,Tb,imm | TRF[Ta] = TDM[TRF[Tb]+imm[4:0]] |
| 23 | M | STORE Ta,Tb,imm | TDM[TRF[Tb]+imm[4:0]] = TRF[Ta] |
<!-- | R | SR Ta,Tb | TRF[Ta] = TRF[Ta] >> TRF[Tb][1:0] |
| R | SL Ta,Tb | TRF[Ta] = TRF[Ta] << TRF[Tb][1:0] | -->


