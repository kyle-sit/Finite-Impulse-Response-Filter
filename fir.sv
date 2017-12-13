module FIR (
	input logic clk, rst, stop,
	input logic [31:0] in,
	output logic next, ready,
	output logic [31:0] out
);

// signals for adders and multipliers
logic [43:0] [31:0] coefficients = { 32'hbbd8e796, // 44 coefficients
										32'h3b02db67,
										32'hbc2e0e02,
										32'hbc9c65aa,
										32'h3c8bca7a,
										32'h3b575958,
										32'h3c7a3c7b,
										32'h3c78c858,
										32'h3b9675ab,
										32'h3d09a22e,
										32'hbbbd15d8,
										32'h3cde314c,
										32'hbbc62970,
										32'hbc833b76,
										32'h3b94449c,
										32'hbda25452,
										32'h3a05d669,
										32'hbded80a7,
										32'hbd6eef65,
										32'hbd7d0c7d,
										32'hbe8090bd,
										32'h3f0200cf,
										32'h3f0200cf,
										32'hbe8090bd,
										32'hbd7d0c7d,
										32'hbd6eef65,
										32'hbded80a7,
										32'h3a05d669,
										32'hbda25452,
										32'h3b94449c,
										32'hbc833b76,
										32'hbbc62970,
										32'h3cde314c,
										32'hbbbd15d8,
										32'h3d09a22e,
										32'h3b9675ab,
										32'h3c78c858,
										32'h3c7a3c7b,
										32'h3b575958,
										32'h3c8bca7a,
										32'hbc9c65aa,
										32'hbc2e0e02,
										32'h3b02db67,
										32'hbbd8e796 };
									
// 44 multipliers, 45 adders
logic [43:0] mready, mbusy; // first multiplier/adder at 0
logic [44:0] aready, abusy; // 73->37->19->10->5->3->2->1
logic start;
logic [43:0] [31:0] inputs;
logic [44:0] [31:0] adder_A, adder_B;
logic [43:0] [31:0] multiplier_in;
logic [43:0] [31:0] multiplier_out;
logic [44:0] [31:0] adder_out;
logic [8:0] input_counter, counter;
logic [2:0] state;
parameter [2:0] idle = 3'd0, prep = 3'd1, fire = 3'd2, loop = 3'd3, finished = 3'd4;
logic [2:0] wc;

genvar i;
generate
	for (i = 0; i < 45; i++) begin : generate_block_identifier
		if (i < 44) begin
			multiplier_fp m1 (
				.clk(clk), .start(start),
				.A(coefficients[i]), .B(multiplier_in[i]),
				.ready(mready[i]), .busy(mbusy[i]),
				.Y(multiplier_out[i])
			);
		end
		adder_fp a1 (
			.clk(clk), .start(start), .op(1'b0),
			.A(adder_A[i]), .B(adder_B[i]),
			.ready(aready[i]), .busy(abusy[i]),
			.Y(adder_out[i])
		);
	end
endgenerate

always_ff @(posedge clk) begin
	
	if (rst) begin
		input_counter <= 0;
		state <= idle;
		wc <= 0;
		next <= 1;
		counter <= 0;
	end
	
	case (state)
		idle: begin
			inputs[input_counter] <= in;
			if (!rst) begin
				state <= prep;
			end
			next <= 0;
			ready <= 0;
		end
		
		prep: begin
			//set up multiplier inputs
			for (int j = 0; j < input_counter + 1; j++) begin
				multiplier_in[j] <= inputs[input_counter - j];
			end
			
			// 22 -> 11 -> 6 -> 3 -> 2 -> 1 = 45
			// first level of adders [21:0]
			for (int k = 0; k < 22; k++) begin
				if (2*k >= input_counter) begin
					adder_A[k] <= 0;
					adder_B[k] <= 0;
				end
				else if ((2*k + 1) == input_counter) begin
					adder_A[k] <= multiplier_out[2*k];
					adder_B[k] <= 0;
				end
				else begin
					adder_A[k] <= multiplier_out[2*k];
					adder_B[k] <= multiplier_out[(2*k) + 1];
				end
			end
			
			// second level of adders [22:32]
			for (int l = 22; l < 33; l++) begin
				adder_A[l] <= adder_out[(l-22)*2];
				adder_B[l] <= adder_out[(l-22)*2+1];
			end
			
			// third level of adders [33:38]
			for (int z = 33; z < 39; z++) begin
				if (z == 38) begin
					adder_A[z] <= adder_out[(z-22)*2];
					adder_B[z] <= 0;
				end
				else begin		
					adder_A[z] <= adder_out[(z-22)*2];
					adder_B[z] <= adder_out[(z-22)*2+1];
				end
			end
			// fourth level of adders [39:41]
			for (int x = 39; x < 42; x++) begin	
				adder_A[x] <= adder_out[(x-22)*2-1];
				adder_B[x] <= adder_out[(x-22)*2];
			end
			
			// fifth level of adders [42:43]
			adder_A[42] <= adder_out[39];
			adder_B[42] <= adder_out[40];
			adder_A[43] <= adder_out[41];
			adder_B[43] <= 0;
			
			// sixth level of adders [44]
			adder_A[44] <= adder_out[42];
			adder_B[44] <= adder_out[43];
			
			state <= fire;
		end
		
		fire: begin
			start <= 1;
			wc <= 0;
			state <= loop;
		end
		
		loop: begin
			if (wc < 6) begin
				if (wc == 0) begin
					start <= 0;
				end
				else if (wc == 5) begin
					next <= 1;
				end
				wc <= wc + 1;
			end
			else if (stop || input_counter > 42) begin
				// should probably be 6
				if (counter == 6) begin
					state <= finished;
				end
				else begin	
					state <= idle;
					counter <= counter + 1;
				end
				out <= adder_out[44];
				next <= 0;
				ready <= 1;
			end
			else begin
				state <= idle;
				// connect output
				out <= adder_out[44];
				next <= 0;
				// should probably be 5
				if (input_counter > 5) begin
					ready <= 1;
				end
				input_counter <= input_counter + 1;
			end
		end
		
		finished: begin
			ready <= 1;
			next <= 0;
			out <= adder_out[44];
		end
		
	endcase
end

endmodule