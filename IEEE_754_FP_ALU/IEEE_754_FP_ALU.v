module add_sub(
input [31:0] n1, //addend1 or minuend
input [31:0] n2, //addend2 or subtrahend
input add, //if sub=0 operation is adding else operation is subtraction
input sub, //if sub=0 operation is adding else operation is subtraction
input mul,
output [31:0] result,
output reg [23:0]M1,
output reg [23:0]M2,
output [7:0] E1,
output [7:0] E2,
output [7:0] E_difference,
output reg [7:0] larger_E,
output reg sign,
output reg [7:0] final_E,
output reg [22:0] final_M,
output [31:0] result1
//output overflow, //if the result is too large to be represented.
//output underflow, //if the result is too small to be represented.
//output exception //If the bits of exponents1&2 are 1, then the number will be either infinity or NAN ( i.e. an Exception )
);
//reg [23:0] M1;
//reg [23:0] M2;

wire  E1isGreaterThanE2;
reg [24:0] temp_M1;
reg [24:0] temp_M2;
reg M_carry;
wire reduced_and_E1 = &E1;//bitwise and operation of exponent1 for checking all the bits are 1 (exception "infinity")
wire reduced_and_E2 = &E2;
wire reduced_or_E1 = |E1;	//// bitwise or operation of E1 for checking all bits are 0 
							//then Number is denormalized and implied bit of the corresponding mantissa is set as 0.
wire reduced_or_E2 = |E2;
//or(exception,reduced_and_E1,reduced_and_E2); 
reg [24:0] temp1_M;
reg [24:0] temp2_M;
wire [22:0] temp3_M;
wire [7:0]large_E;
wire [7:0]two_complement_E2;
wire [8:0] temp1_E;
wire [7:0] temp2_E;
wire [7:0] temp3_E;
wire [7:0] temp4_E;
wire sign_n1 = n1[31];
wire sign_n2 = n2[31];
//wire [7:0] E1 = n1[30:23];
	assign E1 = n1[30:23];
	assign E2 = n2[30:23];

// Performing E1 - E2
	assign  two_complement_E2 = ~E2 + 1'b1;
// for subtraction add 2's complemented_E2 to the E1 if carry=1 then E1>E2 else if carry=0 then E1<E2
	assign temp1_E = E1 + two_complement_E2;
	assign temp2_E = temp1_E[7:0];
	assign E1isGreaterThanE2 = temp1_E[8];
// If carry =0 means E1isGreaterThanE2=0 then exponent_difference comes out to be -ve then find it's 2's complement
	assign temp3_E = ~temp2_E + 1'b1;
// Original exponent_difference or 2's complement version is selected according to isE1GreaterThanE2 by using 2:1 mux
	assign E_difference = (E1isGreaterThanE2) ? temp2_E : temp3_E;
//for Selecting the larger exponent
	assign large_E = (E1isGreaterThanE2) ? E1 : E2;
// shifting either mantissa of n1 or n2 based on larger_exponent
//if E1 is larger then output exponent also same as E1 and right shift smaller mantessa M2 by final_exponent_difference bits
	reg [23:0] larger_M;
	reg [23:0] smaller_M;
	
//if the operation is subtraction then we need to add 2's_complemented_smaller_M to the larger_M
//if the operation is addition then we can add directly both larger_M and smaller_M
//based on the based on the operation (sub) we can decide what is the addend to larger_M
//so 2:1 mux is the suitable design here
//now add the larger_M and final_small_M if the carry generates then add 1'b1 to the exponent
//because resultant number will be higher so that exponent should be adjusted to +1

//wire sign1;
 //   assign sign1 = n1[31]^n2[31];
reg [7:0]ae, be;
//    assign ae = n1[30:23] - 8'd127;
//    assign be = n2[30:23] - 8'd127; // ae, be are unbiased exponents
   // wire [23:0]am, bm;
    wire [22:0]cman;
    reg [47:0]cm;
 //   assign am = {1'b1,n1[22:0]}; // Reprentation of (1.A_mantissa) as 24 bits
 //   assign bm = {1'b1,n2[22:0]}; // Reprentation of (1.B_mantissa) as 24 bits
	reg [7:0]ce;
	wire [7:0]cexp;
	reg [31:0]am,bm;
 //   assign ce = (ae + be) + 8'd127; // Biasing exponent.
	  // Sum of unbiased exponents should be in the range (-127,128] to avoid overflow
  //  radix4booth multip({8'd0,am},{8'd0,bm},cm); // 24 bit multiplication
    
