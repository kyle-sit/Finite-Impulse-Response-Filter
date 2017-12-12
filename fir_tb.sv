`timescale 1ns / 1ps

module m_fir_tb;
	
	// internal
	integer i = 0; // counter
	integer j = 0;
	integer n = 200; // total number of testvector
	logic[31:0] tv_A[99:0];
	logic[31:0] tv_Y[99:0];
	
	logic [31:0] A, Y;
	logic clk, rst, next, ready;
	logic stop = 0;

	FIR fir (
		.in(A), .out(Y),
		.clk(clk), .rst(rst), .stop(stop), .next(next), .ready(ready)
	);
	
	// read test vector
	initial begin
		$readmemh("input.txt", tv_A);
		$readmemh("output.txt", tv_Y);
		
		//for (integer k = 0; k < n; k++)
			//$display("%h", tv_A[k]);
		
		// turn on module
		clk <= 1;
		rst <= 1;
		#10;
		rst <= 0;
	end
	
	always_ff @(posedge clk) begin
		if (next) begin
			// give inputs
			$display("%dth input requested", i+1);
			if (i < n) begin
				A <= tv_A[i];
				i <= i + 1;
			end
			// stop
			else begin
				stop <= 1;
			end
		end
		// fetch outputs
		if (ready) begin
			$display("%dth output received", j+1);
			num_check(tv_Y[j], Y);
			j <= j + 1;
			// stop when all the output received
			if (j == n) begin
				$display("Extra output");
				$stop;
			end
		end
	end
	
	// toggle clk
	always #5 clk = ~clk;
	
	// display float numbers
	function void num_check (input logic [31:0] exp, out);
		//$display("%h, %h", exp, out);
		// process expected
		if (exp[30:23] === 0)
			$write("Expected:0, ");
		else if (exp[30:23] === 8'hff) begin
			if (exp[22:0] === 0) begin
				if (exp[31])
					$write("Expected:-Inf, ");
				else
					$write("Expected:+Inf, ");
			end
			else
				$write("Expected:NaN, ");
		end
		else
			$write("Expected:%f, ", $bitstoshortreal(exp));
		
		// process out
		if (out[30:23] === 0)
			$write("Output:0\n");
		else if (out[30:23] === 8'hff) begin
			if (out[22:0] === 0) begin
				if (out[31])
					$write("Output:-Inf\n");
				else
					$write("Output:+Inf\n");
			end
			else
				$write("Output:NaN\n");
		end
		else
			$write("Output:%f\n", $bitstoshortreal(out));
	endfunction
	
endmodule