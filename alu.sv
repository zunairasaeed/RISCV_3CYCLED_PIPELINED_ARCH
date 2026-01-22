
module alu (
    input logic[31:0] opr_a,       
    input logic[31:0] opr_b,       
    input logic[3:0] aluop,        
    output logic[31:0] alu_res,    
    output logic zero              
);

always_comb 
begin
    case(aluop)
        4'b0000: alu_res = opr_a + opr_b;                    
        4'b0001: alu_res = opr_a - opr_b;                    
        4'b0010: alu_res = opr_a << opr_b[4:0];              
        4'b0011: alu_res = ($signed(opr_a) < $signed(opr_b)) ? 32'd1 : 32'd0; 
        4'b0100: alu_res = (opr_a < opr_b) ? 32'd1 : 32'd0;  
        4'b0101: alu_res = opr_a ^ opr_b;                   
        4'b0110: alu_res = opr_a >> opr_b[4:0];              
        4'b0111: alu_res = $signed(opr_a) >>> opr_b[4:0];    
        4'b1000: alu_res = opr_a | opr_b;                    
        4'b1001: alu_res = opr_a & opr_b;                    
        4'b1010: alu_res = opr_a * opr_b;                    
        default:  alu_res = 32'b0;                          
    endcase
    // Zero flag: set to 1 if ALU result is zero (used for BEQ/BNE)
    zero = (alu_res == 32'b0);
end

initial begin
    // $monitor("Time: %0t | OPR_A: %h | OPR_B: %h | ALUOP: %b | ALU_RES: %h", $time, opr_a, opr_b, aluop, alu_res);
end

endmodule