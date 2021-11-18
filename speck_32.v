`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2021 12:11:10 PM
// Design Name: 
// Module Name: speck_32
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


module speck_32(
  input               resetn,       // Async reset.
  input               clock,        // clock.
  input               enc_dec,      // Encrypt/Decrypt select. 0:Encrypt  1:Decrypt
  input               key_exp,      // Round Key Expansion
  input               start,        // Encrypt or Decrypt Start
  output reg          key_val,      // Round Key valid
  output reg          text_val,     // Cipher Text or Inverse Cipher Text valid
  input      [63:0]  key_in,       // Key input
  input      [31:0]  text_in,      // Cipher Text or Inverse Cipher Text input
  output     [31:0]  text_out,     // Cipher Text or Inverse Cipher Text output
  output reg          busy          // AES unit Busy
    );
    
    // State Machine stage name
    `define  IDLE        3'h0           // Idle stage.
    `define  KEY_EXP     3'h1           // Key expansion stage.
    `define  ROUND_LOOP  3'h2           // Cipher/InvCipher stage.
    
    reg       [2:0]  now_state;       // State Machine register
    reg       [2:0]  next_state;      // Next State Machine value
    
    wire [63:0] master_key;
    wire [31:0] din, dout;
    wire[351:0] allKeys;
        
    assign master_key = key_in[63:0];
    assign din = text_in[31:0];
    
    reg start_keygen, start_encrypt;
    
    wire key_valid, encrypt_valid, enc_busy;
    
    keygen_32 speck_keygen(.clock(clock), .reset(resetn), .ukey(master_key), .ukey_valid(start_keygen), .allRoundKeys(allKeys), .key_ready(key_valid));
    
    
    encrypt speck_enc (.clock(clock), .reset(resetn), .din(din), .allRoundKeys(allKeys), .din_valid(start_encrypt), .dout_ready(encrypt_valid), .busy(enc_busy), .dout(dout));     
    
    
    // --------------------------------------------------------------------------------
            // Main State Machine
            // --------------------------------------------------------------------------------
              always @( now_state or enc_dec or key_exp or start or  key_valid or encrypt_valid or enc_busy) begin
                case ( now_state )
                  `IDLE       : if ( key_exp == 1'b1 ) begin
                                     next_state <= `KEY_EXP;       // Idle
                                     start_keygen <= 1'b1;
                                     text_val <= 1'b0;
                                     key_val <= 1'b0;
                                     busy <= 1'b0;
                                end
                                else if ( start == 1'b1 ) begin
                                    if ( key_valid == 1'b0 ) begin 
                                        next_state <= `KEY_EXP;       // Idle
                                        start_keygen <= 1'b1;
                                    end
                                    else next_state = `ROUND_LOOP;
                                end
                                else next_state = `IDLE;
                  `KEY_EXP    : if ( key_valid == 1'b1) begin
                                    next_state = `ROUND_LOOP;         // Key Expansion state
                                    key_val <= 1'b1;
                                    
                                end
                                else next_state = `KEY_EXP;
                  `ROUND_LOOP : begin
                                    busy <= enc_busy;
                                    if(start_encrypt == 1'b0) begin
                                     start_encrypt <= 1'b1;
                                     
                                    end
                                    if(encrypt_valid == 1'b1 ) begin
                                    text_val <= 1'b1;
                                    
                                    next_state = `IDLE;         // Cipher/Invese Cipher state
                                    end
                                    else next_state = `ROUND_LOOP;
                                end
                                
                   default    : next_state = `IDLE;
                endcase
              end

    
    
   always @(posedge clock or negedge resetn) begin
                if ( resetn == 1'b0 ) begin
                    now_state <= `IDLE;
                    start_encrypt <= 0;
                    start_keygen <= 0;
                end
                else now_state <= next_state;
              end

assign text_out = dout;              
               
endmodule
