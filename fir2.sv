module fir_decoder (
	input logic [7:0] in,
	output logic [31:0] out
);

always_comb begin
	case (in)
		8'd1: out = 32'hbc06ca4c; 
		8'd2: out = 32'hbb86b56d; 
		8'd3: out = 32'h3c8493ff; 
		8'd4: out = 32'h3bd1ba42; 
		8'd5: out = 32'hbb8b5502; 
		8'd6: out = 32'h3b373752; 
		8'd7: out = 32'hbbb85463; 
		8'd8: out = 32'hbb686092; 
		8'd9: out = 32'hbaa9b425; 
		8'd10: out = 32'hbbbc6406; 
		8'd11: out = 32'h3ac7e136; 
		8'd12: out = 32'hbb13cfee; 
		8'd13: out = 32'h3a9e292e; 
		8'd14: out = 32'h3b6b0993; 
		8'd15: out = 32'h379a8626; 
		8'd16: out = 32'h3bccb77f; 
		8'd17: out = 32'h3a1e2a32; 
		8'd18: out = 32'h3b430c5f; 
		8'd19: out = 32'h3b1e2e7e; 
		8'd20: out = 32'hbb4c87e1; 
		8'd21: out = 32'h3b01c058; 
		8'd22: out = 32'hbbc3bfed; 
		8'd23: out = 32'hbb1731b3; 
		8'd24: out = 32'hbb49c9bc; 
		8'd25: out = 32'hbbd875d2; 
		8'd26: out = 32'h3ae6fe6a; 
		8'd27: out = 32'hbba1ae72; 
		8'd28: out = 32'h3b54f3ca; 
		8'd29: out = 32'h3b524155; 
		8'd30: out = 32'h3a95af73; 
		8'd31: out = 32'h3c27a647; 
		8'd32: out = 32'h389119a3; 
		8'd33: out = 32'h3c014658; 
		8'd34: out = 32'h3b18dd0d; 
		8'd35: out = 32'hbb34e966; 
		8'd36: out = 32'h3b6e4f7d; 
		8'd37: out = 32'hbc376c18; 
		8'd38: out = 32'hbab5f4f3; 
		8'd39: out = 32'hbc0f9d82; 
		8'd40: out = 32'hbc211979; 
		8'd41: out = 32'h3aaaf59d; 
		8'd42: out = 32'hbc33a32e; 
		8'd43: out = 32'h3bff0daf; 
		8'd44: out = 32'h3a95beeb; 
		8'd45: out = 32'h3ba93beb; 
		8'd46: out = 32'h3c8bbf64; 
		8'd47: out = 32'hb7f820de; 
		8'd48: out = 32'h3c9c2bac; 
		8'd49: out = 32'h3a741f9a; 
		8'd50: out = 32'h3a94f0d3; 
		8'd51: out = 32'h3baf7891; 
		8'd52: out = 32'hbcab8865; 
		8'd53: out = 32'h3aa3dbd1; 
		8'd54: out = 32'hbcc6ccbc; 
		8'd55: out = 32'hbc6d9da8; 
		8'd56: out = 32'hbb8e2c53; 
		8'd57: out = 32'hbccb036a; 
		8'd58: out = 32'h3c9541a6; 
		8'd59: out = 32'hbc0285df; 
		8'd60: out = 32'h3ca7920f; 
		8'd61: out = 32'h3d0353c8; 
		8'd62: out = 32'h3b939c61; 
		8'd63: out = 32'h3d68738a; 
		8'd64: out = 32'hbb9b5561; 
		8'd65: out = 32'h3ccf1a8f; 
		8'd66: out = 32'h3bd599a9; 
		8'd67: out = 32'hbd6f422c; 
		8'd68: out = 32'h3c46e4b1; 
		8'd69: out = 32'hbe06636d; 
		8'd70: out = 32'hbd375f0e; 
		8'd71: out = 32'hbdca0818; 
		8'd72: out = 32'hbe825a8b; 
		8'd73: out = 32'h3ef5580e; 
		/*8'd74: out = 32'h3ef5580e; 
		8'd75: out = 32'hbe825a8b; 
		8'd76: out = 32'hbdca0818; 
		8'd77: out = 32'hbd375f0e; 
		8'd78: out = 32'hbe06636d; 
		8'd79: out = 32'h3c46e4b1; 
		8'd80: out = 32'hbd6f422c; 
		8'd81: out = 32'h3bd599a9; 
		8'd82: out = 32'h3ccf1a8f; 
		8'd83: out = 32'hbb9b5561; 
		8'd84: out = 32'h3d68738a; 
		8'd85: out = 32'h3b939c61; 
		8'd86: out = 32'h3d0353c8; 
		8'd87: out = 32'h3ca7920f; 
		8'd88: out = 32'hbc0285df; 
		8'd89: out = 32'h3c9541a6; 
		8'd90: out = 32'hbccb036a; 
		8'd91: out = 32'hbb8e2c53; 
		8'd92: out = 32'hbc6d9da8; 
		8'd93: out = 32'hbcc6ccbc; 
		8'd94: out = 32'h3aa3dbd1; 
		8'd95: out = 32'hbcab8865; 
		8'd96: out = 32'h3baf7891; 
		8'd97: out = 32'h3a94f0d3; 
		8'd98: out = 32'h3a741f9a; 
		8'd99: out = 32'h3c9c2bac; 
		8'd100: out = 32'hb7f820de; 
		8'd101: out = 32'h3c8bbf64; 
		8'd102: out = 32'h3ba93beb; 
		8'd103: out = 32'h3a95beeb; 
		8'd104: out = 32'h3bff0daf; 
		8'd105: out = 32'hbc33a32e; 
		8'd106: out = 32'h3aaaf59d; 
		8'd107: out = 32'hbc211979; 
		8'd108: out = 32'hbc0f9d82; 
		8'd109: out = 32'hbab5f4f3; 
		8'd110: out = 32'hbc376c18; 
		8'd111: out = 32'h3b6e4f7d; 
		8'd112: out = 32'hbb34e966; 
		8'd113: out = 32'h3b18dd0d; 
		8'd114: out = 32'h3c014658; 
		8'd115: out = 32'h389119a3; 
		8'd116: out = 32'h3c27a647; 
		8'd117: out = 32'h3a95af73; 
		8'd118: out = 32'h3b524155; 
		8'd119: out = 32'h3b54f3ca; 
		8'd120: out = 32'hbba1ae72; 
		8'd121: out = 32'h3ae6fe6a; 
		8'd122: out = 32'hbbd875d2; 
		8'd123: out = 32'hbb49c9bc; 
		8'd124: out = 32'hbb1731b3; 
		8'd125: out = 32'hbbc3bfed; 
		8'd126: out = 32'h3b01c058; 
		8'd127: out = 32'hbb4c87e1; 
		8'd128: out = 32'h3b1e2e7e; 
		8'd129: out = 32'h3b430c5f; 
		8'd130: out = 32'h3a1e2a32; 
		8'd131: out = 32'h3bccb77f; 
		8'd132: out = 32'h379a8626; 
		8'd133: out = 32'h3b6b0993; 
		8'd134: out = 32'h3a9e292e; 
		8'd135: out = 32'hbb13cfee; 
		8'd136: out = 32'h3ac7e136; 
		8'd137: out = 32'hbbbc6406; 
		8'd138: out = 32'hbaa9b425; 
		8'd139: out = 32'hbb686092; 
		8'd140: out = 32'hbbb85463; 
		8'd141: out = 32'h3b373752; 
		8'd142: out = 32'hbb8b5502; 
		8'd143: out = 32'h3bd1ba42; 
		8'd144: out = 32'h3c8493ff; 
		8'd145: out = 32'hbb86b56d; 
		8'd146: out = 32'hbc06ca4c;*/
	endcase

