`timescale 1ns / 1ns

module address_mux #(parameter WIDTH = 5) (
  
  input [WIDTH - 1 : 0] in0,
  input [WIDTH - 1 : 0] in1,
  input sel,
  output [WIDTH - 1 : 0]out

); 
  
  assign out = (sel) ? in1 : in0;
  
endmodule

module bus_driver #(parameter WIDTH = 8) (
  
  input [WIDTH - 1 : 0] data_in,
  input data_en,
  output [WIDTH - 1 : 0] data_out
  
); 
  
  assign data_out = (data_en) ? data_in : {WIDTH{1'hz}};
  
endmodule

module alu #(parameter WIDTH = 8) (
  
  input [WIDTH - 1 : 0] in_a,
  input [WIDTH - 1 : 0] in_b,
  input [$clog2(WIDTH) -1 : 0] opcode,
  output [WIDTH - 1 : 0] alu_out,
  output a_is_zero

);
  
  reg [WIDTH - 1 : 0] result;
  
  always @ (in_a, in_b, opcode)
    begin
      case(opcode)
        3'b000 : result = in_a;
        3'b001 : result = in_a;
        3'b010 : result = in_a + in_b;
        3'b011 : result = in_a & in_b;
        3'b100 : result = in_a ^ in_b;
        3'b101 : result = in_b;
        3'b110 : result = in_a;
        3'b111 : result = in_a;
        default : result = {WIDTH{1'b0}};
      endcase
    end
  
  assign a_is_zero = (result) ? 1'b0 : 1'b1;
  assign alu_out = result;
  
endmodule


module cpu_controller #(parameter op_width = 3,  max_phase = 8)(
  input [op_width -  1 : 0] opcode,
  input a_zero,
  input [max_phase - 1 : 0] phase,
  output sel, // Select signal
  output rd, // Read signal
  output ld_ir, // Load instruction
  output inc_pc, // Increment program counter
  output halt, // To HALT CPU Activity
  output ld_pc, // To Load Program Counter
  output data_e, // Data enable for Bus_Driver
  output load_ac, // Loading Accumulator
  output wr // Write Signal
);
  
  reg sel_, rd_, ld_ir_, inc_pc_, halt_, ld_pc_, data_e_, load_ac_, wr_; 
  reg H, J, A, Z , S;
  
  always @ (opcode, a_zero, phase)
    begin
      A = (opcode == 3'b010 | opcode == 3'b011 | opcode == 3'b100 | opcode == 3'b101) ? 1'b1 : 1'b0;
      H = (opcode == 3'b000) ? 1'b1 : 1'b0;
      Z = (opcode == 3'b100 && a_zero) ? 1'b1 : 1'b0;
      J = (opcode == 3'b111) ? 1'b1 : 1'b0;
      S = (opcode == 3'b110) ? 1'b1 : 1'b0;
      case (phase)
        8'd0 : begin
           sel_     = 1;
           rd_      = 0;
           ld_ir_   = 0;
           inc_pc_  = 0;
           halt_    = 0;
           ld_pc_   = 0;
           data_e_  = 0;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd1 : begin
           sel_     = 1;
           rd_      = 1;
           ld_ir_   = 0;
           inc_pc_  = 0;
           halt_    = 0;
           ld_pc_   = 0;
           data_e_  = 0;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd2 : begin
           sel_     = 1;
           rd_      = 1;
           ld_ir_   = 1;
           inc_pc_  = 0;
           halt_    = 0;
           ld_pc_   = 0;
           data_e_  = 0;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd3 : begin
           sel_     = 1;
           rd_      = 1;
           ld_ir_   = 1;
           inc_pc_  = 0;
           halt_    = 0;
           ld_pc_   = 0;
           data_e_  = 0;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd4 : begin    // Segment that Deals with HALT
          
           sel_     = 0;
           rd_      = 0;
           ld_ir_   = 0;
           inc_pc_  = 1;
           halt_    = H;
           ld_pc_   = 0;
           data_e_  = 0;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd5 : begin // If the instruction needs the acculumatlor this comes into play
           
           sel_     = 0;
           rd_      = A;
           ld_ir_   = 0;
           inc_pc_  = 0;
           halt_    = 0;
           ld_pc_   = 0;
           data_e_  = 0;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd6 : begin
           
           sel_     = 0;
           rd_      = A;
           ld_ir_   = 0;
           inc_pc_  = Z;
           halt_    = 0;
           ld_pc_   = J;
           data_e_  = S;
           load_ac_ = 0;
           wr_      = 0;
        end
        8'd7 : begin
          
           sel_     = 0;
           rd_      = A;
           ld_ir_   = 0;
           inc_pc_  = 0;
           halt_    = 0;
           ld_pc_   = J;
           data_e_  = S;
           load_ac_ = A;
           wr_      = S;
        end
      endcase
    end
      assign sel = sel_;
      assign rd = rd_;
      assign ld_ir = ld_ir_;
      assign inc_pc = inc_pc_;
      assign halt = halt_;
      assign ld_pc = ld_pc_;
      assign data_e = data_e_;
      assign load_ac = load_ac_;
      assign wr = wr_;

endmodule
      
module register #(parameter WIDTH = 8) (
  input clk,
  input rst,
  input [WIDTH - 1 : 0] data_in,
  input load,
  output [WIDTH - 1 : 0] data_out
); 
  
  reg [WIDTH - 1 : 0] data_out_;
  
  always @ (posedge clk)
    begin
      if (rst)
        data_out_ <= {WIDTH{1'b0}};
      else
        begin
          if (load)
            data_out_ <= data_in;
          else
            data_out_ <= data_out_;
        end
    end 
  
  assign data_out = data_out_;
  
endmodule
  
module memory #(parameter A_WIDTH = 5, D_WIDTH = 8)(
   input clk,
   input wr,
   input rd,
   input [A_WIDTH -1 : 0] addr,
   inout [D_WIDTH -1 : 0] data
); 
  
  reg [D_WIDTH -1 : 0] data_;
  reg [D_WIDTH - 1 : 0] mem [2**A_WIDTH -1 : 0];
  
  always @ (posedge clk)
    begin
      if(wr)
        mem[addr] <= data_;
      else if (rd)
        data_ <= mem[addr];
      else
        data_ <= {D_WIDTH{1'hz}};
    end
   assign data = data_;
endmodule
            
