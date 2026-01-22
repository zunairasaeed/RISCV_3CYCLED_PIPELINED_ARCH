// ============================================================================
// Testbench for 3-Stage Pipelined RISC-V Processor
//============================================================================

module tb_processor();
    logic clk, rst;

    // ---- Processor Instantiation ----
    processor proc_inst (.clk(clk), .rst(rst));

    // ---- Clock Generation (10ns period: 5ns high, 5ns low) ----
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---- Initialization and Test Sequence ----
    initial begin
        // Load instruction memory from file
        $readmemb("instruction_memory", proc_inst.imem_inst.mem);
        // Load initial register file values from file
        $readmemb("register_file", proc_inst.rfile_inst.reg_mem);

        // ---- Reset Sequence ----
        // Hold reset for 2 clock cycles to initialize all pipeline registers
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // ---- Run Simulation ----
        // Execute for 50 clock cycles to observe pipeline behavior
        repeat(50) @(posedge clk);

        // ---- Display Final State ----
        $display("\n========== SIMULATION COMPLETE ==========");
        $display("Final PC: %h", proc_inst.pc_out);
        $display("==========================================\n");

        $finish;
    end

    // ---- Monitor: Display Processor State Each Clock Cycle ----
    // This shows pipeline stages at each clock edge
    always @(posedge clk) begin
        $display("Time=%0t | PC=%h | INST_FETCH=%h", 
            $time,
            proc_inst.pc_out,
            proc_inst.inst
        );
        
        $display("        | IF/ID: PC+4=%h | INST=%h",
            proc_inst.pc_id,
            proc_inst.inst_id
        );
        
        $display("        | ID/EX: rdata1=%h | rdata2=%h | alu_res=%h",
            proc_inst.rdata1,
            proc_inst.rdata2,
            proc_inst.alu_res
        );
        
        $display("        | EX/MEM: alu_res=%h | rd=%0d | rf_en=%b",
            proc_inst.alu_result_mem,
            proc_inst.rd_mem,
            proc_inst.rf_en_mem
        );
        
        $display("        | MEM/WB: rf_wdata=%h | rd_wb=%0d | rf_en_wb=%b\n",
            proc_inst.rf_wdata,
            proc_inst.rd_wb,
            proc_inst.rf_en_wb
        );
    end

    // ---- VCD File Dumping ----
    // This creates a waveform file that can be viewed in GTKWave
    initial begin
        $dumpfile("processor.vcd");
        // Dump all signals in tb_processor and all instantiated modules
        $dumpvars(0, tb_processor);
    end

endmodule
