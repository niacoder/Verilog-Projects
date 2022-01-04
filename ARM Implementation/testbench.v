`timescale 1ns / 1ps


module testbench();

reg clk;
reg reset;


//generate clk signal
initial
   begin
      clk <= 1;
      while (1)
      #5 clk <= ~clk;
   end


 wire [63:0] read_data;
 wire [31:0] ins_reg;
 wire MemWrite;
 wire ALU_zeroflag;
 wire [63:0] mem_addr;
 wire [63:0] write_data;
 wire [4:0] read_addr;

//generate reset signal
initial
   begin
      reset = 1;
      #11 reset <=0;
   end

initial
    begin
$readmemb("H:/Lab5/Lab5.srcs/sources_1/imports/Desktop/ins_reg.txt", john.insRam.ins_file);

$readmemh("H:/Lab5/Lab5.srcs/sources_1/imports/Desktop/reg_file.txt", john.regfile);
    end
    
    // instantiate cpu
    cpu john (
    .clk(clk),
    .reset(reset),

    .read_data(read_data),
    .ins_reg(ins_reg),
    .MemWrite(MemWrite),
    .ALU_zeroflag(ALU_zeroflag),
    .mem_addr(mem_addr),
    .write_data(write_data),
    .read_addr(read_addr)
    );
    

endmodule