//    assign cman = cm[47] ? (cm[23] ? cm[46:24]+1'b1 : cm[46:24]) : (cm[22] ? cm[45:23]+1'b1 : cm[45:23]);  //This includes rounding off mantissa product to 23 bits
//    assign cman = cm[47] ? cm[46:24] : cm[45:23]; //This step is truncation instead of rounding
//    assign cexp = cm[47]? (ce + 1'b1):ce; // Exponent increases by 1 depending on mantiassas multiplication.
//    assign result1 =  (mul) ? {sign1,cexp,cman}: 31'd0;




	always@(*)begin
		M1={1'b1,n1[22:0]};
		M2={1'b1,n2[22:0]};	
		if(add) begin
			if(large_E == E1) begin
				M2=M2>>E_difference;
				larger_E = E1;
				larger_M = M1;
				smaller_M = M2;
				sign = sign_n1;
				if (sign_n1 == sign_n2) begin
					temp1_M = M1 + M2 ;
				end else begin
					temp_M2 = ~M2 + 1'b1;//2's complement
					temp2_M = M1 + temp_M2;
				end
			end
			else if(large_E == E2) begin
				M1=M1>>E_difference;
				larger_E = E2;
				larger_M = M2;
				smaller_M = M1;
				sign = sign_n2;
				if (sign_n1 == sign_n2) begin
					temp1_M = M2 + M1;
				end else begin
					temp_M1 = ~M1 + 1'b1;//2's complement
					temp2_M = M2 + temp_M1;
				end
			end else begin //if both exponents are equal
				larger_E = E1;
				if(M1>M2) begin
					larger_M = M1;
					smaller_M = M2;
					sign = sign_n1;
					if(sign_n1 == sign_n2) begin
						temp1_M = M2 + M1 ;
					end else begin
					temp_M2 = ~M2 + 1'b1;//2's complement
					temp2_M = M1 + temp_M2;
					end
				end else begin
					larger_M = M2;
					smaller_M = M1;
					sign = sign_n2;
					if (sign_n1 == sign_n2) begin
						temp1_M = M2 + M1;
					end else begin
						temp_M1 = ~M1 + 1'b1;//2's complement
						temp2_M = M2 + temp_M1;
					end
				end
			end
		end 
		else if(sub) begin //if(sub=1)
			if(large_E == E1) begin
				M2=M2>>E_difference;
				larger_E = E1;
				larger_M = M1;
				smaller_M = M2;
				sign = sign_n1;
				if (sign_n1 == sign_n2) begin
					temp_M2 = ~M2 + 1'b1;//2's complement
					temp2_M = M1 + temp_M2;
				end else begin
					temp1_M = M1 + M2 ;
				end
			end
			else if(large_E == E2) begin
				M1=M1>>E_difference;
				larger_E = E2;
				larger_M = M2;
				smaller_M = M1;
				sign = sign_n2;
				if (sign_n1 == sign_n2) begin
					temp_M2 = ~M2 + 1'b1;//2's complement
					temp2_M = M1 + temp_M2;
				end else begin
					temp1_M = M1 + M2 ;
				end
			end 
			else begin //if both exponents are equal
				larger_E = E1;
				if(M1>M2) begin
				larger_M = M1;
				smaller_M = M2;
				sign = sign_n1;
				if (sign_n1 == sign_n2) begin
					temp_M2 = ~M2 + 1'b1;//2's complement
					temp2_M = M1 + temp_M2;
				end else begin
					temp1_M = M1 + M2 ;
				end
				end else begin
				larger_M = M2;
				smaller_M = M1;
				sign = sign_n2;
				if (sign_n1 == sign_n2) begin
					temp_M2 = ~M2 + 1'b1;//2's complement
					temp2_M = M1 + temp_M2;
				end else begin
					temp1_M = M1 + M2;
				end
				end
			end
		end
		else if (mul) begin
			sign = n1[31]^n2[31];
			ae = n1[30:23] - 8'd127;
			be = n2[30:23] - 8'd127; // ae, be are unbiased exponents
			ce = (ae + be) + 8'd127; // Biasing exponent.
			am = {8'd0,M1};
			bm = {8'd0,M2};
			cm = am*bm;
		end
	end
	
assign temp3_M =  temp2_M[23] ? {temp2_M[22:0]} : temp2_M[22] ? {temp2_M[21:0],1'd0} : temp2_M[21] ? {temp2_M[20:0],2'd0} : temp2_M[20] ? {temp2_M[19:0],3'd0} : temp2_M[19] ? {temp2_M[18:0],4'd0} : temp2_M[18] ? {temp2_M[17:0],5'd0} : temp2_M[17] ? {temp2_M[16:0],6'd0} : temp2_M[16] ? {temp2_M[15:0],7'd0} : temp2_M[15] ? {temp2_M[14:0],8'd0} : temp2_M[14] ? {temp2_M[13:0],9'd0} : temp2_M[13] ? {temp2_M[12:0],10'd0} : temp2_M[12] ? {temp2_M[11:0],11'd0} : temp2_M[11] ? {temp2_M[10:0],12'd0} : temp2_M[10] ? {temp2_M[9:0],13'd0} : temp2_M[9] ? {temp2_M[8:0],14'd0} : temp2_M[8] ? {temp2_M[7:0],15'd0} : temp2_M[7] ? {temp2_M[6:0],16'd0} : temp2_M[6] ? {temp2_M[5:0],17'd0} : temp2_M[5] ? {temp2_M[4:0],18'd0} : temp2_M[4] ? {temp2_M[3:0],19'd0} : temp2_M[3] ? {temp2_M[2:0],20'd0} : temp2_M[2] ? {temp2_M[1:0],21'd0} : temp2_M[1] ? {temp2_M[0],22'd0} : 23'd0 ;
assign temp4_E = temp2_M[23] ? larger_E-0 : temp2_M[22] ? larger_E-1 : temp2_M[21] ? larger_E-2 : temp2_M[20] ? larger_E-3 : temp2_M[19] ? larger_E-4 : temp2_M[18] ? larger_E-5 : temp2_M[17] ? larger_E-6 : temp2_M[16] ? larger_E-7 : temp2_M[15] ? larger_E-8 : temp2_M[14] ? larger_E-9 : temp2_M[13] ? larger_E-10 : temp2_M[12] ? larger_E-11 : temp2_M[11] ? larger_E-12 : temp2_M[10] ? larger_E-13 : temp2_M[9] ? larger_E-14 : temp2_M[8] ? larger_E-15 : temp2_M[7] ? larger_E-16 : temp2_M[6] ? larger_E-17 : temp2_M[5] ? larger_E-18 : temp2_M[4] ? larger_E-19 : temp2_M[3] ? larger_E-20 : temp2_M[2] ? larger_E-21 : temp2_M[1] ? larger_E-22 : larger_E-23;

	always@(*)begin
		if(!sub) begin
			final_M = sign_n1^sign_n2 ? temp3_M : temp1_M[24] ? temp1_M[23:1] : temp1_M[22:0];
			final_E = sign_n1^sign_n2 ? temp4_E : temp1_M[24] ? (larger_E + 1'b1) : larger_E;
		end else begin
			final_M = ~(sign_n1^sign_n2) ? temp3_M : temp1_M[24] ? temp1_M[23:1] : temp1_M[22:0];
			final_E = ~(sign_n1^sign_n2) ? temp4_E : temp1_M[24] ? (larger_E + 1'b1) : larger_E;
		end
	end
	// final result

	assign result = {sign,final_E,final_M};
	
	assign cman = cm[47] ? cm[46:24] : cm[45:23]; //This step is truncation instead of rounding
    assign cexp = cm[47]? (ce + 1'b1):ce; // Exponent increases by 1 depending on mantiassas multiplication.
    assign result1 =  (mul) ? {sign,cexp,cman}: 31'd0;
	
endmodule
