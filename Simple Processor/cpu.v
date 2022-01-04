`timescale 1ns / 1ps

//define all 17 states w/ respective function names for readability
`define S0 (0)
`define S1 (1)
`define S2 (2)
`define S3 (3)
`define S4 (4)
`define S5 (5)
`define S6 (6)
`define S7 (7)
`define S8 (8)
`define S9 (9)
`define S10 (10)
`define S11 (11)
`define S12 (12)
`define S13 (13)
`define S14 (14)
`define S15 (15)
`define S16 (16)

//define opcode function names
`define FN_NOT (3'b000)
`define FN_ADC (3'b001)
`define FN_JPA (3'b010)
`define FN_INCA (3'b011)
`define FN_STA (3'b100)
`define FN_LDA (3'b101)

//define cpu module
module cpu(

//define inputs
    input clk,
    input reset,
    
//define output 
    output reg [4:0] cur_cpu_state
    );
    
    //internal reg next_cpu_state
    reg [4:0] next_cpu_state;
    wire [2:0] opcode;
    reg [15:0] AC;
    reg [15:0] IR; //instruction register
    reg [15:0] MD; //memory data register
    reg [11:0] PC; //program counter
    reg [11:0] MA; //memory address
    reg [15:0] data_arr[0:31]; // memory address register
    reg carry; // 1-bit carry
    wire alu_zeroflag; //alu zero flag
    wire AM; //addressing mode
    
    //set alu zero flag when accumulator == 0
    assign alu_zeroflag = (AC == 0);
    
    //set addressing mode to 12th bit of instruction register
    assign AM = IR[12];
    
    //set opcode to first 3 bits of instruction register
    assign opcode = IR[15:13]; 
    
    //define state machine
    always @ (posedge clk) 
        begin
        //set first state to S0 at the beginning 
        if(reset) 
            cur_cpu_state <= `S0;
        else
        //set current state to get the next state each update 
            cur_cpu_state <= next_cpu_state;
        end
    
    //set state machine according to flow diagram
    always @ (*) 
    begin
        next_cpu_state = `S0;
        
        //use case statement to check current cpu state
        case(cur_cpu_state) 
            `S0://from S0 next state is S1 
                next_cpu_state = `S1;
            `S1://from S1 check opcode
            //if opcode is NOT instruction next state is S2 
                if(opcode == `FN_NOT)
                    next_cpu_state = `S2;
            //if opcode is INCA instruction next state is S3
                else if(opcode == `FN_INCA)
                    next_cpu_state = `S3;
            //check if opcode is JPA instruction
                else if(opcode == `FN_JPA)
                    begin
                    //check if accumulator is greater than 0
                        if (AC > 0)
                            begin
                            //check addressing mode:
                            //if addressing mode is indirect, next state is S4, else next state is S7
                            if(AM == 1)
                                next_cpu_state = `S4;
                            else 
                                next_cpu_state = `S7;
                            end
                         //if accumulator not greater than zero, next state is S0   
                         else
                            next_cpu_state = `S0;
                    end
                 else
                 //if opcode does not match NOT, INCA, or JPA, next state is S8 
                    next_cpu_state = `S8;
                    
            `S2: //from S2 next state go back to S0
                next_cpu_state = `S0;
            `S3: //from S3 next state go back to S0
                next_cpu_state = `S0;
            `S4: //from S4 next state is S5
                next_cpu_state = `S5;          
            `S5: //from S5 next state is S6
                next_cpu_state = `S6;
            `S6: //from S6 next state go back to S0
                next_cpu_state = `S0;
            `S7: //from S7 next state go back to S0
                next_cpu_state = `S0;
            `S8: //at S8 check opcode:
                 //if opcode is not the STA instruction next state is S12
                if(opcode != `FN_STA)
                    next_cpu_state = `S12;
                 //if opcode is the STA instruction, check addressing mode
                else if(opcode == `FN_STA) 
                   //if addressing mode is direct, next state is S11
                    if(AM == 0)
                        next_cpu_state = `S11;
                    //if addressing mode is indirect, next state is S9
                    else if(AM == 1)
                        next_cpu_state = `S9;
            `S9: //from S9 next state is S10
                next_cpu_state = `S10;
            `S10: //from S10 next state is S11
                next_cpu_state = `S11;
            `S11: //from S11 next state goes back to S0
                next_cpu_state = `S0;
            `S12: //at S12, check addressing mode:
                //if addressing mode is direct, check for opcode
                if(AM == 0)
                    begin
                    //if opcode is not the ADC instruction, next state is S16
                    if(opcode != `FN_ADC)
                        next_cpu_state = `S16;
                    //if opcode is the ADC instruction, next state is S15
                    else if(opcode == `FN_ADC)
                        next_cpu_state = `S15;
                    end
                //if addressing mode is indirect, next state is S13
                else if (AM == 1)
                     next_cpu_state = `S13;
            `S13: //from S13 next state is S14
                next_cpu_state = `S14;
            `S14: //at S14, check opcode
                //if opcode is not the ADC instruction, next state is S16
                if(opcode != `FN_ADC)
                    next_cpu_state = `S16;
                //if opcode is the ADC instruction, next state is S15
                else if(opcode == `FN_ADC)
                    next_cpu_state = `S15;
            `S15: //from S15 next state goes back to S0
                next_cpu_state = `S0;
            `S16: //from S16 next state goes back to S0
                next_cpu_state = `S0;      
          endcase
    end

//Define states in state machine:

//Program Counter (PC) block:    
always @(posedge clk) 
begin
    //At the beginning PC gets 0
    if(reset)
    PC <= 0;
    //at S1 increment PC by 1
    else if(cur_cpu_state==`S1)
            PC <= PC+1;
    //at S6 PC gets memory data Register
    else if(cur_cpu_state == `S6)
            PC <= MD;
    //at S7 PC gets instruction register 
    else if(cur_cpu_state == `S7)
            PC <= IR; 
  end         
 
 //Accumulator (AC) block:           
