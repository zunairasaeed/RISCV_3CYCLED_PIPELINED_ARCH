// IF/ID Pipeline Register

module if_id_reg (
    input logic clk,
    input logic rst,
    input logic [31:0] pc_in,       
    input logic [31:0] pc_plus_4_in,
    input logic [31:0] inst_in,     
    output logic [31:0] pc_out,     
    output logic [31:0] pc_plus_4_out, 
    output logic [31:0] inst_out    
);

    // Pipeline register: stores PC, PC+4, and instruction (IR)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out        <= 32'b0;
            pc_plus_4_out <= 32'b0;
            inst_out      <= 32'b0;
        end else begin
            pc_out        <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;
            inst_out      <= inst_in;
        end
    end

endmodule
