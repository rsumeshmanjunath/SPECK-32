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


module keygen_32(
   input clock, 
	input reset,
	input wire[63:0] ukey,
	input wire ukey_valid, 
	output wire[351:0] allRoundKeys, // 1 round key = 16 bits, 22 round keys = 352 bits
	output reg key_ready
    );
    
    localparam 	ST_IDLE = 2'b00,
                ST_INIT = 2'b01,
                ST_KEY = 2'b10,
                ST_DONE = 2'b11;
    
    reg[1:0] state;
    reg[15:0] counter;

    
    reg[15:0] A, B, C, D;
    reg[15:0] allKeys[21:0];
    
    wire [31:0] round_din, round_dout;
   
    
    assign round_din = {B, A};
    
    
    one_round_32 round (.din(round_din),.key(counter),.dout(round_dout));
    
    always@(posedge clock) begin
        if(state == ST_KEY) begin
            allKeys[counter] <= A;
            A <= round_dout[15:0];
            B <= C;
            C <= D;
            D <= round_dout[31:16];
        end
    
    end
    
    
    // counter logic
    always@(posedge clock) begin
        if(state == ST_KEY) begin
            if(counter == 21)
                state <= ST_DONE;
            else
                counter <= counter + 1;
        end
    end
    
    always@(posedge clock) begin
    
    // if reset = 0 or use key valid signal =0  then be in idle state
        if(reset ==0 || ukey_valid == 0) begin
            state <= ST_IDLE;
            key_ready <= 1'b0;
            counter <= 16'b0;
        end
        else begin
            case(state)
                ST_IDLE: begin
                            if(ukey_valid == 1'b1) begin
                                A <= ukey[15:0];
                                B <= ukey[31:16];
                                C <= ukey[47:32];
                                D <= ukey[63:48];
                                state <= ST_KEY;
                            end
                         end
                ST_KEY: begin
                                            
                            end
                                                        
                ST_DONE: begin
                             key_ready <= 1'b1;                           
                           end
               default : begin
                         
                         end   
            endcase
        end
    end
    

assign allRoundKeys[15:0] = allKeys[0];
assign allRoundKeys[31:16] = allKeys[1];
assign allRoundKeys[47:32] = allKeys[2];
assign allRoundKeys[63:48] = allKeys[3];
assign allRoundKeys[79:64] = allKeys[4];
assign allRoundKeys[95:80] = allKeys[5];
assign allRoundKeys[111:96] = allKeys[6];
assign allRoundKeys[127:112] = allKeys[7];
assign allRoundKeys[143:128] = allKeys[8];
assign allRoundKeys[159:144] = allKeys[9];
assign allRoundKeys[175:160] = allKeys[10];
assign allRoundKeys[191:176] = allKeys[11];
assign allRoundKeys[207:192] = allKeys[12];
assign allRoundKeys[223:208] = allKeys[13];
assign allRoundKeys[239:224] = allKeys[14];
assign allRoundKeys[255:240] = allKeys[15];
assign allRoundKeys[271:256] = allKeys[16];
assign allRoundKeys[287:272] = allKeys[17];
assign allRoundKeys[303:288] = allKeys[18];
assign allRoundKeys[319:304] = allKeys[19];
assign allRoundKeys[335:320] = allKeys[20];
assign allRoundKeys[351:336] = allKeys[21];

    
endmodule
