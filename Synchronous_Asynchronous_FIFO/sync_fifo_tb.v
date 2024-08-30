`timescale 1ns/1ps
module tb();
	reg [7:0] rdata;
	reg clk,reset;
	reg write_en,read_en;
	reg [7:0] data_in;
	wire full,empty;
	wire [7:0] data_out;
    reg stop;

sync_fifo uut(.clk(clk),
			.reset(reset),
			.write_en(write_en),
			.read_en(read_en),
			.data_in(data_in),
			.full(full),
			.empty(empty),
			.data_out(data_out) );

	always #10 clk <= ~clk;
initial begin
		clk <= 0;
		reset <= 0;
		write_en <= 0;
		read_en <= 0;
		stop <= 0;
		#50 reset <= 1;
end

initial begin
	@(posedge clk);
	for (integer i = 0; i < 50; i = i+1) begin
		while (full) begin
		@(posedge clk);
		$display("[%0t] FIFO is full, wait For reads to happen", $time);
		end;
		write_en <= $random;
		data_in <= $random;
		
		@(posedge clk);
	end
	stop = 1;
end

initial begin
$dumpfile("fifo.vcd");
$dumpvars(0,tb);
	@(posedge clk);
	while (!stop) begin
		while (empty) begin
		read_en <= 0;
		@(posedge clk);
		end;
		#10
		read_en <= $random;
		@(posedge clk);
		rdata <= data_out;	
	end
	#500 $finish;
end

endmodule

