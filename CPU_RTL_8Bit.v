`timescale 1ns/100ps

module CPU(
  input  clk,
  input  rst,
  output HALT
);
  
  reg [4:0] pc; // Program Counter
  reg [7:0] ac; // Accumulator
  
  reg [7:0] mem [0:31]; // Memory
  
  wire [7:0] instr = mem[pc]; // Instruction
  wire [2:0] opcode = instr[7:5]; // Opcode
  wire [4:0] operand = instr[4:0]; 
  wire [7:0] rvalue = mem[operand];
  
 
  always @ (posedge clk)
    if (rst)
      pc <= 0;
    else
      begin
        case(opcode)
          3'b000 : begin
             pc <= pc; // HALT : HLT Instruction
          end
          
          3'b001 : begin
            pc <= pc + 1 + (!ac); // Skip if zero : SKZ
          end 
          
          3'b010 : begin
            ac <= ac + rvalue; // Addition : ADD
            pc <= pc + 1;
          end 
          
          3'b011 : begin
             ac <= ac & rvalue; // And Operation : AND
             pc <= pc + 1;
          end
          
          3'b100 : begin
             ac <= ac ^ rvalue; // XOR Operation : XOR
             pc <= pc + 1; 
          end
          
          3'b101 : begin
             ac <= rvalue; // Load Accumulator : LDA
             pc <= pc + 1;
          end
          
          3'b110 : begin
            mem[operand] <= ac; // Store  : STO
            pc <= pc + 1;
          end
          
          3'b111 : begin
             pc <= operand; // JMP Instruction
          end
        endcase
      end
    assign HALT = opcode == 0;
endmodule