always @(posedge clk) 
begin 
    //at the beginning AC and carry get 0
    if(reset)
        {carry, AC} <= 0;
    //at S2 AC is inverted     
    else if (cur_cpu_state ==`S2)
         AC <= ~AC;
    //at S3 AC increment by 1, and carry is set if there is a carry
    else if (cur_cpu_state ==`S3)
        {carry, AC} <= AC + 1;
   //at S11 AC and carry get 0
    else if (cur_cpu_state ==`S11)
        {carry, AC} <= 0;
    //at S15 AC gets sum of current accumulator, memory data register, and carry, and carry is set if there is a carry
    else if (cur_cpu_state ==`S15)
        {carry, AC} <= AC + MD + carry;
   //at S16 AC gets memory data register, and carry is set if there is a carry
    else if (cur_cpu_state ==`S16)  // LDA
        {carry, AC} <= MD;
end

//Memory Address (MA) block:
always @(posedge clk) 
begin 
    //at the beginning, MA gets 0
    if(reset)
        MA <= 0;
   //at S4 MA gets instruction register
    else if (cur_cpu_state ==`S4)
        MA <= IR;
   //at S8 MA gets instruction register
    else if (cur_cpu_state ==`S8)
        MA <= IR;
   //at S10 MA gets memory data register
    else if (cur_cpu_state ==`S10)
        MA <= MD;
   //at S11 index of the data array for the MA register gets the accumulator
    else if (cur_cpu_state ==`S11)
        data_arr[MA] <= AC;
   //at S13 MA gets memory data register
    else if (cur_cpu_state ==`S13) 
        MA <= MD;
end

//Memory Data (MD) block:
always @(posedge clk) 
begin 
    //at the beginning MD gets 0
    if(reset)
        MD <= 0;
    //at S5 MD gets contents of memory address register in data array
    else if (cur_cpu_state ==`S5)
        MD <= data_arr[MA];
    //at S9 MD gets contents of memory address register in data array
    else if (cur_cpu_state ==`S9)
        MD <= data_arr[MA];
    //at S12 MD gets content of memory address register in data array
    else if (cur_cpu_state ==`S12)
        MD <= data_arr[MA];
    //at S14 MD gets content of memory address register in data array
    else if (cur_cpu_state ==`S14)
        MD <= data_arr[MA];
end

//Instruction Register (IR) block:
always @(posedge clk) 
begin 
    //at the beginning IR gets 0
    if(reset)
        IR <= 0;
    //at S0 IR gets content of program counter in data array
    else if (cur_cpu_state == `S0)
        IR <= data_arr[PC];
end


endmodule