end

endmodule

module FIR (
	input logic clk, rst, stop,
	input logic [31:0] in,
	output logic next, ready,
	output logic [31:0] out
);

logic [2:0] state;
parameter [2:0] idle = 3'd0, multiply = 3'd1, add = 3'd2, finish = 3'd3;
logic [31:0] running_sum;
logic [7:0] decoder_in;
logic [31:0] decoder_out;
logic start1, start2, ready1, ready2, busy1, busy2;
logic [31:0] adder_A;
logic [3:0] wc;
logic second_pass;



fir_decoder d1 (
	.in(decoder_in),
	.out(decoder_out)
);

adder_fp adder1 (
	.clk(clk), .start(start2), .op(0),
	.A(adder_A), .B(running_sum),
	.ready(ready2), .busy(busy2),
	.Y(running_sum)
);
	
multiplier_fp multiplier1 (
	.clk(clk), .start(start1),
	.A(in), .B(decoder_out),
	.ready(ready1), .busy(busy1),
	.Y(adder_A)
);

	always_ff @(posedge clk) begin

		if(rst) begin
			running_sum <= 0;
			state <= idle;
			ready <= 0;
			wc <= 0;
			decoder_in <= 1;
			next <= 1;
		end

		case(state)
			
			idle: begin
					start1 <= 1;
					next <= 0;
					state <= multiply;
					wc <= 0;
			end
			
			multiply: begin
				if (wc < 6) begin
					if (wc == 5) begin
						next <= 1;
						decoder_in <= decoder_in + 1;
					end
					wc <= wc + 1;
					start1 <= 0;
				end
				else begin
					next <= 0;
					wc <= 0;
					start2 <= 1;
					start1 <= 1;
					state <= add;
				end
			end
			
			add: begin
				if (wc < 6) begin
					if (wc == 5) begin
						next <= 1;
					end
					wc <= wc + 1;
					start2 <= 0;
					start1 <= 0;
					ready <= 0;
				end
				else begin
					if (stop) begin
						state <= finish;
						ready <= 1;
						next <= 0;
					end
					else begin
						next <= 0;
						ready <= 1;
						wc <= 0;
						out <= running_sum;
						if (decoder_in == 0 && second_pass) begin
							state <= finish;
						end
						else begin
							if (decoder_in == 73) begin
								second_pass <= 1;
							end
							start1 <= 1;
							start2 <= 1;
							wc <= 0;
							if (second_pass) begin
								decoder_in <= decoder_in - 1;
							end
							else if (decoder_in != 73) begin
								decoder_in <= decoder_in + 1;
							end
							
						end
					end
				end
			end
			
			finish: begin	
				start1 <= 0;
				start2 <= 0;
				ready <= 1;
				next <= 0;
				out <= running_sum;
			end
			
			
			
		endcase
	end

endmodule