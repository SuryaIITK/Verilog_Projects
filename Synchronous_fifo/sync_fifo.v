module sync_fifo #(parameter fifo_depth=16,data_width=8)
(	
	input clk,
	input reset,
	input write_en,
	input read_en,
	input [data_width-1:0] data_in,
	output full,
	output empty,
	output reg [data_width-1:0] data_out
);
	
	parameter ptr_width=$clog2(fifo_depth);
	reg [ptr_width:0] write_ptr;
	reg [ptr_width:0] read_ptr;
	reg [data_width-1:0] fifo[0:fifo_depth-1] ; //array will have depth elements where each element is 8 bit wide
	
	always @(posedge clk) begin
		if(!reset) begin
			write_ptr<=0;
			//read_ptr<=0;
			//data_out<=0;
		end
		else begin
			if(write_en & !full) begin
			fifo[write_ptr] <= data_in;
			write_ptr<=write_ptr+1;
			end
		end
	end
	  // To write data to FIFO
	always@(posedge clk) begin
		if(!reset) begin
			read_ptr<=0;
			data_out<=0;
		end
		else begin
			if(read_en & !empty) begin
			data_out<=fifo[read_ptr];
			read_ptr<=read_ptr+1;
			end
		end
	end
	 assign full = ({~write_ptr[ptr_width],write_ptr[ptr_width-1:0]} == read_ptr);
	 assign empty = write_ptr == read_ptr;
endmodule