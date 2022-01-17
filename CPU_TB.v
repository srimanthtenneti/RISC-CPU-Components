`timescale 1ns/100ps

module CPU_TB();
  
  reg clk;
  reg rst;
  wire HALT;
  
  integer i;
  
  initial
    begin
       clk = 0;
       rst = 1;
       #5 rst = 0;
      forever #2 clk = ~ clk;
      
    end
  
  CPU cpu0(
    .clk(clk),
    .rst(rst),
    .HALT(HALT)
  );
  
  initial
    begin
      $dumpfile("CPU.vcd");
      $dumpvars(1 , CPU_TB);
      #10;
      for (i = 0 ; i < 31 ; i = i + 1)
        begin
          cpu0.mem[i] = 8'b0;
        end
      cpu0.ac = 8'b1010_1010;
      cpu0.pc = 5'b0;
    end
 
  
  initial
    begin
      #10;
      $readmemb("memory.mem", cpu0.mem);
    end
  
  initial
    begin
      #15;
      for(i = 0; i < 31; i = i + 1)
        begin
          $display("Mem Location : %d, Value : %b,  HALT : %b", i, cpu0.mem[i], HALT);
          $display("Instr : %b,  Opcode : %b ,Operand : %b ,  PC : %b , AC : %b\n", cpu0.instr, cpu0.opcode,cpu0.operand,  cpu0.pc, cpu0.ac);
          $display("Rvalue : %b\n", cpu0.rvalue);
          #2;
        end
      #100 $finish;
    end
  
endmodule
  
  
