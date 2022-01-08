`timescale 1ns / 1ps

module testbench();

//define wires for output and reg values for stimuli and input
 wire carry_out; 
 reg [3:0] stim_ALU_CTRL;
 wire [63:0] ALU_OUTPUT;
 reg [63:0] stim_SRC1;
 reg [63:0] stim_SRC2;
 wire Zero;
 
//define integers to be used in for-loops below (counters)
 integer op_index;
 integer rand_case;
 
//define function names
  `define FN_AND (4'b0000)
  `define FN_OR (4'b0001)
  `define FN_Add (4'b0010)
  `define FN_Subtract (4'b0110)
  `define FN_PassInputB (4'b0111)
  `define FN_NOR (4'b01100)
 
 initial
 begin
    //Outer for-loop within initial block:
    //Test each case from 0-5 to test all 6 operations in simulation
    for(op_index = 0;op_index < 6;op_index = op_index+1)
    begin
        case(op_index)
            0: stim_ALU_CTRL = `FN_AND;
            1: stim_ALU_CTRL = `FN_OR;
            2: stim_ALU_CTRL = `FN_Add;
            3: stim_ALU_CTRL = `FN_Subtract;
            4: stim_ALU_CTRL = `FN_PassInputB;
            5: stim_ALU_CTRL = `FN_NOR; 
         endcase

  //Define corner cases(4) w/ delays in between:
		  //Corner case for two 64-bit 0’s
            stim_SRC1 = 64'h0; stim_SRC2 = 64'h0;
		  
  		  //Corner case for one 64-bit F’s, one 64-bit 0’s
        #10 stim_SRC1 = 64'hFFFF_FFFF_FFFF_FFFF; stim_SRC2 = 64'h0;
		  //Corner case for one 64-bit 0’s, one 64-bit F’s
        #10 stim_SRC1 = 64'h0; stim_SRC2 = 64'hFFFF_FFFF_FFFF_FFFF;

		  //Corner case for two 64-bit F’s
        #10 stim_SRC1 = 64'hFFFF_FFFF_FFFF_FFFF; stim_SRC2 = 64'hFFFF_FFFF_FFFF_FFFF;
 
	    //Nested for-loop:
	    //Generate random cases to test in each of the 6 operations
         for(rand_case = 0; rand_case<100; rand_case = rand_case + 1)
         begin
             #10 
             stim_SRC1 = {$urandom(), $urandom()};
             stim_SRC2 = {$urandom(), $urandom()};
         end
     end    
 end
 
//instantiate the DUT with proper port names
alu test ( 
 .SRC1(stim_SRC1),
 .SRC2(stim_SRC2),
 .ALU_CTRL(stim_ALU_CTRL),
 .ALU_OUTPUT(ALU_OUTPUT),
 .Zero(Zero)
