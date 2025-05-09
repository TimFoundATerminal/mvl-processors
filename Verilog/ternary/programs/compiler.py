import argparse

_1 = 0b11 # -1 (2)
_0 = 0b00 # 0
_1_ = 0b01 # 1


# Helper function
def int_to_balanced_ternary_to_binary(value):
    """
    Convert an integer to balanced ternary representation, then interpret
    that representation as binary and convert back to an integer.
    
    Balanced ternary bit encoding:
    -1 = 0b11 (_1)
    0 = 0b00 (_0)
    1 = 0b01 (_1_)
    """
    if value == 0:
        # return {
        #     "original_value": 0,
        #     "balanced_ternary_trits": [0b00],
        #     "balanced_ternary_formatted": ["_0"],
        #     "binary_representation": "00",
        #     "binary_value": 0
        # }
        return 0
    
    # Define the ternary digit encodings
    trit_encodings = {
        -1: _1, 
        0: _0,
        1: _1_ 
    }
    
    trit_names = {
        0b11: "_1",   # -1
        0b00: "_0",   # 0
        0b01: "_1_"   # 1
    }
    
    # Convert to balanced ternary
    trits = []
    
    # Handle negative values by taking the absolute value and negating each trit at the end
    is_negative = value < 0
    abs_value = abs(value)
    
    while abs_value > 0:
        remainder = abs_value % 3
        
        if remainder == 2:
            # In balanced ternary, 2 is represented as -1 in the next position
            trit = -1
            abs_value = (abs_value + 1) // 3
        else:
            trit = remainder
            abs_value = abs_value // 3
        
        # If the original value was negative, negate the trit
        if is_negative:
            trit = -trit
            
        trits.append(trit_encodings[trit])
    
    # Reverse the list since we built it from least to most significant
    trits.reverse()
    
    # Format the trits for display
    formatted_trits = [trit_names[trit] for trit in trits]
    
    # Convert the binary representation to an integer
    binary_string = ''.join([f"{trit:02b}" for trit in trits])
    binary_value = int(binary_string, 2)
    
    # return {
    #     "original_value": value,
    #     "balanced_ternary_trits": trits,
    #     "balanced_ternary_formatted": formatted_trits,
    #     "binary_representation": binary_string,
    #     "binary_value": binary_value
    # }
    return binary_value


