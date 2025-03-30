import argparse

_1 = 0b11 # -1 (2)
_0 = 0b00 # 0
_1_ = 0b01 # 1

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
            'SRI':   0b010111, # 14
            'SLI':   0b011100, # 15
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
                        imm_val = int(imm)
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
                        imm_val = int(imm)
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
                        imm_val = int(immediate)
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
        # Remove comments (everything after semicolon)
        line = line.split(';')[0].strip().replace(',', '')
        
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
            if instruction in ['MV', 'NOT', 'AND', 'OR', 'XOR', 'ADD', 'SUB', 'MULT', 'DIV', 'MOD', 'COMP']:
                reg_a, reg_b = self.parse_registers(tokens[1], tokens[2])
                return (opcode << 12) | (reg_a << 8) | (reg_b << 4)
                
            # I-type instructions with big immediate (4 trits)
            elif instruction in ['ANDI', 'ADDI', 'SRI', 'SLI', 'LUI', 'LI']:
                reg_a, imm = self.parse_register_big_immediate(tokens[1], tokens[2])
                return (opcode << 12) | (reg_a << 8) | imm
            
            # # I-type instructions with small immediate (2 trits)
            # elif instruction in []: # currently empty, but can be added later
            #     reg_a, small_imm = self.parse_register_small_immediate(tokens[1], tokens[2])
            #     return (opcode << 12) | (reg_a << 8) | (small_imm << 4)
            
            # Branch instructions
            elif instruction in ['BEQ', 'BNE']:
                reg_a, immediate = self.parse_branch_instruction(tokens[1], tokens[2])
                return (opcode << 12) | (reg_a << 8) | immediate
                
            # Memory instructions
            elif instruction in ['LOAD', 'STORE']:
                reg_a, reg_b, small_imm = self.parse_memory_instruction(tokens[1], tokens[2], tokens[3])
                return (opcode << 12) | (reg_a << 8) | (reg_b << 4) | small_imm
                
        except (IndexError, ValueError) as e:
            print(f"Error processing line '{line}': {str(e)}")
            return None

    def assemble(self, input_file, output_file):
        """Assemble input file to hex output."""
        try:
            with open(input_file, 'r') as f:
                for line in f:
                    instruction = self.parse_line(line)
                    if instruction is not None:
                        self.program_memory[self.instruction_count] = instruction
                        self.instruction_count += 1
                        
            # Write hex output (18-bit word size = 5 hex digits)
            with open(output_file, 'w') as f:
                for i in range(self.instruction_count):
                    f.write(f"{self.program_memory[i]:05x}\n")
                    
            print(f"Successfully assembled {self.instruction_count} instructions")
            
        except Exception as e:
            # print(f"Error during assembly: {str(e)}")
            raise e


def main():
    parser = argparse.ArgumentParser(description="Assembler for ternary ISA")

    # Add filepath arguments
    parser.add_argument("--filepath", type=str, default="program", help="Input assembly filepath")
    parser.add_argument("--output", type=str, default="program", help="Output hex filepath")

    args = parser.parse_args()
    args.filepath = "programs/" + args.filepath + ".asm"
    args.output = "programs/bin/" + args.output + ".hex"

    parser = TernaryInstructionParser()
    parser.assemble(args.filepath, args.output)


if __name__ == "__main__":
    main()