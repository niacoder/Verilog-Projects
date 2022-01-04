`timescale 1ns / 1ps

// define functions names for readability (uses 4-bit control line values)
`define OP_LDUR (4'b0010)
`define OP_STUR (4'b0010)
`define OP_CBZ (4'b0111)
`define OP_ADD (4'b0010)
`define OP_SUB (4'b0110)
`define OP_AND (4'b0000)
`define OP_ORR (4'b0001)

// define cpu module
module cpu(
    
    // define clk and reset as inputs
    input clk,
    input reset,

    input [63:0] read_data, // output from data_RAM acts as input for cpu
    input [31:0] ins_reg,   // output from ins_RAM acta as input for cpu
    
    // define outputs which will act as inputs for data_RAM and ins_RAM 
    output reg MemWrite,
    output reg ALU_zeroflag,
    output [63:0] mem_addr,
    output [63:0] write_data,
    output reg [4:0] read_addr
    );
  
    reg [63:0] regfile [0:31]; // register file array
    reg [63:0] ins_file [0:31]; // instruction file array
  
    // define wires for data1 and data2 of register file from ARM datapath  
    wire [63:0] regfile_data1;
    wire [63:0] regfile_data2;

    wire [63:0] write_back; // write back from data RAM to register file
  
    reg [3:0] ALU_CTRL; // define 4-bit ALU control line
 
    wire [10:0] opcode; // define 11-bits for opcode (R-Type only)
 
  // define control lines from ARM datapath
  reg Reg2Loc;
  reg Branch;
  reg un_Branch;
  reg MemRead;
  reg MemtoReg;
  reg [1:0] ALUOp;
  reg ALUSrc;
  reg RegWrite;
  
 
  // instruction register wires
  reg [63:0] ins_extend;
  wire [63:0] ALU_mux;
  wire [63:0] data_mux;
  reg [63:0] ALU_result;
  
 
  //assign data1 and data2 in regfile to correct bits of instruction
  assign regfile_data1 = regfile[ins_reg[9:5]];
  assign regfile_data2 = Reg2Loc ? regfile[ins_reg[4:0]] : regfile[ins_reg[20:16]]; //mux for regfile_data2
  

  // write back process
  always @ (posedge clk)
     begin
        if (RegWrite)
           begin
              regfile[ins_reg[4:0]] = write_back;
           end
     end
  
  // instruction sign extend based on format type   
  always @ (*)
    begin
     ins_extend = 0; //initilaize ins_extend
        if ((ALU_CTRL == `OP_LDUR) | (ALU_CTRL == `OP_STUR)) 
            ins_extend = {{55{ins_reg[20]}}, ins_reg[20:12]}; // D-format
        else if(ALU_CTRL == `OP_CBZ)
            ins_extend = {{45{ins_reg[23]}}, ins_reg[23:5]}; // CB-format
        else if(opcode == 6'b000101)
            ins_extend = {{38{ins_reg[25]}}, ins_reg[25:0]}; // B-format
        else
            ins_extend = {{32{ins_reg[31]}}, ins_reg}; // R-format
    end
    

  
  assign  ALU_mux = ALUSrc ? ins_extend : regfile_data2; // ALU mux for ALU second input (select between ins_extend or regfile_data2
  
   
  // ALU mini module:
  // use case statements to determine ALU operation based on instruction type  
  always @ (*)
     begin
    ALU_zeroflag = 0;
    ALU_result = 0;
     
        case(ALU_CTRL)
            4'b0010: // LDUR and STUR both have ALU function as addition
                ALU_result = regfile_data1 + ALU_mux;
             
            4'b0111: // CBZ
               begin
                //  ALU_result = ALU_mux;
                  ALU_result = regfile_data2;
                  
                if (ALU_result == 0)
                  begin
                   ALU_zeroflag = 1; 
                  end
                end
                
           4'b0010:// R-Type ADD
              ALU_result = regfile_data1 + ALU_mux;
             
           4'b0110: // R-Type SUB
              ALU_result = regfile_data1 - ALU_mux;
              
           4'b0000:// R-Type AND
              ALU_result = regfile_data1 & ALU_mux;
              
           4'b0001:// R-Type OR
              ALU_result = regfile_data1 | ALU_mux;
         endcase
     end
     

  assign opcode = ins_reg[31:21]; // assign opcode to first 11 bits of instruction (used for R-type ALU control)
  
   always @ (*)  // process to set control lines based on instruction type
    begin 
        //initilaize control lines
        Reg2Loc = 0;
        ALUSrc = 0;
        MemtoReg = 0;
        RegWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        Branch = 0;
        un_Branch = 0;
        ALUOp = 2'b00;
        ALU_CTRL = 4'b0000;
    
        if ((ins_reg[31] == 1'b1) && (ins_reg[28:25] == 4'b0101) && (ins_reg[23:21] == 3'b000)) // R-Type case
            begin
                Reg2Loc = 0;
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                ALUOp = 2'b01;
                
               //ALU control for R-type depends on instruction
                if (opcode == 11'b10001011000) // add
                  ALU_CTRL = 4'b0010;
                else if (opcode == 11'b11001011000) // sub
                  ALU_CTRL = 4'b0110;
                else if (opcode == 11'b10001010000) // and
                  ALU_CTRL = 4'b0000;
                else if (opcode == 11'b10101010000) // orr
                  ALU_CTRL = 4'b0001;
           
            end
        else if(ins_reg[31:21] == 11'b11111000010) // LDUR case
            begin
                ALUSrc = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                Branch = 0;
                ALUOp = 2'b00;
                
                ALU_CTRL = 4'b0010;
            end
            
        else if(ins_reg[31:21] == 11'b11111000000) // STUR case
            begin
                Reg2Loc = 1;
                ALUSrc = 1;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                Branch = 0;
                ALUOp = 2'b00;
                
                ALU_CTRL <= 4'b0010;
            end
            
        else if(ins_reg[31:24] == 8'b10110100) // CBZ case
             begin
                Reg2Loc = 1;
                ALUSrc = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 1;
                ALUOp = 2'b01;
                
                ALU_CTRL = 4'b0111;
             end
   
        else if(ins_reg[31:26] == 6'b000101) // Unconditional Branch case
             begin
                  un_Branch = 1;
            
             end
        else
        begin
       
            $display("Error: The current instruction is invalid");
            $finish;
        end
    end
    
    
    assign write_back = MemtoReg ? read_data : ALU_result; // set write_back to data_mux result
    
    // define PC variables
    reg [4:0] PC;
    reg [4:0] nextPC;

 // assign nextPC according to logic gates from datapath
 always @ (*)
    begin
        if ((un_Branch | (Branch & ALU_zeroflag)))
            nextPC = PC + (ins_extend * 1);
        else
            nextPC = PC + 1;
    end

 
    //PC block
    always @ (posedge clk)
       begin
           if (reset) // at reset PC gets 0
             begin
                PC <= 0;
             end
          else
             begin
                PC <= nextPC; // else PC gets nextPC
             end
       end
     

assign write_data = regfile_data2; // assign write_data to regfile_data2 to go into data_RAM


// instantiate data RAM module
    data_RAM dataRam(
    .clk(clk),
    .reset(reset),
    .mem_addr(ALU_result),
    .write_data( write_data),
    .read_data(read_data),
    .MemWrite(MemWrite),
    .MemRead(MemRead)
    );

// instantiate ins RAM module
    ins_RAM insRam(
    .read_addr(PC),
    .ins_reg(ins_reg)
    );
    
endmodule

