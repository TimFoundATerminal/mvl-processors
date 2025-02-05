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
2 trit register (8 registers total)

| Type | 9-trit instructions | Operation |
| ---- | ------------------- | --------- |
| R | MV Ta,Tb | TRF[Ta] = TRF[Tb] |
| R | PTI Ta,Tb | TRF[Ta] = PTI(TRF[Tb]) |
| R | NTI Ta,Tb | TRF[Ta] = NTI(TRF[Tb]) |
| R | STI Ta,Tb | TRF[Ta] = STI(TRF[Tb]) |
| R | AND Ta,Tb | TRF[Ta] = TRF[Ta] & TRF[Tb] |
| R | OR Ta,Tb | TRF[Ta] = TRF[Ta]  TRF[Tb] |
| R | XOR Ta,Tb | TRF[Ta] = TRF[Ta] +o TRF[Tb] |
| R | ADD Ta,Tb | TRF[Ta] = TRF[Ta] + TRF[Tb] |
| R | SUB Ta,Tb | TRF[Ta] = TRF[Ta] - TRF[Tb] |
| R | SR Ta,Tb | TRF[Ta] = TRF[Ta] >> TRF[Tb][1:0] |
| R | SL Ta,Tb | TRF[Ta] = TRF[Ta] << TRF[Tb][1:0] |
| R | COMP Ta,Tb | TRF[Ta] = compare(TRF[Ta],TRF[Tb]) |
| I | ANDI Ta,imm | TRF[Ta] = TRF[Ta] & imm[2:0] |
| I | ADDI Ta,imm | TRF[Ta] = TRF[Ta] + imm[2:0] |
| I | SRI Ta,imm | TRF[Ta] = TRF[Ta] >> imm[1:0] |
| I | SLI Ta,imm | TRF[Ta] = TRF[Ta] << imm[1:0] |
| I | LUI Ta,imm | TRF[Ta] = {imm[3:0],00000} |
| I | LI Ta,imm | TRF[Ta] = {TRF[Ta][8:5],imm[4:0]} |
| B | BEQ Ta,B,imm | PC = PC + imm[3:0] if TRF[Ta][0] == B |
| B | BNE Ta,B,imm | PC = PC + imm[3:0] if TRF[Ta][0] != B |
| B | JAL Ta,imm | TRF[Ta] = PC+1, PC = PC + imm[4:0] |
| B | JALR Ta,Tb,imm | TRF[Ta] = PC+1, PC = PC + imm[4:0] |
| M | LOAD Ta,Tb,imm | TRF[Ta] = TDM[TRF[Tb]+imm[2:0]] |
| M | STORE Ta,Tb,imm | TDM[TRF[Tb]+imm[2:0]] = TRF[Ta] |

Decoding Patterns
- INS Ta,Tb
- INS Ta,Tb,imm
- INS Ta,imm
- INS Ta,B,imm

### Binary

$9ln3/ln2 = 14.25 2.s.f.$

Plan
- 5 bit opcode
- 3 bit register (Ta,Tb)

- 10 bit operand

| Type | 15-bit instructions | Operation |
| ---- | ------------------- | --------- |
| R | MV Ta,Tb | TRF[Ta] = TRF[Tb] |
| R | NOT Ta,Tb | TRF[Ta] = NOT(TRF[Tb]) |
| R | AND Ta,Tb | TRF[Ta] = TRF[Ta] & TRF[Tb] |
| R | OR Ta,Tb | TRF[Ta] = TRF[Ta]  TRF[Tb] |
| R | XOR Ta,Tb | TRF[Ta] = TRF[Ta] +o TRF[Tb] |
| R | ADD Ta,Tb | TRF[Ta] = TRF[Ta] + TRF[Tb] |
| R | SUB Ta,Tb | TRF[Ta] = TRF[Ta] - TRF[Tb] |
| R | COMP Ta,Tb | TRF[Ta] = compare(TRF[Ta],TRF[Tb]) |
| I | LUI Ta,imm | TRF[Ta] = {imm[3:0],00000} |
| I | LI Ta,imm | TRF[Ta] = {TRF[Ta][8:5],imm[4:0]} |
<!-- | R | SR Ta,Tb | TRF[Ta] = TRF[Ta] >> TRF[Tb][1:0] |
| R | SL Ta,Tb | TRF[Ta] = TRF[Ta] << TRF[Tb][1:0] | -->
<!-- | I | ANDI Ta,imm | TRF[Ta] = TRF[Ta] & imm[2:0] |
| I | ADDI Ta,imm | TRF[Ta] = TRF[Ta] + imm[2:0] |
| I | SRI Ta,imm | TRF[Ta] = TRF[Ta] >> imm[1:0] |
| I | SLI Ta,imm | TRF[Ta] = TRF[Ta] << imm[1:0] | -->


