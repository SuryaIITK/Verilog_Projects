module Booths_Multiplier_tb ;
	//Port Section 
	reg clk ; 
	reg start ; 
	reg [7:0] data_in ;
	wire [15:0] product;
	wire done ; 
	wire[1:0] temp;
	
	//Module Instantiation 
	booth_data_path BOOTH_DP(data_in,eqz,Q0,Q_1,clear_A,load_A,shift_A,load_M,clear_Q,load_Q,shift_Q,clear_ff,load_count,decr,addsub,clk,product);
	booth_control_path BOOTH_CP(data_in,start,eqz,Q_1,Q0,shift_A,load_A,clear_A,load_M,load_Q,clear_Q,shift_Q,clear_ff,load_count,decr,addsub,clk,done);

	initial 
		begin
			clk  = 1'b0 ;
			start = 1'b1;
		end 
	always 
		#5 clk = ~ clk ; 		// Clk of Time period 10 Time units. 
	initial 
		begin
			data_in = 5; 		// Value of M 
			#27 data_in = 30 ; 	// Value of Q 
		end 
		
	initial 
		begin 
			$dumpfile ("Booths.vcd") ; 
			$dumpvars (0, Booths_Multiplier_tb) ; 
			$monitor ($time , " | M: %7b | A: %7b |  Q: %7b | Q_1: %b | COUNT: %3b | eqz: %b | STATE: %3b | DONE: %b |",
					BOOTH_DP.M, BOOTH_DP.A, BOOTH_DP.Q, BOOTH_CP.Q_1, BOOTH_DP.count, BOOTH_DP.eqz, BOOTH_CP.state, done) ; 
					
			wait(done);
			$display("\n");
			//$display("M (in decimal): %d", 5);         // Value of M
    //$display("Q (in decimal): %d", 30);        // Value of Q
			$display("Input Multiplicand M		   :    %b    %d)", 8'd5, 5);
			$display("Input Multiplier   Q		   :    %b    %d)", 8'd30, 30);
			$display("Final product after multiplication :    %b  %d)\n", product,product);
			//$display ("product %b",product);
			#1000 $finish ;
		end
endmodule

// ==============================================================================================