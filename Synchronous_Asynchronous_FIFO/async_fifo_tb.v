`timescale 1ns/1ps
module tb;
	reg write_clk;
	reg read_clk;
	reg reset;
	reg write_en;
	reg read_en;
	wire full;
	wire empty;
	wire valid,over_flow,under_flow;
	//reg c1k;
    reg [7:0] data_in;
    wire [7:0] data_out;
    reg [7:0] rdata;
    reg stop;

async_fifo uut(.write_clk(write_clk),
						.read_clk(read_clk),
						.reset(reset),
						.write_en(write_en),
						.read_en(read_en),
						.data_in(data_in),
						.data_out(data_out),
						.full(full),
						.empty(empty),
						.valid(valid),
						.over_flow(over_flow),
						.under_flow(under_flow));
						
				
	always #10 write_clk <= ~write_clk;
	always #20 read_clk <= ~read_clk;
	//always #10 clk <= ~clk;
	//assign read_clk = write_clk;
initial begin
		write_clk <= 0;
		read_clk <= 0;
		//clk <= 0;
		reset <= 0;
		write_en <= 0;
		read_en <= 0;
		stop <= 0;
		#50 reset <= 1;
end

initial begin
	@(posedge write_clk);
	for (integer i = 0; i < 50; i = i+1) begin
		// Wait until there is space in fifo
		while (full) begin
		@(posedge write_clk);
		$display("[%0t] FIFO is full, wait For reads to happen", $time);
		//read_en = 1;
		end;
		// Drive new values into FIFO
		write_en <= $random;
		data_in <= $random;
		$display("[%0t] write_clk i=%0d write_en=%0d data_in=0x%0h ", $time, i, write_en, data_in);
		// Wait for next clock edge
		@(posedge write_clk);
	end
	stop = 1;
end

initial begin
$dumpfile("asyn_fifo.vcd");
$dumpvars(0,tb);
	@(posedge read_clk);
	while (!stop) begin
		// Wait until there is data in fifo
		while (empty) begin
		read_en <= 0;
		$display("[%0t] FIFO is empty, wait For writes to happen", $time);
		@(posedge read_clk);
		end;
		// Sample new values from FIFO at random pace
		read_en <= $random;
		@(posedge read_clk);
		rdata <= data_out;
		$display("[%0t] read_clk read_en=%0d rdata=0x%0h ", $time, read_en, rdata);	
	end
	#500
	$finish;
end

endmodule