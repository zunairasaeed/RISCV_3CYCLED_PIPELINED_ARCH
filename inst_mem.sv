// ============================================================================
// Instruction Memory Module
// ============================================================================

module inst_mem (
    input logic [31:0] addr,       
    output logic [31:0] data      
);
   
    logic [31:0] mem [1023:0];

  
    always_comb 
    begin
        data = mem[addr[31:2]];  
    end
endmodule
