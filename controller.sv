
module controller (
    input  logic [6:0] opcode,     
    input  logic [2:0] funct3,      
    input  logic [6:0] funct7,    

    // ALU control
    output logic [3:0] aluop,      
    output logic       rf_en,     
    output logic       sel_b,    

    // Memory control
    output logic       is_load,    
    output logic       mem_write,  
    output logic [2:0] load_type,  
    output logic       load_unsigned,
    output logic [2:0] store_type, 

    // Control flow
    output logic       is_branch,  
    output logic       is_jal,     
    output logic       is_jalr     
);

    always_comb begin
  =
        // Initialize all control signals to safe defaults
        aluop         = 4'b0000; 
        rf_en         = 1'b0;     
        sel_b         = 1'b0; 

        is_load       = 1'b0;     
        mem_write     = 1'b0;     
        load_type     = 3'b000;  
        load_unsigned = 1'b0;  
        store_type    = 3'b000;  

        is_branch     = 1'b0;    
        is_jal        = 1'b0;     
        is_jalr       = 1'b0;     

        // ---------------- Instruction Decoding ----------------
        case (opcode)
            // R-type instructions: Register-Register operations
            7'b0110011: begin
                rf_en = 1'b1; 
                sel_b = 1'b0; 
                case ({funct7, funct3})
                    {7'b0000000,3'b000}: aluop = 4'b0000; // ADD
                    {7'b0100000,3'b000}: aluop = 4'b0001; // SUB
                    {7'b0000000,3'b111}: aluop = 4'b0010; // AND
                    {7'b0000000,3'b110}: aluop = 4'b0011; // OR
                    {7'b0000000,3'b100}: aluop = 4'b0100; // XOR
                    {7'b0000000,3'b010}: aluop = 4'b0101; // SLT
                endcase
            end

            // I-type ALU instructions: Register-Immediate operations
            7'b0010011: begin
                rf_en = 1'b1;  
                sel_b = 1'b1;  
                case (funct3)
                    3'b000: aluop = 4'b0000; // ADDI
                    3'b111: aluop = 4'b0010; // ANDI
                    3'b110: aluop = 4'b0011; // ORI
                    3'b100: aluop = 4'b0100; // XORI
                    3'b010: aluop = 4'b0101; // SLTI
                endcase
            end

            // Load instructions: Load from memory to register
            7'b0000011: begin
                rf_en         = 1'b1;  
                sel_b         = 1'b1;  
                is_load       = 1'b1; 
                aluop         = 4'b0000; 
                load_type     = funct3; 
                load_unsigned = funct3[2];
            end

            // Store instructions: Store register to memory
            7'b0100011: begin
                sel_b      = 1'b1;  
                mem_write  = 1'b1;  
                aluop      = 4'b0000; 
                store_type = funct3; 
            end

           
            7'b1100011: begin
                is_branch = 1'b1; 
                aluop     = 4'b0001;
            end

            // JAL:(unconditional jump with return address)
            7'b1101111: begin
                is_jal = 1'b1;  
                rf_en  = 1'b1;  
            end

            // JALR:(indirect jump with return address)
            7'b1100111: begin
                is_jalr = 1'b1; 
                rf_en   = 1'b1; 
                sel_b   = 1'b1; 
                aluop   = 4'b0000;
            end
        endcase
    end
endmodule
