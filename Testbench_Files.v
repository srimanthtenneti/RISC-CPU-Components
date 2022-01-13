/* 

Address Mux
-------------

`timescale 1ns/1ns

module address_mux_tb #(parameter WIDTH = 5)();
  
  reg [WIDTH - 1 : 0] in0, in1;
  reg sel;
  wire [WIDTH - 1 : 0] out;
  
  initial 
    begin
      in0 = {WIDTH{1'b0}};
      in1 = {WIDTH{1'b0}};
      sel = 0;
    end
  
  // DUT
  
  address_mux adm0 (
    .in0(in0),
    .in1(in1),
    .sel(sel),
    .out(out)
  );
  
  initial 
    begin
      $dumpfile("adm.vcd");
      $dumpvars(1 , address_mux_tb);
      #10 sel = 0; in0 = 5'b11111; in1 = 5'b10101;
      #10 sel = 1; in0 = 5'b00010; in1 = 5'b00111;
      #30 $finish;
    end
  
endmodule

*/

/* 

Bus Driver
-----------

`timescale 1ns/1ns

module bus_driver_tb #(parameter WIDTH = 8)();
  
  reg [WIDTH - 1 : 0] data_in;
  reg data_en;
  wire [WIDTH - 1 : 0] data_out;
  
  initial 
    begin
      data_in = {WIDTH{1'b0}};
      data_en = 0;
    end
  
  // DUT
  
  bus_driver bd0 (
    .data_in(data_in),
    .data_en(data_en),
    .data_out(data_out)
  );
  
  initial 
    begin
      $dumpfile("adm.vcd");
      $dumpvars(1 , bus_driver_tb);
      #10 data_in = {WIDTH{1'b1}};
      #10 data_en = 1;
      #50 $finish;
    end
  
endmodule

*/ 

/*

ALU
-----

module alu_tb #(parameter WIDTH = 8)();
  
  reg [WIDTH - 1 : 0] in_a;
  reg [WIDTH - 1 : 0] in_b;
  reg [$clog2(WIDTH) - 1 : 0] opcode;
  wire a_is_zero;
  wire [WIDTH - 1 : 0] alu_out;
  
  initial
    begin
      in_a = {WIDTH{1'b0}};
      in_b = {WIDTH{1'b0}};
      opcode = {$clog2(WIDTH){1'b0}};
    end
  
  // DUT
  alu alu0(
    .in_a(in_a),
    .in_b(in_b),
    .opcode(opcode),
    .alu_out(alu_out),
    .a_is_zero(a_is_zero)
  );
  
  initial 
    begin
      $dumpfile("alu.vcd");
      $dumpvars(1 , alu_tb);
      $monitor("in_a : %b, in_b : %b , opcode : %d, alu_out : %b, Zero ; %b", in_a,in_b,opcode,alu_out,a_is_zero);
      #10 in_a = 8'b0000_0001; in_b = 8'b0000_1111;
      #10 opcode = 3'b001;
      #10 opcode = 3'b010;
      #10 opcode = 3'b011;
      #10 opcode = 3'b100;
      #10 opcode = 3'b101;
      #10 opcode = 3'b110;
      #10 in_a = {WIDTH{1'b0}};
      #10 opcode = 3'b111;
      #200 $finish; 
    end
  
endmodule
  
*/

/*

module cpu_control_tb #(parameter op_width = 3,  max_phase = 8)();
  
  reg [op_width -  1 : 0] opcode;
  reg  a_zero;
  reg  [max_phase - 1 : 0] phase;
  wire sel;// Select signal
  wire rd;// Read signal
  wire ld_ir;// Load instruction
  wire inc_pc;// Increment program counter
  wire halt;// To HALT CPU Activity
  wire ld_pc;// To Load Program Counter
  wire data_e;// Data enable for Bus_Driver
  wire load_ac; // Loading Accumulator
  wire wr; // Write Signal
  
  integer i, j;
  
  initial
    begin
       opcode = 0;
       a_zero = 0;
       phase = 0;
    end
  
  // DUT
  
  cpu_controller c0(
    .opcode(opcode),
    .a_zero(a_zero),
    .phase(phase),
    .sel(sel),
    .rd(rd),
    .ld_ir(ld_ir),
    .inc_pc(inc_pc),
    .halt(halt),
    .ld_pc(ld_pc),
    .data_e(data_e),
    .load_ac(load_ac),
    .wr(wr)
  );
  
  initial
    begin
      $dumpfile("controller.vcd");
      $dumpvars(1 , cpu_control_tb);
      for (i = 0 ; i < 8 ; i = i + 1)
        begin
          for (j = 0 ; j < 8 ; j = j + 1)
            begin
              #10
              opcode = i;
              phase = j; 
            end
        end
      #1000 $finish;
    end
endmodule
  
*/

/* 

`timescale 1ns / 1ns

module register_tb #(parameter WIDTH = 8)();
  
  reg clk;
  reg rst;
  reg [WIDTH - 1 : 0] data_in;
  reg load;
  wire [WIDTH - 1 : 0] data_out;
  
  integer i;
  
  initial
    begin
       clk = 0;
       rst = 1;
       data_in = {WIDTH{1'b0}};
       load = 0;
       forever #5 clk = ~clk;
    end
  
  // DUT
  register r0(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .load(load),
    .data_out(data_out)
  );
  
  task load_data(input [WIDTH - 1 : 0] data_i);
    begin
       load = 1;
       data_in = data_i;
    end
  endtask
  
  initial 
    begin
      $dumpfile("Register.vcd");
      $dumpvars(1 , register_tb);
      #10 rst = 0;
      for (i = 0; i < 31 ; i = i + 1)
        begin
          #10 load_data(i); 
          #5 load = 0;
        end
      #1000 $finish;
    end
endmodule

*/ 
