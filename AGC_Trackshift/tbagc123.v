


`timescale 1ns / 1ps


module agc_tb;

    // Parameters
    localparam CLK_PERIOD = 10; // 10ns clock period

    // Testbench signals
    reg clk;
    reg rst;
    // These must be 'signed' to match the DUT port
    reg signed [3:0] x_i_in;
    reg signed [3:0] x_q_in;

    wire signed [15:0] z_i_out;
    wire signed [15:0] z_q_out;
    
    // --- File I/O Variables ---
    // 'integer' is standard Verilog-1995
    integer real_file_handle;
    integer imag_file_handle;
    // This reg can be signed (Verilog-2001) or unsigned (Verilog-1995)
    reg [3:0] real_data; // Use 4-bit unsigned reg
    reg [3:0] imag_data; // Use 4-bit unsigned reg
    
    // *** FIX 1: Declare the counter variable 'i' ***
    integer i; 
    
    agc_top agc_top_inst (
        .clk(clk),
        .rst(rst),
        .x_i_in(x_i_in),
        .x_q_in(x_q_in),
        .z_i_out(z_i_out),
        .z_q_out(z_q_out)
    );

    // 1. Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 2. Stimulus and Simulation Control
    initial begin
        
        $monitor("Time=%0t | rst=%b | x_in=(%d, %d) | z_out_hex=(%h, %h) | z_out_float=(%f, %f)",
                 $time, rst, x_i_in, x_q_in, 
                 z_i_out, z_q_out,
                 $signed(z_i_out) / 256.0,
                 $signed(z_q_out) / 256.0);
                 
        real_file_handle = $fopen("C:/Users/bvsrv/agc123/real2.dat", "r");
        imag_file_handle = $fopen("C:/Users/bvsrv/agc123/img.dat", "r");

        if (real_file_handle == 0 || imag_file_handle == 0) begin
            $display("Error: Could not open input files.");
            $finish;
        end

        // --- Reset Sequence ---
        rst = 1;
        x_i_in = 0;
        x_q_in = 0;
        #(CLK_PERIOD * 2); // t=20
        
        rst = 0;
        
        // *** FIX 2: Initialize the counter ***
        i = 0; 

        // --- Main file reading loop ---
        begin : file_read_loop
            while (1) begin
                if ($feof(real_file_handle) || $feof(imag_file_handle)) begin
                    $display("End of file reached. Read %d samples.", i);
                    disable file_read_loop; // Verilog-2001 'break'
                end
                
                // *** MODIFIED: Read hex (%h) instead of decimal (%d) ***
                $fscanf(real_file_handle, "%h", real_data);
                $fscanf(imag_file_handle, "%h", imag_data);
                
                x_i_in = real_data;
                x_q_in = imag_data;
                
                // *** FIX 3: Increment the counter ***
                i = i + 1; 
                
                @(posedge clk);
            end
        end // End of named block 'file_read_loop'
        
        // --- Cleanup ---
        $display("File reading complete.");
        $fclose(real_file_handle);
        $fclose(imag_file_handle);
        
        #100; // Wait a bit
        $finish;
    end

endmodule



