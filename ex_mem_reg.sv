// EX/MEM Pipeline Register

module ex_mem_reg (
    input logic clk,
    input logic rst,
    
    // Data from Execute stage
    input logic [31:0] alu_result_in,   
    input logic [31:0] rdata2_in,        
    input logic [31:0] pc_in,            
    input logic [31:0] pc_plus_4_in,     
    input logic [31:0] ir_in,            
    input logic [4:0]  rd_in,            
    
    // Control signals from Execute stage
    input logic        rf_en_in,        
    input logic        mem_write_in,     
    input logic        is_load_in,      
    input logic        is_jal_in,       
    input logic        is_jalr_in,      
    input logic [2:0]  load_type_in,     
    input logic        load_unsigned_in, 
    input logic [2:0]  store_type_in,  
    
    // Outputs to Memory stage
    output logic [31:0] alu_result_out,
    output logic [31:0] rdata2_out,
    output logic [31:0] pc_out,          
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] ir_out,          
    output logic [4:0]  rd_out,
    output logic        rf_en_out,
    output logic        mem_write_out,
    output logic        is_load_out,
    output logic        is_jal_out,
    output logic        is_jalr_out,
    output logic [2:0]  load_type_out,
    output logic        load_unsigned_out,
    output logic [2:0]  store_type_out
);

    // Pipeline register: stores all signals needed for memory stage and PC and IR (Instruction Register) for tracking
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_out  <= 32'b0;
            rdata2_out      <= 32'b0;
            pc_out          <= 32'b0;
            pc_plus_4_out   <= 32'b0;
            ir_out          <= 32'b0;
            rd_out          <= 5'b0;
            rf_en_out       <= 1'b0;
            mem_write_out   <= 1'b0;
            is_load_out     <= 1'b0;
            is_jal_out      <= 1'b0;
            is_jalr_out     <= 1'b0;
            load_type_out   <= 3'b0;
            load_unsigned_out <= 1'b0;
            store_type_out  <= 3'b0;
        end else begin
            alu_result_out  <= alu_result_in;
            rdata2_out      <= rdata2_in;
            pc_out          <= pc_in;
            pc_plus_4_out   <= pc_plus_4_in;
            ir_out          <= ir_in;
            rd_out          <= rd_in;
            rf_en_out       <= rf_en_in;
            mem_write_out   <= mem_write_in;
            is_load_out     <= is_load_in;
            is_jal_out      <= is_jal_in;
            is_jalr_out     <= is_jalr_in;
            load_type_out   <= load_type_in;
            load_unsigned_out <= load_unsigned_in;
            store_type_out  <= store_type_in;
        end
    end

endmodule
