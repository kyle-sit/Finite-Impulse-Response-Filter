module fir_tb;

	logic [31:0] in, out;
	logic clk, rst, stop, next, ready;

	fir uut (
		.in(in), .out(out),
		.clk(clk), .rst(rst), .stop
	)
	
	initial begin
		clk = 0;
	end
	
	always begin
		#50
		clk = ~clk;
	end

endmodule