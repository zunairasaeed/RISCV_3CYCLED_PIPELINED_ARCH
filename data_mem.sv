
module data_mem (
    input logic clk,
    input logic [31:0] addr,       
    input logic [31:0] wdata,      
    input logic [2:0] load_type,   
    input logic load_unsigned,   
    input logic mem_write,         
    input logic [2:0] store_type, 
    output logic [31:0] rdata      
);
    // Data memory: 1024 bytes (256 words) 
    logic [7:0] mem [1024];
    logic [9:0] addr_idx;
    assign addr_idx = addr[9:0];  // Use lower 10 bits for addressing

    // Combinational read: load operations
    always_comb begin
        case(load_type)
            // Byte load: LB (signed) or LBU (unsigned)
            3'b000: begin 
                if (load_unsigned)
                    rdata = {24'b0, mem[addr_idx]};  // LBU: zero-extend
                else
                    rdata = {{24{mem[addr_idx][7]}}, mem[addr_idx]};  // LB: sign-extend
            end

            // Halfword load: LH or LHU 
            3'b001: begin
                if (load_unsigned)
                    rdata = {16'b0, mem[addr_idx+1], mem[addr_idx]};  
                else
                    rdata = {{16{mem[addr_idx+1][7]}}, mem[addr_idx+1], mem[addr_idx]}; 
            end

            // Word load: LW (always 32 bits)
            3'b010: begin
                rdata = {mem[addr_idx+3], mem[addr_idx+2], mem[addr_idx+1], mem[addr_idx]};
            end

            default: rdata = 32'b0;
        endcase
    end

    // Synchronous write: store operations
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (store_type)
                3'b000: begin 
                    mem[addr_idx] <= wdata[7:0];
                end
                3'b001: begin 
                    mem[addr_idx]     <= wdata[7:0];
                    mem[addr_idx + 1] <= wdata[15:8];
                end
                3'b010: begin 
                    mem[addr_idx]     <= wdata[7:0];
                    mem[addr_idx + 1] <= wdata[15:8];
                    mem[addr_idx + 2] <= wdata[23:16];
                    mem[addr_idx + 3] <= wdata[31:24];
                end
                default: begin
                    mem[addr_idx] <= wdata[7:0]; 
                end
            endcase
        end
    end
endmodule