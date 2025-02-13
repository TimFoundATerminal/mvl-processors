module instruction_parser;
    // File handling variables
    integer file;
    integer scan_file;
    integer tokens;
    reg [100*8-1:0] line;
    reg [100*8-1:0] trimmed_line;
    reg [15:0] program_memory [0:255];
    
    // Parsing variables
    integer instruction_count;
    integer i;
    reg [15:0] current_instruction;
    reg [31:0] parse_temp;
    reg [4:0] opcode;
    reg [2:0] reg_a, reg_b;
    reg [7:0] immediate;
    reg [4:0] shift;
    
    // String handling helpers
    reg [31:0] str1, str2, str3;
    reg [4:0] num1, num2, num3;
    
    initial begin
        file = $fopen("programs/program.asm", "r");
        if (file == 0) begin
            $display("Error: Could not open program.asm");
            $finish;
        end
        
        instruction_count = 0;
        
        while (!$feof(file)) begin
            scan_file = $fgets(line, file);
            
            // Initialize trimmed line
            trimmed_line = "";
            
            // Find first semicolon and copy up to that point
            for (i = 100; i > 0; i = i - 1) begin
                if (line[i*8 +: 8] == ";") begin
                    i = 0;
                end
                trimmed_line[i*8 +: 8] = line[i*8 +: 8];
            end
            
            $display("Line: %s", trimmed_line);
            $display("Line[0]: %s", trimmed_line[7:0]);
            if (trimmed_line[7:0] != ";" && trimmed_line[7:0] != "\n" && trimmed_line[7:0] != 0) begin
                parse_instruction(trimmed_line);
                instruction_count = instruction_count + 1;
            end
        end
        
        $fclose(file);
        
        // Write machine code to output file
        write_machine_code();
    end
    
    task parse_instruction;
        input [100*8-1:0] asm_line;
        
        begin
            tokens = $sscanf(asm_line, "%s %s %s", str1, str2, str3);
            $display("%s %s %s", str1, str2, str3);
            
            case (str1)
                // R-type instructions
                "MV": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b00000, reg_a, reg_b, 5'b0};
                end
                
                "NOT": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b00010, reg_a, reg_b, 5'b0};
                end
                
                "AND": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b00100, reg_a, reg_b, 5'b0};
                end
                
                "OR": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b00101, reg_a, reg_b, 5'b0};
                end
                
                "XOR": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b00110, reg_a, reg_b, 5'b0};
                end
                
                "ADD": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b00111, reg_a, reg_b, 5'b0};
                end
                
                "SUB": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b01000, reg_a, reg_b, 5'b0};
                end
                
                "COMP": begin
                    parse_registers(str2, str3);
                    program_memory[instruction_count] = {5'b01011, reg_a, reg_b, 5'b0};
                end
                
                // I-type instructions
                "LUI": begin
                    parse_register_immediate(str2, str3);
                    program_memory[instruction_count] = {5'b10000, reg_a, immediate};
                end
                
                "LI": begin
                    parse_register_immediate(str2, str3);
                    program_memory[instruction_count] = {5'b10001, reg_a, immediate};
                end
                
                // M-type instructions
                "LOAD": begin
                    parse_memory_instruction(str2, str3);
                    program_memory[instruction_count] = {5'b10110, reg_a, reg_b, shift};
                end
                
                "STORE": begin
                    parse_memory_instruction(str2, str3);
                    program_memory[instruction_count] = {5'b10111, reg_a, reg_b, shift};
                end
                
                default: begin
                    $display("Error: Unknown instruction '%s'", str1);
                    $finish;
                end
            endcase
        end
    endtask
    
    task parse_registers;
        input [31:0] reg1, reg2;
        reg [3:0] r1_num, r2_num;
        begin
            if ($sscanf(reg1, "R%d", r1_num) != 1 || $sscanf(reg2, "R%d", r2_num) != 1) begin
                $display("Error: Invalid register format");
                $finish;
            end
            reg_a = r1_num[2:0];
            reg_b = r2_num[2:0];
        end
    endtask
    
    task parse_register_immediate;
        input [31:0] reg1, imm;
        reg [3:0] r1_num;
        reg [7:0] imm_val;
        begin
            if ($sscanf(reg1, "R%d", r1_num) != 1) begin
                $display("Error: Invalid register format");
                $finish;
            end
            if ($sscanf(imm, "%h", imm_val) != 1) begin
                $display("Error: Invalid immediate value");
                $finish;
            end
            reg_a = r1_num[2:0];
            immediate = imm_val;
        end
    endtask
    
    task parse_memory_instruction;
        input [31:0] reg1, reg2;
        reg [3:0] r1_num, r2_num;
        reg [4:0] offset;
        begin
            if ($sscanf(reg1, "R%d", r1_num) != 1 || $sscanf(reg2, "R%d,%d", r2_num, offset) != 2) begin
                $display("Error: Invalid memory instruction format");
                $finish;
            end
            reg_a = r1_num[2:0];
            reg_b = r2_num[2:0];
            shift = offset[3:0];
        end
    endtask
    
    task write_machine_code;
        integer out_file;
        integer i;
        begin
            out_file = $fopen("programs/program.hex", "w");
            if (out_file == 0) begin
                $display("Error: Could not open output file");
                $finish;
            end
            
            $display("%d", instruction_count);
            for (i = 0; i < instruction_count; i = i + 1) begin
                $display("%h", program_memory[i]);
                $fdisplay(out_file, "%h", program_memory[i]);
            end
            
            $fclose(out_file);
        end
    endtask
    
endmodule