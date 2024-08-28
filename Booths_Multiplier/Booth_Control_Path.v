//Control Path 
module booth_control_path (data_in,start,eqz,Q_1,Q0,shift_A,load_A,clear_A,load_M,load_Q,clear_Q,shift_Q,clear_ff,load_count,decr,addsub,clk,done);
	output reg decr,load_count,shift_A,load_A,clear_A,load_M,load_Q,clear_Q,shift_Q,clear_ff,addsub,done;  
	input start,eqz,Q_1,Q0,clk; 
	input[7:0] data_in ;
	reg[2:0] state;
	
	//States
	parameter 	S0 = 3'b000,S1 = 3'b001,S2 = 3'b010,S3 = 3'b011,S4 = 3'b100,S5 = 3'b101,S6 = 3'b110;

	always@ (posedge clk) 
	//Implementation of State Diagram of control path 
	case (state)
		S0 	: 	if (start) state <= S1;
		S1 	: 	state <= S2;
		S2 	: 	#2 if ({Q0, Q_1} == 2'b01) state <= S3; 
				else if ({Q0, Q_1} == 2'b10) state <= S4;
				else state <= S5; 
		S3 	: 	state <= S5;
		S4 	: 	state <= S5;
		S5 	: 	#2 if (({Q0, Q_1} == 2'b01) && (!eqz))
					state <= S3;
				else if (({Q0, Q_1} == 2'b10) && (!eqz))
					state <= S4;
				else if (eqz)
					state <= S6;
		S6 	: 	state <= S6; 
	   	default:	state <= S0; 
	endcase 
			
	always @(state)
	
	//Assigning the control signals of the data path as per the state. 
	case (state)
		S0 : begin 								
			decr = 0; load_count = 0; shift_A = 0; load_A = 0; clear_A = 0; load_M = 0; 
			load_Q =  0;clear_Q = 0; shift_Q = 0; clear_ff = 0; addsub = 0; done = 0;
			end 
		S1 : begin 
			clear_A = 1 ; clear_ff = 1 ; load_count = 1 ; load_M = 1;
			end 
		S2 : begin 
			clear_A = 0 ; load_count = 0 ; load_M = 0 ; load_Q = 1 ; decr = 0; 
             end 
		S3 : begin 
			shift_A = 0 ; shift_Q = 0 ;load_Q = 0 ; addsub = 1 ; load_A = 1 ; decr = 0;
			end 
		S4 : begin 
			shift_A = 0 ; shift_Q = 0 ;load_Q = 0 ; addsub = 0 ; load_A = 1 ; decr = 0;
			end 
		S5 : begin
			clear_ff = 0; load_Q = 0 ; load_A = 0 ; shift_A = 1 ; shift_Q = 1 ; decr = 1;
			end 		 
		S6 : begin 
			shift_A = 0 ; shift_Q = 0 ; decr = 0 ; done = 1;
			end  
		default : begin 
			decr = 0 ;  load_count = 0 ; shift_A = 0 ; load_A = 0 ; clear_A = 0 ; load_M = 0;
 			load_Q =  0 ;  clear_Q = 0 ;  shift_Q = 0 ; clear_ff  = 0 ; addsub = 0 ; done = 0;
			end  
	endcase 
endmodule 