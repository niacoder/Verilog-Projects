`timescale 1ns / 1ps

//define inputs and outputs with proper bit-size
module alu(
  input [63:0] SRC1,
  input [63:0] SRC2,
  input [3:0] ALU_CTRL,
  output reg [63:0] ALU_OUTPUT,
  output reg Zero ); 
//define function names to use instead of binary notation
  `define FN_AND (4'b0000);
  `define FN_OR (4'b0001);
  `define FN_Add (4'b0010);
  `define FN_Subtract (4'b0110);
  `define FN_PassInputB (4'b0111);
  `define FN_NOR (4'b01100); 
//case statements inside always block to check for binary input and perform proper operation based on Table 1
  always @ (*)
  begin 
        case(ALU_CTRL)
        4'b0000: 
              ALU_OUTPUT = SRC1 & SRC2;
        4'b0001:
              ALU_OUTPUT = SRC1 | SRC2;
        4'b0010:
              ALU_OUTPUT = SRC1 + SRC2;
        4'b0110:
              ALU_OUTPUT = SRC1 - SRC2;
        4'b0111:
              ALU_OUTPUT = SRC2;
        4'b1100:
              ALU_OUTPUT = ~(SRC1 | SRC2);
        endcase
        
	   //if statement to set Zero to 1 if ALU output is 0
        if(ALU_OUTPUT == 0)
            Zero = 1;
        else 
            Zero = 0;
  end

endmodule
