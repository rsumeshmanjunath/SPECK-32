`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2021 06:06:54 PM
// Design Name: 
// Module Name: encrypt
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


module encrypt(
    input clock,
	input reset,
	input wire[31:0] din,
	input wire[351:0] allRoundKeys,
	input wire din_valid,
	output reg dout_ready,
	output reg busy,
	output wire[31:0] dout
    );
    
    reg[1:0] state;
    localparam 	ST_IDLE = 2'b00,
                ST_ENCRYPT = 2'b01,
                ST_DONE = 2'b11;
    
    wire[15:0] allKeys[21:0];
    
    integer round = 0;

    assign allKeys[0] = allRoundKeys[15:0];
    assign allKeys[1] = allRoundKeys[31:16];
    assign allKeys[2] = allRoundKeys[47:32];
    assign allKeys[3] = allRoundKeys[63:48];
    assign allKeys[4] = allRoundKeys[79:64];
    assign allKeys[5] = allRoundKeys[95:80];
    assign allKeys[6] = allRoundKeys[111:96];
    assign allKeys[7] = allRoundKeys[127:112];
    assign allKeys[8] = allRoundKeys[143:128];
    assign allKeys[9] = allRoundKeys[159:144];
    assign allKeys[10] = allRoundKeys[175:160];
    assign allKeys[11] = allRoundKeys[191:176];
    assign allKeys[12] = allRoundKeys[207:192];
    assign allKeys[13] = allRoundKeys[223:208];
    assign allKeys[14] = allRoundKeys[239:224];
    assign allKeys[15] = allRoundKeys[255:240];
    assign allKeys[16] = allRoundKeys[271:256];
    assign allKeys[17] = allRoundKeys[287:272];
    assign allKeys[18] = allRoundKeys[303:288];
    assign allKeys[19] = allRoundKeys[319:304];
    assign allKeys[20] = allRoundKeys[335:320];
    assign allKeys[21] = allRoundKeys[351:336];
    
    reg[31:0] reg_in;
    wire[31:0] r_out;
        
    initial begin
            round = 0;
            state <= ST_IDLE;
            dout_ready <= 0;
            busy <= 0;
        end
    
    //Round function of SPECK-32/64
    one_round_32 speck_round (.din(reg_in),.key(allKeys[round]),.dout(r_out));
    
    // counter logic
        always@(posedge clock) begin
            if(state == ST_ENCRYPT) begin
                if(round == 20) begin
                    round <= round + 1;
                    state <= ST_DONE;
                    end
                else
                    round <= round + 1;
            end
        end

 always@(posedge clock) begin
    
    // if reset = 0 or use key valid signal =0  then be in idle state
        if(reset ==0 || din_valid == 0) begin
            state <= ST_IDLE;
            dout_ready <= 1'b0;
            round <= 5'b0;
            reg_in <= 0;
            busy <= 1'b0;
        end
        else begin
            case(state)
                ST_IDLE: begin
                            if(din_valid)
                                state <= ST_ENCRYPT;
                                reg_in <= din;
                                busy <= 1'b1;
                         end

                ST_ENCRYPT: begin
                                reg_in <= r_out;            
                            end
                                                        
                ST_DONE: begin
                                 dout_ready <= 1'b1;   
                                 busy <= 1'b0;                    
                           end
               default : begin
                         
                         end   
            endcase
        end
    end
    
    assign dout = r_out; 
    
endmodule
