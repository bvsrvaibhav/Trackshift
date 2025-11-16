
`timescale 1ns / 1ps

module tb_QPSK_Symbol_Timing_Sync_Top;

    parameter DATA_WIDTH   = 16;
    parameter MU_WIDTH     = 10;
    parameter MU_FRAC      = 9;
    parameter COEFF_WIDTH  = 16;
    parameter ACC_WIDTH    = 32;
    parameter MEM_DEPTH    = 16384;

    reg clk = 0;
    reg rst = 1;

    reg signed [DATA_WIDTH-1:0] I_mem [0:MEM_DEPTH-1];
    reg signed [DATA_WIDTH-1:0] Q_mem [0:MEM_DEPTH-1];

    reg signed [DATA_WIDTH-1:0] I_in = 0;
    reg signed [DATA_WIDTH-1:0] Q_in = 0;

    wire signed [DATA_WIDTH-1:0] I_out;
    wire signed [DATA_WIDTH-1:0] Q_out;
    wire                         valid_out;

    integer i;
    integer f_i_log, f_q_log;

  QPSK_Symbol_Timing_Sync_Top #(
        .DATA_WIDTH(DATA_WIDTH),
        .MU_WIDTH(MU_WIDTH),
        .MU_FRAC(MU_FRAC),
        .COEFF_WIDTH(COEFF_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .I_in(I_in),
        .Q_in(Q_in),
        .I_out(I_out),
        .Q_out(Q_out),
        .valid_out(valid_out)
    );

    // Clock generation: 100 MHz
    always #5 clk = ~clk;

    // Log file open
    initial begin
        f_i_log = $fopen("C:/Internships/NRSC/GTED/I1_log.txt", "w");
        f_q_log = $fopen("C:/Internships/NRSC/GTED/I2_log.txt", "w");

        if (f_i_log == 0 || f_q_log == 0) begin
            $display("ERROR opening output log files.");
            $finish;
        end
    end

    // Header printing flag
    reg header_printed = 0;

    // Output logging on valid_out
    always @(posedge clk) begin
        if (!rst && valid_out) begin
            $fwrite(f_i_log, "%h\n", I_out);
            $fwrite(f_q_log, "%h\n", Q_out);
            $fflush(f_i_log);
            $fflush(f_q_log);

            if (!header_printed) begin
                $display("Time(ns) |   I_in |  Q_in | I_out | Q_out | valid_out | I_interp | Q_interp |   e_k   |  e_k_zs |   v_k   |   mu");
                header_printed = 1;
            end

            if ($time <= 1000) begin
                $display("%8t | %6d | %6d | %6d | %6d |     %1b      | %8d | %8d | %7d | %7d | %7d | %4d",
                    $time,
                    I_in, Q_in,
                    I_out, Q_out,
                    valid_out,
                    dut.interpolator_inst.I_interp,   // Cubic interpolated I
                    dut.interpolator_inst.Q_interp,   // Cubic interpolated Q
                    dut.zcted_inst.e_k,               // TED output (44-bit)
                    dut.zs_inst.e_k_zs,              // TED truncated
                    dut.loop_filter_inst.v_k,
                    dut.nco_update_inst.mu
                );
            end
        end
    end

    // Stimulus
    initial begin
        $readmemh("C:/Internships/NRSC/GTED/I1.txt", I_mem);
        $readmemh("C:/Internships/NRSC/GTED/I2.txt", Q_mem);

        #20 rst = 0;

        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            @(posedge clk);
            I_in <= I_mem[i];
            Q_in <= Q_mem[i];
        end

        I_in <= 0;
        Q_in <= 0;

        repeat (200) @(posedge clk);

        $fclose(f_i_log);
        $fclose(f_q_log);

        $display("Simulation done. Output files written.");
        $stop;
    end

endmodule