class TernaryInstructionParser:
    def __init__(self):
        # Program memory to store instructions (256 18-bit words)
        self.program_memory = [0] * 256
        self.instruction_count = 0
        
        # Instruction opcodes (3 trits = 6 bits)
        # Using decimal values that correspond to 3 trits
        self.instructions = {
            'MV':    0b000000, # 0
            'NOT':   0b000011, # 2 
            'AND':   0b000101, # 4
            'OR':    0b000111, # 5
            'XOR':   0b001100, # 6
            'ADD':   0b001101, # 7
            'SUB':   0b001111, # 8
            'COMP':  0b010011, # 11
            'ANDI':  0b010100, # 12
            'ADDI':  0b010101, # 13
            'LT':    0b010111, # 14
            'EQ':    0b011100, # 15
            'LUI':   0b011101, # 16
            'LI':    0b011111, # 17
            'BEQ':   0b110000, # 18
            'BNE':   0b110001, # 19
            'LOAD':  0b110101, # 22
            'STORE': 0b110111, # 23
            'HALT':  0b111111  # 26
        }
    
    def decimal_to_ternary(self, decimal, num_trits):
        """Convert decimal to ternary representation with specified number of trits."""
        if decimal < 0:
            # For negative numbers in balanced ternary
            max_val = 3**num_trits // 2
            if abs(decimal) > max_val:
                raise ValueError(f"Value {decimal} too large for {num_trits} trits")
            # Convert to binary representation with the specified bit width (2 bits per trit)
            return decimal & ((1 << (num_trits * 2)) - 1)
        else:
            # For positive numbers
            max_val = 3**num_trits - 1
            if decimal > max_val:
                raise ValueError(f"Value {decimal} too large for {num_trits} trits")
            # Convert to binary representation with the specified bit width (2 bits per trit)
            return decimal & ((1 << (num_trits * 2)) - 1)

    def parse_registers(self, reg1, reg2):
        """Parse register numbers from R format strings."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            r2_num = int(reg2.strip()[1:])  # Remove 'R' and convert to int
            
            # Ternary CPU registers are 2 trits (can represent up to 9 registers)
            if not (0 <= r1_num <= 8 and 0 <= r2_num <= 8):
                raise ValueError("Register numbers must be between 0 and 8")
                
            return r1_num, r2_num
        except Exception as e:
            raise ValueError(f"Invalid register format: {reg1}, {reg2}: {str(e)}")

    def parse_register_big_immediate(self, reg1, imm):
        """Parse register and big immediate value (4 trits = 8 bits)."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            
            # Handle hex values prefixed with 0x or not
            if isinstance(imm, str):
                if imm.startswith('0x'):
                    imm_val = int(imm, 16)
                else:
                    try:
                        imm_val = int_to_balanced_ternary_to_binary(int(imm))
                    except ValueError:
                        imm_val = int(imm, 16)
            else:
                imm_val = int(imm)
                
            if not (0 <= r1_num <= 8):
                raise ValueError("Register numbers must be between 0 and 8")
            
            # 4 trits can represent values 0 to 80 (3^4 - 1)
            if not (-40 <= imm_val <= 40):
                raise ValueError("Big immediate value must be between -40 and 40")
                
            # Convert to appropriate binary representation
            imm_binary = self.decimal_to_ternary(imm_val, 4)
                
            return r1_num, imm_binary
        except ValueError as e:
            raise e
        except Exception as e:
            raise ValueError(f"Invalid register/immediate format: {reg1}, {imm}: {str(e)}")
        
    def parse_register_small_immediate(self, reg1, imm):
        """Parse register and small immediate value (2 trits = 4 bits)."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            
            # Handle hex values prefixed with 0x or not
            if isinstance(imm, str):
                if imm.startswith('0x'):
                    imm_val = int(imm, 16)
                else:
                    try:
                        imm_val = int_to_balanced_ternary_to_binary(int(imm))
                    except ValueError:
                        imm_val = int(imm, 16)
            else:
                imm_val = int(imm)
                
            if not (0 <= r1_num <= 8):
                raise ValueError("Register numbers must be between 0 and 8")
            
            # 2 trits can represent values -4 to 4 (balanced ternary)
            if not (-4 <= imm_val <= 4):
                raise ValueError("Small immediate value must be between -4 and 4")
                
            # Convert to appropriate binary representation
            imm_binary = self.decimal_to_ternary(imm_val, 2)
                
            return r1_num, imm_binary
        except ValueError as e:
            raise e
        except Exception as e:
            raise ValueError(f"Invalid register/immediate format: {reg1}, {imm}: {str(e)}")

    def parse_memory_instruction(self, reg1, reg2, offset):
        """Parse memory instruction format (register, register, offset)."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            r2_num = int(reg2.strip()[1:])  # Remove 'R' and convert to int
            
            # Handle offset as a small immediate
            if isinstance(offset, str):
                if offset.startswith('0x'):
                    offset_val = int(offset, 16)
                else:
                    try:
                        offset_val = int(offset)
                    except ValueError:
                        offset_val = int(offset, 16)
            else:
                offset_val = int(offset)
            
            if not (0 <= r1_num <= 8 and 0 <= r2_num <= 8):
                raise ValueError("Register numbers must be between 0 and 8")
            
            # 2 trits can represent values -4 to 4
            if not (-4 <= offset_val <= 4):
                raise ValueError("Offset must be between -4 and 4")
                
            # Convert to appropriate binary representation
            offset_binary = self.decimal_to_ternary(offset_val, 2)
                
            return r1_num, r2_num, offset_binary
        except Exception as e:
            raise ValueError(f"Invalid memory instruction format: {reg1}, {reg2}, {offset}: {str(e)}")

    def parse_branch_instruction(self, reg1, immediate):
        """Parse branch instruction format (register, immediate)."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            
            # Handle immediate as a big immediate
            if isinstance(immediate, str):
                if immediate.startswith('0x'):
                    imm_val = int(immediate, 16)
                else:
                    try:
                        imm_val = int_to_balanced_ternary_to_binary(int(immediate))
                    except ValueError:
                        imm_val = int(immediate, 16)
            else:
                imm_val = int(immediate)
                
            if not (0 <= r1_num <= 8):
                raise ValueError("Register numbers must be between 0 and 8")
            
            # 4 trits can represent values -40 to 40
            if not (-40 <= imm_val <= 40):
                raise ValueError("Branch offset must be between -40 and 40")
                
            # Convert to appropriate binary representation
            imm_binary = self.decimal_to_ternary(imm_val, 4)
                
            return r1_num, imm_binary
        except ValueError as e:
            raise e
        except Exception as e:
            raise ValueError(f"Invalid branch instruction format: {reg1}, {immediate}: {str(e)}")

    def parse_line(self, line):
        """Parse a single line of assembly."""

        # Check if the line is 3 semicolons (end of file)
        if line.strip() == ';;;':
            return ";;;"

        # Remove comments (everything after semicolon)
        line = line.split(';')[0].strip().replace(',', '')
        
        # Ignore lines that are empty before the semicolon
        if not line:
            return None
            
        # Split line into tokens
        tokens = line.split()
        if not tokens:
            return None
            
        instruction = tokens[0].upper()
        
        try:
            if instruction not in self.instructions:
                raise ValueError(f"Unknown instruction: {instruction}")
                
            opcode = self.instructions[instruction]

            # Halt instruction (no operands)
            if instruction == 'HALT':
                return (opcode << 12)  # 6 bits shifted left by 12 bits
            
            # R-type instructions (register-register operations)
            if instruction in ['MV', 'NOT', 'AND', 'OR', 'XOR', 'ADD', 'SUB', 'COMP', 'LT', 'EQ']:
                reg_a, reg_b = self.parse_registers(tokens[1], tokens[2])
                return (opcode << 12) | (reg_a << 8) | (reg_b << 4)
                
            # I-type instructions with big immediate (4 trits)
            if instruction in ['ANDI', 'ADDI', 'SRI', 'SLI', 'LUI', 'LI']:
                reg_a, imm = self.parse_register_big_immediate(tokens[1], tokens[2])
                return (opcode << 12) | (reg_a << 8) | imm
            
            # Branch instructions
            if instruction in ['BEQ', 'BNE']:
                reg_a, immediate = self.parse_branch_instruction(tokens[1], tokens[2])
                return (opcode << 12) | (reg_a << 8) | immediate
                
            # Memory instructions
            if instruction in ['LOAD', 'STORE']:
                reg_a, reg_b, small_imm = self.parse_memory_instruction(tokens[1], tokens[2], tokens[3])
                return (opcode << 12) | (reg_a << 8) | (reg_b << 4) | small_imm
                
        except (IndexError, ValueError) as e:
            print(f"Error processing line '{line}': {str(e)}")
            return None
        
        return None

    def assemble(self, input_file, output_file):
        """Assemble input file to hex output."""
        try:
            with open(input_file, 'r') as f:
                for line in f:
                    instruction = self.parse_line(line)
                    if instruction == ";;;":
                        break
                    elif instruction is not None:
                        self.program_memory[self.instruction_count] = instruction
                        self.instruction_count += 1
                        
            # Write hex output (18-bit word size = 5 hex digits)
            with open(output_file, 'w') as f:
                for i in range(self.instruction_count):
                    f.write(f"{self.program_memory[i]:05x}\n")
                    
            print(f"Successfully assembled {self.instruction_count} ternary instructions")
            
        except Exception as e:
            # print(f"Error during assembly: {str(e)}")
            raise e


def main():
    parser = argparse.ArgumentParser(description="Assembler for ternary ISA")

    # Add filepath arguments
    parser.add_argument("--file", type=str, default="program", help="Input assembly file")
    parser.add_argument("--filepath", type=str, default=None, help="Input assembly filepath")
    parser.add_argument("--output", type=str, default="programs/bin/program.hex", help="Output hex filepath")

    args = parser.parse_args()
    if args.filepath is None:
        args.filepath = "programs/" + args.file + ".asm"

    parser = TernaryInstructionParser()
    parser.assemble(args.filepath, args.output)


def test():
    for test_value in [0, 10, -10, 42, -42]:
        result = int_to_balanced_ternary_to_binary(test_value)
        print(f"Original: {result['original_value']}")
        print(f"Balanced ternary: {result['balanced_ternary_formatted']}")
        print(f"Binary representation: {result['binary_representation']}")
        print(f"Binary value: {result['binary_value']}")
        print()

if __name__ == "__main__":
    main()
    # test()