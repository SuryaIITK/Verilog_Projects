`include "mips32.v"
module test_mips32;
   reg clk1 ,clk2 ;
   integer k;
pipe_MIPS32 mips (clk1, clk2);
   
  initial 
    begin
	  clk1 = 0; clk2 = 0;
	 repeat (50) // Gene:
	 begin
	  #5 clk1 = 1; #5 clk1 = 0;
	  #5 clk2 = 1; #5 clk2 = 0;
	 end
   end
  
 initial
   begin
     for (k=0; k<31; k++)
	 mips.Reg[k] = k;
     
     mips.Mem[0] = 32'h28010080; // ADDI R1,R0,128
     
	 mips.Mem[1] = 32'h0c631800; // OR R3,R3,R3 -- dummy
     
	 mips.Mem[2] = 32'h20220000; // LW R2,0(R1)
     
	 mips.Mem[3] = 32'h0c631800; // OR R3,R3,R3 —- dummy
     
	 mips.Mem[4] = 32'h28420032; // ADDI R2,R2,50
     
	 mips.Mem[5] = 32'h0c631800; // OR R3,R3,R3 --- dummy
     
	 mips.Mem[6] = 32'h24220001; // SW R2,1(R1)
     mips.Mem[7] = 32'hfc000000; // HLT
     mips.Mem[128] = 100;
     
     mips.PC = 0;
     mips.HALTED = 0;
     mips.TAKEN_BRANCH = 0;
     #500 $display ("Mem[128]: %4d \nMem[129]: %4d",mips.Mem[128],mips.Mem[129]);
   end
   
  initial 
   begin
    $dumpfile ("mips .vcd");
    $dumpvars (0, test_mips32);
    #600 $finish;
   end
  
endmodule
   