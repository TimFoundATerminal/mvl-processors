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