`timescale 1ns / 1ps

/**
 * TOP MODULE: Automatic Gain Control (AGC)
 * Connects all sub-modules to implement the full AGC loop.
 */
module agc_top (
    input clk,
    input rst,
    input signed [3:0] x_i_in,     // 4-bit real input
    input signed [3:0] x_q_in,     // 4-bit imag input
    output signed [15:0] z_i_out,  // Q8.8 scaled real output
    output signed [15:0] z_q_out   // Q8.8 scaled imag output
);

    // --- Fixed-Point Parameters ---
    localparam [15:0] TARGET_R     = 16'h0400; 
    localparam [15:0] MU           = 16'h001A;
    localparam [15:0] INITIAL_GAIN = 16'h0100;

    // --- Wires for feedback loop ---
    wire signed [15:0] gain;         
    wire signed [15:0] z_i_scaled;   
    wire signed [15:0] z_q_scaled;   
    wire signed [15:0] magnitude;    
    wire signed [15:0] error;        

    // 1. Loop Filter (The only sequential part of the loop)
    loop_filter u_loop_filter (
        .clk(clk),
        .rst(rst),
        .error(error),
        .mu(MU),
        .initial_gain(INITIAL_GAIN),
        .gain(gain) 
    );

    // 2. Complex Multiplier (Combinational)
    complex_multiplier u_multiplier (
        .x_i(x_i_in),
        .x_q(x_q_in),
        .gain(gain),
        .z_i(z_i_scaled),
        .z_q(z_q_scaled)
    );

    // 3. Magnitude Calculator (NOW Combinational)
    magnitude_calculator u_mag_calc (
        // .clk(clk),            // <--- REMOVED
        .z_i(z_i_scaled),
        .z_q(z_q_scaled),
        .magnitude(magnitude)
    );

    // 4. Error Detector (NOW Combinational)
    error_detector u_error_det (
        // .clk(clk),            // <--- REMOVED
        .target_R(TARGET_R),
        .current_mag(magnitude),
        .error(error)
    );
    
    assign z_i_out = z_i_scaled;
    assign z_q_out = z_q_scaled;

endmodule





