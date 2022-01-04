`timescale 1ns / 1ps



module ins_RAM(
    input clk,
    input reset,
    input [4:0] read_addr,
    output [31:0] ins_reg
    );
    
 reg [63:0] ins_file [0:31];
 
 assign ins_reg = ins_file[read_addr];
 
endmodule

