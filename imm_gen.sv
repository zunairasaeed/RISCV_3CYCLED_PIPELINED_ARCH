// ============================================================================
// Immediate Generator Module
// ============================================================================

module imm_gen (
    input logic [31:0] inst,      
    output logic [31:0] imm_out    
);

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    always_comb begin
        case (opcode)
            // I-type: ADDI, ANDI, ORI, XORI, SLTI, LOAD, JALR; Immediate is in bits [31:20], sign-extended
            7'b0010011,  // I-type ALU
            7'b0000011,  // LOAD
            7'b1100111:  // JALR
            begin
                imm_out = {{20{inst[31]}}, inst[31:20]};
            end
            
            // S-type: STORE instructions
           
            7'b0100011: begin
                imm_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            
            // B-type: Branch instructions

            7'b1100011: begin
                imm_out = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            
            // J-type: JAL instruction
          
            7'b1101111: begin
                imm_out = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            
            default: imm_out = 32'b0;  
        endcase
    end

endmodule