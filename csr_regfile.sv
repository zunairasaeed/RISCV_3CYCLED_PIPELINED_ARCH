module csr_regfile (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        csr_wr_req,
    input  logic        csr_rd_req,
    input  logic        is_mret,
    input  logic [11:0] csr_addr,
    input  logic [31:0] csr_wdata,
    input  logic [31:0] pc_in,
    input  logic        interrupt,
    input  logic [31:0] intr_cause,
    output logic [31:0] csr_rdata,
    output logic [31:0] mepc_out,
    // expose mtvec 
    output logic [31:0] mtvec_out,
    output logic        epc_taken
);

    logic [31:0] csr_mstatus, csr_mie, csr_mip, csr_mtvec, csr_mepc, csr_mcause;

    assign mepc_out = csr_mepc;
    assign mtvec_out = csr_mtvec;
   
    assign epc_taken = is_mret || (interrupt && csr_mstatus[3] && csr_mie[0]);

    // ---------------- CSR Read ----------------
    always_comb begin
        csr_rdata = 32'b0;
        if (csr_rd_req) begin
            case(csr_addr)
                12'h300: csr_rdata = csr_mstatus;
                12'h304: csr_rdata = csr_mie;
                12'h344: csr_rdata = csr_mip;
                12'h305: csr_rdata = csr_mtvec;
                12'h341: csr_rdata = csr_mepc;
                12'h342: csr_rdata = csr_mcause;
                default: csr_rdata = 32'b0;
            endcase
        end
    end

    // ---------------- CSR Write ----------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_mstatus <= 32'b0;
            csr_mie     <= 32'b0;
            csr_mip     <= 32'b0;
         
            csr_mtvec   <= 32'h00000080;
            csr_mepc    <= 32'b0;
            csr_mcause  <= 32'b0;
        end else begin
          
            if (is_mret) begin
               
            end
            // Interrupt handling
            else if (interrupt && csr_mstatus[3] && csr_mie[0]) begin
                csr_mepc   <= pc_in;
                csr_mcause <= intr_cause;
            end
            // Normal CSR write
            else if (csr_wr_req) begin
                case(csr_addr)
                    12'h300: csr_mstatus <= csr_wdata;
                    12'h304: csr_mie     <= csr_wdata;
                    12'h344: csr_mip     <= csr_wdata;
                    12'h305: csr_mtvec   <= csr_wdata;
                    12'h341: csr_mepc    <= csr_wdata;
                    12'h342: csr_mcause  <= csr_wdata;
                endcase
            end
        end
    end
endmodule
