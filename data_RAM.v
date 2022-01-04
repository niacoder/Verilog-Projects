`timescale 1ns / 1ps



module data_RAM(
    input clk,
    input reset,
    input [63:0] mem_addr,
    input MemWrite,
    input [63:0] write_data,
    output reg [63:0] read_data,
    input MemRead
    );
    
    reg [63:0] data_file [0:31];
    
    always @ (*)
    begin
        if(MemRead)
            read_data = data_file[mem_addr];
        else if (MemWrite)
             data_file[mem_addr] = write_data;
    end
        

    
endmodule
