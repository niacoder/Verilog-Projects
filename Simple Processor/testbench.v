`timescale 1ns / 1ps


//define testbench
module testbench();

//define wires and reg values
    reg clk;//clk
    reg reset;//reset
    wire AM;//addressing mode
    wire [4:0] cur_cpu_state;//current cpu state
    
    //generate clk signal
    initial
       begin
          clk <= 1;
          while (1)
              # 5 clk <= ~clk;
       end
       
    //generate reset signal 
    initial
       begin
          reset = 1;
          #17 reset <= 0;
       end
    
    //read data file with HEX instructions for simple processor
    initial 
        begin
    $readmemh( "H:/data_file.txt", kevin.data_arr);
         end
    
    //instantiate cpu module with proper port names
    cpu kevin (
    .clk(clk),
    .reset(reset),
    .cur_cpu_state(cur_cpu_state)
    );

endmodule

