module mux2 (
    input logic [31:0] in0,     
    input logic [31:0] in1,       
    input logic sel,             
    output logic [31:0] out        
);

    always_comb 
    begin
        out = sel ? in1 : in0; 
    end

endmodule