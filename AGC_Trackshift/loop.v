
`timescale 1ns / 1ps

module loop_filter (
    input clk,
    input rst,
    input signed [15:0] error,         // Q8.8 error input
    input signed [15:0] mu,            // Q8.8 step size
    input signed [15:0] initial_gain,  // Q8.8 initial gain
    output signed [15:0] gain         // <-- FIX: Removed 'reg' from here
);

    reg signed [15:0] gain_reg;
    wire signed [15:0] gain_update;
    
    // Internal 32-bit register for full multiplication result (Q16.16)
    wire signed [31:0] update_product = error * mu;
    
    // Scale the product (mu * error) back to Q8.8
    // (product[23:8])
    assign gain_update = update_product >>> 8;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            gain_reg <= initial_gain; // Reset gain to 1.0 (or other initial)
        end else begin
            gain_reg <= gain_reg + gain_update;
        end
    end
    
    // This concurrent assignment now correctly drives the output 'wire'
    assign gain = gain_reg;

endmodule
