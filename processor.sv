// ============================================================================
// 3-Stage Pipelined RISC-V Processor
// ============================================================================
// This processor implements a 3-stage pipeline:
//   Stage 1 (IF): Instruction Fetch - PC, Instruction Memory
//   Stage 2 (ID/EX): Decode/Execute - Register File, ALU, Immediate Generation
//   Stage 3 (MEM/WB): Memory/Writeback - Data Memory, Register Write

module processor (
    input logic clk,
    input logic rst
);

    // ==================== STAGE 1: INSTRUCTION FETCH ====================
    logic [31:0] pc_out, pc_next, pc_plus_4;
    logic [31:0] inst; 

    logic [31:0] pc_id, pc_plus_4_id, inst_id;  
    logic [31:0] imm_ex;  

    logic branch_taken_ex, is_jal_ex, is_jalr_ex;
    logic [31:0] rdata1_ex;
    
    // PC logic: handles branches, jumps, and sequential execution
    always_comb begin
        if (is_jalr_ex) begin
            // JALR: jump to (rs1 + immediate) & 0xFFFFFFFE
            pc_next = (rdata1_ex + imm_ex) & 32'hFFFFFFFE;
        end else if (is_jal_ex || branch_taken_ex) begin
            // JAL or taken branch: PC + immediate offset
            pc_next = pc_id + imm_ex;
        end else begin
            // Sequential: PC + 4
            pc_next = pc_out + 32'd4;
        end
    end
    
    assign pc_plus_4 = pc_out + 32'd4;
    
    // Program Counter: updates on clock edge
    pc pc_inst(.clk(clk), .rst(rst), .pc_in(pc_next), .pc_out(pc_out));
    
    // Instruction Memory: reads instruction at PC address
    inst_mem imem_inst(.addr(pc_out), .data(inst));


    // ==================== IF/ID PIPELINE REGISTER ====================
    // Register buffer between Fetch and Decode stages
    // Note: pc_id, pc_plus_4_id, inst_id, and imm_ex are declared above
    if_id_reg if_id_reg_inst(
        .clk(clk),
        .rst(rst),
        .pc_in(pc_out),       
        .pc_plus_4_in(pc_plus_4), 
        .inst_in(inst),        
        .pc_out(pc_id),        
        .pc_plus_4_out(pc_plus_4_id),
        .inst_out(inst_id)    
    );


    // ==================== STAGE 2: DECODE/EXECUTE ====================
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;
    logic [4:0] rs1, rs2, rd;
    
    inst_dec idec_inst(
        .inst(inst_id),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );
    

    imm_gen imm_gen_inst(.inst(inst_id), .imm_out(imm_ex));
    
    // Control unit
    logic [3:0] aluop;
    logic rf_en, sel_b;
    logic is_load, mem_write;
    logic [2:0] load_type, store_type;
    logic load_unsigned;
    logic is_branch, is_jal, is_jalr;
    
    controller ctrl_inst(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .aluop(aluop),
        .rf_en(rf_en),
        .sel_b(sel_b),
        .is_load(is_load),
        .mem_write(mem_write),
        .load_type(load_type),
        .load_unsigned(load_unsigned),
        .store_type(store_type),
        .is_branch(is_branch),
        .is_jal(is_jal),
        .is_jalr(is_jalr)
    );
    
    // Register File
    logic [31:0] rdata1, rdata2;
    
    // Writeback signals
    logic [31:0] rf_wdata;
    logic [4:0] rd_wb;
    logic rf_en_wb;
    
    reg_file rfile_inst(
        .clk(clk),
        .rf_en(rf_en_wb),          
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd_wb),               
        .wdata(rf_wdata),         
        .rdata1(rdata1),
        .rdata2(rdata2)
    );
    
    // ALU input multiplexer
    logic [31:0] alu_b, alu_res;
    logic zero;
    mux2 mux_alu_b(.in0(rdata2), .in1(imm_ex), .sel(sel_b), .out(alu_b));
    
    // Arithmetic Logic Unit
    alu alu_inst(
        .opr_a(rdata1),
        .opr_b(alu_b),
        .aluop(aluop),
        .alu_res(alu_res),
        .zero(zero)
    );
    
    // Branch logic
    // These signals are used in PC logic (control hazard - resolved in ID/EX)
    always_comb begin
        branch_taken_ex = 1'b0;
        if (is_branch) begin
            case(funct3)
                3'b000: branch_taken_ex = zero;           
                3'b001: branch_taken_ex = ~zero;          
                3'b100: branch_taken_ex = alu_res[0];    
                3'b101: branch_taken_ex = ~alu_res[0];   
                3'b110: branch_taken_ex = alu_res[0];     
                3'b111: branch_taken_ex = ~alu_res[0];    
            endcase
        end
    end
    
    // Pass control signals and data for PC update
    assign is_jal_ex = is_jal;
    assign is_jalr_ex = is_jalr;
    assign rdata1_ex = rdata1;


    // ==================== EX/MEM PIPELINE REGISTER ====================
 
    logic [31:0] alu_result_mem, rdata2_mem, pc_mem, pc_plus_4_mem, ir_mem;
    logic [4:0] rd_mem;
    logic rf_en_mem, mem_write_mem, is_load_mem;
    logic is_jal_mem, is_jalr_mem;
    logic [2:0] load_type_mem, store_type_mem;
    logic load_unsigned_mem;
    
    ex_mem_reg ex_mem_reg_inst(
        .clk(clk),
        .rst(rst),
        .alu_result_in(alu_res),
        .rdata2_in(rdata2),
        .pc_in(pc_id),              
        .pc_plus_4_in(pc_plus_4_id), 
        .ir_in(inst_id),           
        .rd_in(rd),
        .rf_en_in(rf_en),
        .mem_write_in(mem_write),
        .is_load_in(is_load),
        .is_jal_in(is_jal),
        .is_jalr_in(is_jalr),
        .load_type_in(load_type),
        .load_unsigned_in(load_unsigned),
        .store_type_in(store_type),
        .alu_result_out(alu_result_mem),
        .rdata2_out(rdata2_mem),
        .pc_out(pc_mem),           
        .pc_plus_4_out(pc_plus_4_mem),
        .ir_out(ir_mem),            
        .rd_out(rd_mem),
        .rf_en_out(rf_en_mem),
        .mem_write_out(mem_write_mem),
        .is_load_out(is_load_mem),
        .is_jal_out(is_jal_mem),
        .is_jalr_out(is_jalr_mem),
        .load_type_out(load_type_mem),
        .load_unsigned_out(load_unsigned_mem),
        .store_type_out(store_type_mem)
    );


    // ==================== STAGE 3: MEMORY/WRITEBACK ====================
    // Data Memory
    logic [31:0] load_data;
    data_mem dmem_inst(
        .clk(clk),
        .addr(alu_result_mem),      
        .wdata(rdata2_mem),            
        .load_type(load_type_mem),
        .load_unsigned(load_unsigned_mem),
        .mem_write(mem_write_mem),
        .store_type(store_type_mem),
        .rdata(load_data)
    );
    
    // Writeback: select data to write back to register file
    // Note: rf_wdata, rd_wb, and rf_en_wb are declared above
    
    // Pipeline register for writeback stage (implicit in register file timing)
    // Note: pc_mem and ir_mem are available here for tracking/debugging
    
    always_ff @(posedge clk) begin
        rd_wb <= rd_mem;
        rf_en_wb <= rf_en_mem;
    end
    
    // Writeback data selection: priority order
    // 1. JAL/JALR: return address (PC+4)
    // 2. Load: data from memory
    // 3. Normal: ALU result
    always_comb begin
        if (is_jal_mem || is_jalr_mem) begin
            rf_wdata = pc_plus_4_mem;
        end else if (is_load_mem) begin
            rf_wdata = load_data;
        end else begin
            rf_wdata = alu_result_mem;
        end
    end

endmodule
