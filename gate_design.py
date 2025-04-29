"""
Balanced Ternary Logic Gates Implementation
-------------------------------------------
This program defines both single-input (monadic) and two-input (dyadic) balanced ternary logic gates
and generates their truth tables.

Balanced ternary uses the values: -1 (negative), 0 (neutral), and +1 (positive).
These are often represented as -, 0, and + respectively.
"""

import numpy as np

# Define the balanced ternary values
NEG = -1  # Negative, often written as '-'
ZERO = 0  # Zero, written as '0'
POS = 1   # Positive, often written as '+'

# Define the trit values for iterations
TRIT_VALUES = [NEG, ZERO, POS]
TRIT_SYMBOLS = {NEG: "-", ZERO: "0", POS: "+"}

# Monadic (single-input) gates

def PTI(a):
    """
    Parallel Transformation Increasing (PTI) gate
    If input is negative, output is negative
    If input is zero, output is zero
    If input is positive, output is zero
    (Preserves negative, converts positive to zero)
    """
    if a < 0:
        return a
    else:
        return ZERO

def NTI(a):
    """
    Serial Transformation Increasing (STI) gate
    If input is negative, output is zero
    If input is zero, output is zero
    If input is positive, output is positive
    (Preserves positive, converts negative to zero)
    """
    if a > 0:
        return a
    else:
        return ZERO

def STI(a):
    """
    Negative Transformation Increasing (NTI) gate
    Returns the negation of the input
    """
    return -a

# Dyadic (two-input) gates

def NAND(a, b):
    """
    Ternary NAND gate
    Returns the negation of the minimum (AND) of the two inputs
    """
    return -min(a, b)

def NOR(a, b):
    """
    Ternary NOR gate
    Returns the negation of the maximum (OR) of the two inputs
    """
    return -max(a, b)

# def consensus(a, b):
#     """
#     Consensus gate
#     Returns + when both inputs are +, - when both inputs are -, 0 otherwise
#     """
#     if a == POS and b == POS:
#         return POS
#     elif a == NEG and b == NEG:
#         return NEG
#     else:
#         return ZERO

def OR(a, b):
    """
    Ternary OR gate (maximum)
    """
    return max(a, b)

def AND(a, b):
    """
    Ternary AND gate (minimum)
    """
    return min(a, b)

def generate_monadic_truth_table(gate_function):
    """
    Generates a truth table for a single-input gate function
    """
    # Create an array for the 3 possible inputs
    truth_table = np.zeros(3, dtype=int)
    
    # Fill the truth table
    for i, a in enumerate(TRIT_VALUES):
        truth_table[i] = gate_function(a)
    
    return truth_table

def generate_dyadic_truth_table(gate_function):
    """
    Generates a 3x3 truth table for a two-input gate function
    """
    # Create an empty 3x3 matrix
    truth_table = np.zeros((3, 3), dtype=int)
    
    # Fill the truth table
    for i, a in enumerate(TRIT_VALUES):
        for j, b in enumerate(TRIT_VALUES):
            truth_table[i, j] = gate_function(a, b)
    
    return truth_table

def print_monadic_truth_table(gate_name, truth_table):
    """
    Prints a formatted truth table for a single-input gate
    """
    print(f"\n{gate_name} Gate Truth Table (Monadic):")
    print("Input | Output")
    print("------+-------")
    
    for i, a in enumerate(TRIT_VALUES):
        result = truth_table[i]
        print(f"  {TRIT_SYMBOLS[a]}   |   {TRIT_SYMBOLS[result]}")

def print_dyadic_truth_table(gate_name, truth_table):
    """
    Prints a formatted truth table for a two-input gate
    """
    print(f"\n{gate_name} Gate Truth Table (Dyadic):")
    print("  | ", end="")
    for b in TRIT_VALUES:
        print(f"{TRIT_SYMBOLS[b]} ", end="")
    print("\n--+-------")
    
    for i, a in enumerate(TRIT_VALUES):
        print(f"{TRIT_SYMBOLS[a]} | ", end="")
        for j in range(3):
            result = truth_table[i, j]
            print(f"{TRIT_SYMBOLS[result]} ", end="")
        print()

def main():
    """
    Main function to generate and display truth tables for all gates
    """
    print("Balanced Ternary Logic Gates - Truth Tables")
    print("-------------------------------------------")
    
    # List of monadic gates to analyze
    monadic_gates = [
        ("PTI", PTI),
        ("STI", STI),
        ("NTI", NTI),
    ]
    
    # List of dyadic gates to analyze
    dyadic_gates = [
        ("NAND", NAND),
        ("NOR", NOR),
        ("Consensus", consensus_gate),
    ]
    
    # Generate and print truth tables for monadic gates
    print("\nMONADIC (SINGLE-INPUT) GATES:")
    for gate_name, gate_function in monadic_gates:
        truth_table = generate_monadic_truth_table(gate_function)
        print_monadic_truth_table(gate_name, truth_table)
    
    # Generate and print truth tables for dyadic gates
    print("\nDYADIC (TWO-INPUT) GATES:")
    for gate_name, gate_function in dyadic_gates:
        truth_table = generate_dyadic_truth_table(gate_function)
        print_dyadic_truth_table(gate_name, truth_table)

def consensus_gate(a, b):
    """ Consensus gate class to allow for dynamic gate creation """

    pos_a = PTI(a)
    pos_b = PTI(b)

    p_result = STI(NOR(pos_a, pos_b))
    n_result = STI(NAND(a, b))

    result = STI(NOR(p_result, n_result))

    return result

def any_gate(a, b):
    """ Consensus gate class to allow for dynamic gate creation """

    pos_a = PTI(a)
    pos_b = PTI(b)

    p_result = STI(NOR(pos_a, pos_b))
    n_result = STI(NAND(a, b))

    result = STI(NOR(p_result, n_result))

    return result

if __name__ == "__main__":
    main()