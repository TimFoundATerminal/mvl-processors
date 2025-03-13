import argparse


def input_to_hex(string):
    """Convert a hex string to binary."""
    if string.startswith('0x'):
        return string[2:]
    # Convert decimal to hex
    return hex(int(string))[2:]


def decimal_to_7bit_signed(decimal):
    """Convert a decimal number to 7-bit signed binary."""
    if not (-64 <= decimal <= 63):
        raise ValueError("Value must be in range [-64, 63] for 7-bit signed representation")
        
    if decimal < 0:
        # Perform two's complement by adding 128 which
        decimal = decimal + (1 << 7)
    return decimal


class InstructionParser:
    def __init__(self):
        # Program memory to store instructions (256 16-bit words)
        self.program_memory = [0] * 256
        self.instruction_count = 0
        
        # Instruction opcodes
        self.instructions = {
            'MV':    0b00000, # 0
            'NOT':   0b00010, # 2
            'AND':   0b00100, # 4
            'OR':    0b00101, # 5
            'XOR':   0b00110, # 6
            'ADD':   0b00111, # 7
            'SUB':   0b01000, # 8
            'COMP':  0b01011, # 11
            'ANDI':  0b01100, # 12
            'ADDI':  0b01101, # 13
            'SRI':   0b01110, # 14
            'SLI':   0b01111, # 15
            'LUI':   0b10000, # 16
            'LI':    0b10001, # 17
            'BEQ':   0b10010, # 18
            'BNE':   0b10011, # 19
            'LOAD':  0b10110, # 22
            'STORE': 0b10111, # 23
            'HALT':  0b11111  # 31
        }

    def parse_registers(self, reg1, reg2):
        """Parse register numbers from R format strings."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            r2_num = int(reg2.strip()[1:])  # Remove 'R' and convert to int
            
            if not (0 <= r1_num <= 7 and 0 <= r2_num <= 7):
                raise ValueError("Register numbers must be between 0 and 7")
                
            return r1_num, r2_num
        except:
            raise ValueError(f"Invalid register format: {reg1}, {reg2}")

    def parse_register_immediate(self, reg1, imm):
        """Parse register and immediate value."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            
            # Handle hex values prefixed with 0x or not
            if isinstance(imm, str):
                if imm.startswith('0x'):
                    imm_val = int(imm, 16)
                else:
                    imm_val = int(imm, 16)
            else:
                imm_val = int(imm)
                
            if not (0 <= r1_num <= 7):
                raise ValueError("Register numbers must be between 0 and 7")
            if not (0 <= imm_val <= 255):
                raise ValueError("Immediate value must be between 0 and 255")
                
            return r1_num, imm_val
        except ValueError as e:
            raise e
        except Exception as e:
            raise ValueError(f"Invalid register/immediate format: {reg1}, {imm}")
        
    def parse_register_neg_immediate(self, reg1, imm):
        """Parse register and immediate value."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            
            # Handle hex values prefixed with 0x or not
            if isinstance(imm, str):
                if imm.startswith('0x'):
                    imm_val = int(imm, 16)
                else:
                    imm_val = int(imm, 16)
            else:
                imm_val = int(imm)
                
            if not (0 <= r1_num <= 7):
                raise ValueError("Register numbers must be between 0 and 7")
            if not (-128 <= imm_val <= 127):
                raise ValueError("Immediate value must be between 0 and 255")
            
            # If negative, convert to 8-bit signed by adding 2**7
            if imm_val < 0:
                imm_val = imm_val + (1 << 8)
                
            return r1_num, imm_val
        except ValueError as e:
            raise e
        except Exception as e:
            raise ValueError(f"Invalid register/immediate format: {reg1}, {imm}")

    def parse_memory_instruction(self, reg1, reg2, offset):
        """Parse memory instruction format (register, register, offset)."""
        try:
            r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
            r2_num = int(reg2.strip()[1:])  # Remove 'R' and convert to int
            offset = int(offset.strip())
            
            if not (0 <= r1_num <= 7 and 0 <= r2_num <= 7):
                raise ValueError("Register numbers must be between 0 and 7")
            if not (0 <= offset <= 31):
                raise ValueError("Offset must be between 0 and 31")
                
            return r1_num, r2_num, offset
        except:
            raise ValueError(f"Invalid memory instruction format: {reg1}, {reg2}, {offset}")
        
    # def parse_branch_instruction(self, reg1, b, immediate):
    #     """Parse branch instruction format (register, immediate)."""
    #     try:
    #         r1_num = int(reg1.strip()[1:])  # Remove 'R' and convert to int
    #         b_val = int(b.strip())
    #         imm_val = int(immediate.strip())
                
    #         if not (0 <= r1_num <= 7):
    #             raise ValueError("Register numbers must be between 0 and 7")
    #         if not (0 <= b_val <= 1):
    #             raise ValueError("Branch value must be 0 or 1")
    #         if not (-64 <= imm_val <= 63):
    #             raise ValueError("Immediate value must be between -64 and 63")
                
    #         return r1_num, b_val, decimal_to_7bit_signed(imm_val)
        
    #     except ValueError as e:
    #         raise e
    #     except:
    #         raise ValueError(f"Invalid branch instruction format: {reg1}, {b}, {immediate}")

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

            # Halt instruction
            if instruction == 'HALT':
                return (opcode << 11)
            
            # R-type instructions
            if instruction in ['MV', 'NOT', 'AND', 'OR', 'XOR', 'ADD', 'SUB', 'COMP']:
                reg_a, reg_b = self.parse_registers(tokens[1], tokens[2])
                return (opcode << 11) | (reg_a << 8) | (reg_b << 5)
                
            # I-type instructions
            elif instruction in ['ANDI', 'ADDI', 'SRI', 'SLI', 'LUI', 'LI']:
                reg_a, imm = self.parse_register_immediate(tokens[1], tokens[2])
                return (opcode << 11) | (reg_a << 8) | imm
            
            # Negative I-type instructions
            elif instruction in ['BEQ', 'BNE']:
                reg_a, imm = self.parse_register_neg_immediate(tokens[1], tokens[2])
                return (opcode << 11) | (reg_a << 8) | imm
            
            # # Branch instructions
            # elif instruction in ['BEQ', 'BNE']:
            #     reg_a, b, immediate = self.parse_branch_instruction(tokens[1], tokens[2], tokens[3])
            #     return (opcode << 11) | (reg_a << 8) | (b << 7) | immediate
                
            # M-type instructions
            elif instruction in ['LOAD', 'STORE']:
                reg_a, reg_b, offset = self.parse_memory_instruction(tokens[1], tokens[2], tokens[3])
                return (opcode << 11) | (reg_a << 8) | (reg_b << 5) | offset
                
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
                        
            # Write hex output
            with open(output_file, 'w') as f:
                for i in range(self.instruction_count):
                    f.write(f"{self.program_memory[i]:04x}\n")
                    
            print(f"Successfully assembled {self.instruction_count} instructions")
            
        except Exception as e:
            print(f"Error during assembly: {str(e)}")


def main():
    parser = argparse.ArgumentParser(description="Assembler for custom ISA")

    # Add filepath arguments
    parser.add_argument("--filepath", type=str, default="program", help="Input assembly filepath")
    parser.add_argument("--output", type=str, default="program", help="Output hex filepath")

    args = parser.parse_args()
    args.filepath = "programs/" + args.filepath + ".asm"
    args.output = "programs/bin/" + args.output + ".hex"

    parser = InstructionParser()
    parser.assemble(args.filepath, args.output)


if __name__ == "__main__":
    main()