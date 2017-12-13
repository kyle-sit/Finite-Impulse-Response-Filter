module FIR_SSE (
	input logic clk, rst, stop,
	input logic [31:0] in, out_gold,
	output logic next, ready,
	output logic [31:0] out_filt, out_sse
);

logic frst, fstop, fnext, fready;
logic srst, sstop, snext, sready;
logic [31:0] fir_out;
logic [2:0] state;
logic next_input;
parameter [2:0] idle = 3'd0, fire_fir = 3'd1, waiting = 3'd2, fire_sse = 3'd3, outputting = 3'd4, finished = 3'd5;

logic [43:0] [31:0] golden_outputs;
logic [43:0] [31:0] fir_outputs;
logic [8:0] out_gold_counter, out_fir_counter, filter_counter, stop_num;
logic [31:0] current_golden_out, current_fir_out;

FIR fir (
	.in(in), .out(fir_out),
	.clk(clk), .rst(frst), .stop(fstop), .next(next), .ready(fready)
);

SSE sse (
	.A(current_fir_out), .B(current_golden_out), .Y(out_sse),
	.clk(clk), .rst(srst), .stop(sstop), .next(snext), .ready(sready)
);

always_ff @(posedge clk) begin
	
	// initialize counters to 0, take in the first input
	if (rst) begin
		state <= idle;
		out_gold_counter <= 0;
		out_fir_counter <= 0;
		filter_counter <= 0;
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
		end
		
		// continue storing golden inputs until the fir is ready
		waiting: begin
			frst <= 0;
		    if( stop ) begin
				state <= fire_sse;
				out_fir_counter <= 0;
				out_gold_counter <= 0;
				srst <= 1;
				fstop <= 1;
				stop_num <= out_fir_counter;
				fir_outputs[out_fir_counter] <= fir_out;
			end
			else if(out_fir_counter > 43) begin
				state <= fire_sse;
				out_fir_counter <= 0;
				out_gold_counter <= 0;
				srst <= 1;
				fstop <= 1;
				stop_num <= out_fir_counter;
			end
			else begin
				if( next ) begin
					next_input <= 1;
				end
				if (next_input == 1 && out_gold_counter < 44) begin
					golden_outputs[out_gold_counter] <= out_gold;
					out_gold_counter <= out_gold_counter + 1;
					next_input <= 0;
				end
				if( fready ) begin
					fir_outputs[out_fir_counter] <= fir_out;
					out_fir_counter <= out_fir_counter + 1;
				end
			end
		end
		
		fire_sse: begin
			srst <= 0;
			if( filter_counter > stop_num) begin
				state <= finished;
				sstop <= 1;
			end
			else begin
				if( snext ) begin
					current_fir_out <= fir_outputs[out_fir_counter];
					current_golden_out <= golden_outputs[out_gold_counter];
					out_fir_counter <= out_fir_counter + 1;
					out_gold_counter <= out_gold_counter + 1;
				end
				if( sready ) begin
					out_filt <= fir_outputs[filter_counter];
					filter_counter <= filter_counter + 1;
					ready <= 1;
				end
				else begin
					ready <= 0;
				end
			end
		end
		
		finished: begin
			ready <= 1;
		end
	
	endcase
end

endmodule