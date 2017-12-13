module FIR_SSE (
	input logic clk, rst, stop,
	input logic [31:0] in, out_gold,
	output logic next, ready,
	output logic [31:0] out_filt, out_sse
);

logic frst, fstop, fnext, fready;
logic srst, sstop, snext, sready;
logic [31:0] fir_out, current_golden_out;
logic [2:0] state;
logic next_input;
parameter [2:0] idle = 3'd0, fire_fir = 3'd1, waiting = 3'd2, fire_sse = 3'd3, outputting = 3'd4, finished = 3'd5;

logic [43:0] [31:0] golden_outputs;
logic [8:0] out_gold_counter, current_out_gold_counter;

FIR fir (
	.in(in), .out(fir_out),
	.clk(clk), .rst(frst), .stop(fstop), .next(next), .ready(fready)
);

SSE sse (
	.A(fir_out), .B(out_gold), .Y(out_sse),
	.clk(clk), .rst(srst), .stop(sstop), .next(snext), .ready(sready)
);

always_ff @(posedge clk) begin
	
	// initialize counters to 0, take in the first input
	if (rst) begin
		state <= idle;
		out_gold_counter <= 0;
		current_out_gold_counter <= 0;
		next_input <= 0;
	end
	
	case (state)
	
		// idle state
		idle: begin
			state <= fire_fir;
			frst <= 1;
		end
		
		// fire the fir. store golden output 1 because sse won't run yet
		fire_fir: begin
			state <= waiting;
			golden_outputs[0] <= out_gold;
			out_gold_counter <= out_gold_counter + 1;
		end
		
		// continue storing golden inputs until the fir is ready
		waiting: begin
			frst <= 0;
			if( next ) begin
				next_input <= 1;
			end
			if (next_input == 1) begin
				golden_outputs[out_gold_counter] <= out_gold;
				out_gold_counter <= out_gold_counter + 1;
				next_input <= 0;
			end
			if( fready ) begin
				state <= fire_sse;
			end
		end
		
		fire_sse: begin
			//srst <= 1;
			//current_golden_out <= golden_outputs[current_out_gold_counter];
			if( next ) begin
				next_input <= 1;
			end
			if (next_input == 1) begin
				golden_outputs[out_gold_counter] <= out_gold;
				out_gold_counter <= out_gold_counter + 1;
				next_input <= 0;
			end
			//state <= outputting;
		end
		
		outputting: begin
			srst <= 0;
		end
	
	endcase
end

endmodule