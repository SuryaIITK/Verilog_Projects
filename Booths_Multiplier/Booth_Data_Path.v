//Data Path Implementation
module booth_data_path(data_in,eqz,Q0,Q_1,clear_A,load_A,shift_A,load_M,clear_Q,load_Q,shift_Q,clear_ff,load_count,decr,addsub,clk,product);
	input  clear_A,load_A,shift_A,load_M,clear_Q,load_Q,shift_Q,clear_ff,load_count,decr,addsub,clk; 
	input [7:0] data_in;
	output eqz,Q0,Q_1;
	output reg [15:0] product;
	wire  [7:0] A,M,Q,Z;
	wire  [3:0] count;
	assign eqz = ~|count;  				// The eqz will be set once the count reaches to zero (3'b000)
	assign Q0 = Q[0]; 					// The LSB of Register QSR will be loaded into Q0 which will act as input to flip flop. 
	
	// Module Instantiation 
	shift_reg  SHFT_Q (Q,data_in,A[0],clear_Q,load_Q,shift_Q,clk) ;   // Reg Q
	shift_reg  SHFT_A (A,Z,A[3],clear_A,load_A,shift_A,clk);		// Reg A	
	PIPO   PIPO_M (M,data_in,load_M,clk); 			//Reg M 
	D_FlipFlop  D_Q_1 (Q_1,Q0,clear_ff,clk);		//D Flip Flop (for Q_1)
	ALU  Add_Sub (Z,A,M,addsub);					//ALU for adding and subtracting
	COUNTER  CNTR (count,load_count,decr,clk);		//Counter 
	always@(*) begin
	if (eqz)
	product = {A , Q};
	end
endmodule

//Shift Register 
module shift_reg(d_out,d_in,s_in,clear,load,shift,clk); 
	input [7:0] d_in ;
	input s_in,load,shift,clk,clear;
	output reg [7:0] d_out; 
	always @ (posedge clk)
		if (clear)
			d_out <= 8'b0;
		else if(load)   				// If Load signal is high the data from the bus will be loaded. 
			d_out <= d_in;
		else if (shift)					// If Shift signal is high then bits will be shifted serially. 
			d_out <= {s_in,d_out[7:1]};
endmodule 

//PIPO Shift Register 
module PIPO(p_out,p_in,load_p,clk); 
	input [7:0] p_in;
	input load_p, clk;
	output reg [7:0]p_out; 
		
	always@(posedge clk)	
		if(load_p)						// If Load signal is high the data from the bus will be loaded. 
			p_out <= p_in; 
endmodule 

//D Flip Flop 
module D_FlipFlop (q,d,clear,clk); 		// D FF is used to store the Q_1 bit. 
	input d,clear,clk; 
	output reg q;
		
	always @ (posedge clk)
		if (clear)					// If clear is high FF will be cleared else the value of D will be loaded. 
			q <= 1'b0;
		else 
			q <= d;
endmodule 

//ALU     
module ALU (out,a,b,select);				// The ALU is assigned the operation of addition or subtraction depend_ing on the select. 
	input [7:0] a, b ;
	input select ;
	output reg [7:0] out; 
	wire [7:0] sum,difference;
	Adder8bit adder(a,b,1'b0,sum,c_out);
	Adder8bit subtracter (a,~b,1'b1,difference,c_out);
	always @ (*)
		if (select)
			out = sum ;
		else
			out = difference; 
endmodule 

//Counter 
module COUNTER (d_out,ld_cnt,decr_C,clk); 			// This down counter is used to count the number of cycles to be executed.   
	input decr_C,clk,ld_cnt; 
	output reg [3:0] d_out;

	always @(posedge clk)
		if (ld_cnt ==1'b1)
			d_out <= 4'b1000; 			//The inital value loaded in counter will be same as that of the number of bits (here 5 bit).
		else if (decr_C)
			d_out <= d_out - 1 ;
endmodule


module Adder4bit(input [3:0] a,input [3:0] b,input cin,output [3:0]sum,output cout);
	wire g0,g1,g2,g3,p0,p1,p2,p3,c2,c1,c0;
	assign g0 = a[0]&b[0];
	assign g1 = a[1]&b[1];
	assign g2 = a[2]&b[2];
	assign g3 = a[3]&b[3];
	assign p0 = a[0]^b[0];
	assign p1 = a[1]^b[1];
	assign p2 = a[2]^b[2];
	assign p3 = a[3]^b[3];
	assign c0 = g0 |( p0 & cin);
	assign c1 = g1 | (p1&g0)| (p1&p0&cin);
	assign c2 = g2 | (p2&g1) | (p2&p1&g0) | (p2&p1&p0&cin);
	assign cout = g3 | (p3&g2) | (p3&p2&g1) | (p3&p2&p1&g0) | (p3&p2&p1&p0&cin);

	xor(sum[0],p0,cin);
	xor(sum[1],p1,c0);
	xor(sum[2],p2,c1);
	xor(sum[3],p3,c2);

endmodule

module Adder8bit(input [7:0] a,input [7:0] b,input cin,output [7:0]sum,output cout);
	Adder4bit ADD01(.a(a[3:0]),.b(b[3:0]),.cin(cin),.sum(sum[3:0]),.cout(ctemp));
	Adder4bit ADD02(.a(a[7:4]),.b(b[7:4]),.cin(ctemp),.sum(sum[7:4]),.cout(cout));
endmodule