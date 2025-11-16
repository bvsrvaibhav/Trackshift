


`timescale 1ns / 1ps
/**
 * Error Detector - MODIFIED (Combinational)
 * Calculates the error signal e[n] = R - |z[n]|
 */
module error_detector (
    // input clk,               // <-- REMOVED
    input signed [15:0] target_R,     // Q8.8 target amplitude
    input signed [15:0] current_mag,  // Q8.8 current magnitude
    output reg signed [15:0] error    // Q8.8 error signal
);

    always @(*) begin // <--- MODIFIED from @(posedge clk)
        error = target_R - current_mag;
    end

endmodule
