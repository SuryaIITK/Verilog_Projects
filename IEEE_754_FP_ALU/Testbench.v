`timescale 1ns / 1ps
module Main_tb;
reg [31:0] n1;
reg [31:0] n2;
reg add;
reg sub;
reg mul;
wire [31:0] result;
wire [23:0]M1;
wire [23:0]M2;
wire [7:0] E1;
wire [7:0] E2;
wire [7:0] E_difference;
wire [7:0] larger_E;
wire sign;
wire [7:0] final_E;
wire [22:0] final_M;
wire [31:0] result1;
	// Instantiate the Unit Under Test (UUT)
	add_sub uut (
		.n1(n1), 
		.n2(n2), 
		.add(add), 
		.sub(sub), 
		.mul(mul),
		.result(result),
		.M1(M1),
		.M2(M2),
		.E1(E1),
		.E2(E2),
		.E_difference(E_difference),
		.larger_E(larger_E),
		.sign(sign),
		.final_E(final_E),
		.final_M(final_M),
		.result1(result1)
		);
	initial begin
	$dumpfile("surya.vcd");
	$dumpvars;
		// Initialize Inputs
//		n1 = 32'b01000011000011111000111101011100;    // 143.56
//		n2 = 32'b11000010101011101101111110111110;    // -87.437
//		n1 = 32'b01000000000000000000000000000000;
//		n2 = 32'b01000000010000000000000000000000;
		n1 = 32'b00111111100000000000000000000000; // 1.0
        n2 = 32'b01000000000000000000000000000000; // 2.0
        #10;
        
		add =1'b1; #50
		sub =1'b0; #50
		mul = 1'b0;#50
		$display("Addtion result : %b",result);
		$display("M1 	 : %b",M1);
		$display("M2 	 : %b",M2);
		$display("exponent1 : %b",E1);
		$display("exponent2 : %b",E2);
		$display("E_difference : %b",E_difference);	
		$display("larger_E:%b",larger_E);
		$display("sign : %b",sign);
		$display("final_E : %b",final_E);
		$display("final_M : %b",final_M);
		$display("Test Case 2: n1 = %h, n2 = %h, result1 = %h", n1, n2, result1);
	end     
endmodule