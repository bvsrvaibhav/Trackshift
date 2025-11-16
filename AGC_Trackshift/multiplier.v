
`timescale 1ns / 1ps


/**
 * Complex Multiplier
 * Multiplies the complex input (x_i, x_q) by the real gain.
 * z_i = x_i * gain
 * z_q = x_q * gain
 */
module complex_multiplier (
    input  signed [3:0] x_i,       // 4-bit real input
    input  signed [3:0] x_q,       // 4-bit imaginary input
    input  signed [15:0] gain,     // Q8.8 gain value
    output reg signed [15:0] z_i,  // Q8.8 scaled real output
    output reg signed [15:0] z_q   // Q8.8 scaled imaginary output
);

    // Internal 32-bit registers for full multiplication result (Q16.16)
    reg signed [31:0] z_i_product;
    reg signed [31:0] z_q_product;

    // Convert 4-bit inputs to 16-bit Q8.8 format
    // 1. Sign-extend the 4-bit value to 16 bits
    // 2. Shift left by 8 to align it as a Q8.8 number
    //    e.g., input '3' (4'b0011) becomes 16'h0300 (value 3.0)
    wire signed [15:0] x_i_fixed = {{12{x_i[3]}}, x_i} << 8;
    wire signed [15:0] x_q_fixed = {{12{x_q[3]}}, x_q} << 8;

    always @(*) begin
        // Perform multiplication. Result is Q16.16 (32 bits)
        z_i_product = x_i_fixed * gain;
        z_q_product = x_q_fixed * gain;

        // Scale back to Q8.8 by taking the correct 16 bits
        // We shift right by 8 (discarding the 8 lower fractional bits)
        // This is equivalent to product[23:8]
        z_i = z_i_product >>> 8;
        z_q = z_q_product >>> 8;
    end

endmodule
