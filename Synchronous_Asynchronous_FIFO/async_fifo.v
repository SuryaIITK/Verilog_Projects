module async_fifo (write_clk,read_clk,write_en,read_en,reset,data_in,data_out,valid,empty,full,over_flow,under_flow);
parameter data_width=8;
parameter fifo_depth=16;
input write_clk;
input read_clk;
input reset;
input write_en;
input read_en;
input [data_width-1:0] data_in;
output reg [data_width-1:0] data_out;
output full;
output empty;
output reg valid;
output reg over_flow;
output reg under_flow;
parameter ptr_width=$clog2(fifo_depth);

reg [ptr_width:0] write_ptr;
reg [ptr_width:0] read_ptr;
reg [ptr_width:0] wr_ptr_to_grey_q1,wr_ptr_to_grey_q2;
reg [ptr_width:0] rd_ptr_to_grey_q1,rd_ptr_to_grey_q2;
reg [ptr_width:0] wr_ptr_binary,rd_ptr_binary;
wire [ptr_width:0] wr_ptr_to_grey;
wire [ptr_width:0] rd_ptr_to_grey;


//2d array
reg [data_width-1:0] fifo [fifo_depth-1:0];
//writng data into fifo_depth
always@(posedge write_clk) begin
	if (!reset) begin
	write_ptr <= 0;
	end
	else begin
		if (write_en & !full) begin
			fifo[write_ptr] <= data_in;
			write_ptr <= write_ptr+1;
			
		end
	end
 end
//reading data into fifo_depth
always@(posedge read_clk) begin
	if (!reset) begin
	read_ptr <= 0;
	data_out <= 0;
	end
	else begin
		if (read_en & !empty) begin
			data_out <= fifo[read_ptr];
			read_ptr <= read_ptr+1;
			
 		end
	end
 end

// converting write_ptr & read_ptr to grey code from binary

assign wr_ptr_to_grey = write_ptr^(write_ptr>>1);
assign rd_ptr_to_grey = read_ptr^(read_ptr>>1);

//passing those wr_ptr_to_grey & rd_ptr_to_grey through 2 stage synchronizer
//2 stage synchronizer for write_ptr w.r.to read_clk

always@(posedge read_clk) begin
	if(!reset) begin
		wr_ptr_to_grey_q1<=0;
		wr_ptr_to_grey_q2<=0;
	end
	else begin
		wr_ptr_to_grey_q1<=wr_ptr_to_grey;
		wr_ptr_to_grey_q2<=wr_ptr_to_grey_q1;
	end
end

//2 stage synchronizer for read_ptr w.r.to write_clk

always@(posedge write_clk) begin
	if(!reset) begin
		rd_ptr_to_grey_q1<=0;
		rd_ptr_to_grey_q2<=0;
	end
	else begin
		rd_ptr_to_grey_q1<=rd_ptr_to_grey;
		rd_ptr_to_grey_q2<=rd_ptr_to_grey_q1;
	end
end
always@(*) begin
	wr_ptr_binary[ptr_width]=wr_ptr_to_grey_q2[ptr_width];
	rd_ptr_binary[ptr_width]=rd_ptr_to_grey_q2[ptr_width];
	
	for (integer i=ptr_width-1; i>=0; i=i-1) begin
		wr_ptr_binary[i]=wr_ptr_binary[i+1]^wr_ptr_to_grey_q2[i];
		rd_ptr_binary[i]=rd_ptr_binary[i+1]^rd_ptr_to_grey_q2[i];
	end
end

// for empty & full condition
//assign empty = (rd_ptr_to_grey == wr_ptr_to_grey_q2);
//assign full =(wr_ptr_to_grey[ptr_width]!==rd_ptr_to_grey_q2[ptr_width]) && (wr_ptr_to_grey[ptr_width-1]==rd_ptr_to_grey_q2[ptr_width-1]) && (wr_ptr_to_grey[ptr_width-2]==rd_ptr_to_grey_q2[ptr_width-2]);
//assign full =({~wr_ptr_to_grey[ptr_width],wr_ptr_to_grey[ptr_width-1:0]} == rd_ptr_to_grey_q2);
assign empty = (read_ptr == wr_ptr_binary);
assign full =({~write_ptr[ptr_width],write_ptr[ptr_width-1:0]} == rd_ptr_binary);

//over_flow condition
always@(posedge write_clk) begin
	over_flow = (full && write_en);
end
always@(posedge read_clk) begin
	under_flow = (empty && read_en);
	valid = (data_out && !empty);   //no data for reading
end
endmodule

	

