`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 12:28:53 PM
// Design Name: 
// Module Name: one_round_32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module one_round_32(
    input wire [31:0] din,
    input wire [15:0] key,
    output wire [31:0] dout
    );
    
    wire [15:0] left, right;
    wire [15:0] left_shift, right_shift;
    wire [15:0] left_add;
    wire [15:0] left_new, right_new;
    
    assign left = din[31:16];
    assign right = din[15:0]; 
    assign left_shift = {left[6:0], left[15:7]};
    assign left_add = left_shift + right;
    assign left_new = left_add ^ key;
    
    assign right_shift = {right[13:0], right[15:14]};
    assign right_new = right_shift ^ left_new;
    assign dout = {left_new, right_new}; 
    
endmodule
