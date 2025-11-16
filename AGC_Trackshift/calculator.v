


`timescale 1ns / 1ps

/**
 * Magnitude Calculator (Approximation) - MODIFIED (Combinational)
 * Calculates magnitude = max(|I|, |Q|) + 0.5*min(|I|, |Q|)
 */
module magnitude_calculator (
    // input clk,            // <-- REMOVED
    input signed [15:0] z_i,       // Q8.8 real input
    input signed [15:0] z_q,       // Q8.8 imaginary input
    output reg signed [15:0] magnitude // Q8.8 magnitude output
);

    reg signed [15:0] abs_i, abs_q;
    reg signed [15:0] max_val, min_val;

    always @(*) begin  // <--- MODIFIED from @(posedge clk)
        // 1. Find absolute values (abs)
        abs_i = (z_i[15]) ? -z_i : z_i;
        abs_q = (z_q[15]) ? -z_q : z_q;

        // 2. Find max and min
        if (abs_i > abs_q) begin
            max_val = abs_i;
            min_val = abs_q;
        end else begin
            max_val = abs_q;
            min_val = abs_i;
        end

        // 3. Calculate approximation: max + 0.5*min
        // A ">> 1" is a divide by 2 (or 0.5 multiply)
        magnitude = max_val + (min_val >>> 1);
    end

//endmodule
endmodule



