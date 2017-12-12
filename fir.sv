module FIR (
	input logic clk, rst, stop,
	input logic [31:0] in,
	output logic next, ready,
	output logic [31:0] out
);

// signals for adders and multipliers
logic [72:0] [31:0] coefficients = { 32'hbc06ca4c,
									32'hbb86b56d,
									32'h3c8493ff,
									32'h3bd1ba42,
									32'hbb8b5502,
									32'h3b373752,
									32'hbbb85463,
									32'hbb686092,
									32'hbaa9b425,
									32'hbbbc6406,
									32'h3ac7e136,
									32'hbb13cfee,
									32'h3a9e292e,
									32'h3b6b0993,
									32'h379a8626,
									32'h3bccb77f,
									32'h3a1e2a32,
									32'h3b430c5f,
									32'h3b1e2e7e,
									32'hbb4c87e1,
									32'h3b01c058,
									32'hbbc3bfed,
									32'hbb1731b3,
									32'hbb49c9bc,
									32'hbbd875d2,
									32'h3ae6fe6a,
									32'hbba1ae72,
									32'h3b54f3ca,
									32'h3b524155,
									32'h3a95af73,
									32'h3c27a647,
									32'h389119a3,
									32'h3c014658,
									32'h3b18dd0d,
									32'hbb34e966,
									32'h3b6e4f7d,
									32'hbc376c18,
									32'hbab5f4f3,
									32'hbc0f9d82,
									32'hbc211979,
									32'h3aaaf59d,
									32'hbc33a32e,
									32'h3bff0daf,
									32'h3a95beeb,
									32'h3ba93beb,
									32'h3c8bbf64,
									32'hb7f820de,
									32'h3c9c2bac,
									32'h3a741f9a,
									32'h3a94f0d3,
									32'h3baf7891,
									32'hbcab8865,
									32'h3aa3dbd1,
									32'hbcc6ccbc,
									32'hbc6d9da8,
									32'hbb8e2c53,
									32'hbccb036a,
									32'h3c9541a6,
									32'hbc0285df,
									32'h3ca7920f,
									32'h3d0353c8,
									32'h3b939c61,
									32'h3d68738a,
									32'hbb9b5561,
									32'h3ccf1a8f,
									32'h3bd599a9,
									32'hbd6f422c,
									32'h3c46e4b1,
									32'hbe06636d,
									32'hbd375f0e,
									32'hbdca0818,
									32'hbe825a8b,
									32'h3ef5580e,
									32'h3ef5580e,
									32'hbe825a8b,
									32'hbdca0818,
									32'hbd375f0e,
									32'hbe06636d,
									32'h3c46e4b1,
									32'hbd6f422c,
									32'h3bd599a9,
									32'h3ccf1a8f,
									32'hbb9b5561,
									32'h3d68738a,
									32'h3b939c61,
									32'h3d0353c8,
									32'h3ca7920f,
									32'hbc0285df,
									32'h3c9541a6,
									32'hbccb036a,
									32'hbb8e2c53,
									32'hbc6d9da8,
									32'hbcc6ccbc,
									32'h3aa3dbd1,
									32'hbcab8865,
									32'h3baf7891,
									32'h3a94f0d3,
									32'h3a741f9a,
									32'h3c9c2bac,
									32'hb7f820de,
									32'h3c8bbf64,
									32'h3ba93beb,
									32'h3a95beeb,
									32'h3bff0daf,
									32'hbc33a32e,
									32'h3aaaf59d,
									32'hbc211979,
									32'hbc0f9d82,
									32'hbab5f4f3,
									32'hbc376c18,
									32'h3b6e4f7d,
									32'hbb34e966,
									32'h3b18dd0d,
									32'h3c014658,
									32'h389119a3,
									32'h3c27a647,
									32'h3a95af73,
									32'h3b524155,
									32'h3b54f3ca,
									32'hbba1ae72,
									32'h3ae6fe6a,
									32'hbbd875d2,
									32'hbb49c9bc,
									32'hbb1731b3,
									32'hbbc3bfed,
									32'h3b01c058,
									32'hbb4c87e1,
									32'h3b1e2e7e,
									32'h3b430c5f,
									32'h3a1e2a32,
									32'h3bccb77f,
									32'h379a8626,
									32'h3b6b0993,
									32'h3a9e292e,
									32'hbb13cfee,
									32'h3ac7e136,
									32'hbbbc6406,
									32'hbaa9b425,
									32'hbb686092,
									32'hbbb85463,
									32'h3b373752,
									32'hbb8b5502,
									32'h3bd1ba42,
									32'h3c8493ff,
									32'hbb86b56d,
									32'hbc06ca4c };
									
logic [145:0] mready, mbusy; // first multiplier/adder at 0
logic [149:0] aready, abusy; // 73->37->19->10->5->3->2->1
logic start;
logic [145:0] [31:0] inputs;
logic [149:0] [31:0] adder_A, adder_B;
logic [145:0] [31:0] multiplier_in;
logic [145:0] [31:0] multiplier_out;
logic [149:0] [31:0] adder_out;
logic [8:0] input_counter, counter;
logic [2:0] state;
parameter [2:0] idle = 3'd0, prep = 3'd1, fire = 3'd2, loop = 3'd3, finished = 3'd4;
logic [2:0] wc;

genvar i;
generate
	for (i = 0; i < 150; i++) begin : generate_block_identifier
		if (i < 146) begin
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
			
			//set up first level of adders [72:0]
			for (int k = 0; k < 73; k++) begin
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
			
			//set up second level of adders [109:73]
			for (int l = 73; l < 110; l++) begin
				if (l == 109) begin
					adder_A[l] <= adder_out[(l-73)*2];
					adder_B[l] <= 0;
				end
				else begin		
					adder_A[l] <= adder_out[(l-73)*2];
					adder_B[l] <= adder_out[(l-73)*2+1];
				end
			end
			
			//set up third level of adders [128:110]
			for (int z = 110; z < 129; z++) begin
				if (z == 128) begin
					adder_A[z] <= adder_out[(z-73)*2-1];
					adder_B[z] <= 0;
				end
				else begin		
					adder_A[z] <= adder_out[(z-73)*2-1];
					adder_B[z] <= adder_out[(z-73)*2];
				end
			end
			
			//set up fourth level of adders [138:129]
			for (int x = 129; x < 139; x++) begin
				if (x == 138) begin
					adder_A[x] <= adder_out[(x-74)*2];
					adder_B[x] <= 0;
				end
				else begin		
					adder_A[x] <= adder_out[(x-74)*2];
					adder_B[x] <= adder_out[(x-74)*2+1];
				end
			end
			
			//set up fifth level of adders [143:139]
			for (int y = 139; y < 144; y++) begin		
					adder_A[y] <= adder_out[(y-74)*2-1];
					adder_B[y] <= adder_out[(y-74)*2];
			end
			
			//set up sixth level of adders [146:144]
			adder_A[144] <= adder_out[139];
			adder_B[144] <= adder_out[140];
			adder_A[145] <= adder_out[141];
			adder_B[145] <= adder_out[142];
			adder_A[146] <= adder_out[143];
			adder_B[146] <= 0;
			
			//set up seventh level of adders [148:147]
			adder_A[147] <= adder_out[144];
			adder_B[147] <= adder_out[145];
			adder_A[148] <= adder_out[146];
			adder_B[148] <= 0;
			
			// set up eighth level of adders [149]
			adder_A[149] <= adder_out[147];
			adder_B[149] <= adder_out[148];
			
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
			else if (stop || input_counter > 144) begin
				if (counter == 9) begin
					state <= finished;
				end
				else begin	
					state <= idle;
					counter <= counter + 1;
				end
				out <= adder_out[149];
				next <= 0;
				ready <= 1;
			end
			else begin
				state <= idle;
				// connect output
				out <= adder_out[149];
				next <= 0;
				if (input_counter > 7) begin
					ready <= 1;
				end
				input_counter <= input_counter + 1;
			end
		end
		
		finished: begin
			ready <= 1;
			next <= 0;
			out <= adder_out[149];
		end
		
	endcase
end

endmodule