/* File containing module code for a floating point adder
*/

//adder module
module adder_fp(
	input logic clk, start, op,
	input logic [31:0] A, B,
	output logic ready, busy,
	output logic [31:0] Y	
);

	logic [3:0] state = 4'd0; // 3 states = 2 bits
	parameter idle = 4'd0, checks = 4'd1, operation = 4'd2, addition = 4'd3, subtraction = 4'd4, leadingZero = 4'd5, 
		finished = 4'd6;
	logic A_sign, B_sign, isSet, group2;
	logic [23:0] A_mantissa, B_mantissa, final_mantissa;
	logic [7:0] A_exponent, B_exponent, final_exponent;
	logic [24:0] output_mantissa;
	
	always_ff @(posedge clk) begin
		case(state)
			idle: begin
				ready <= 0;
				busy <= 0;
				if (start) begin
					state <= checks;
					A_sign <= A[31];
					A_exponent <= A[30:23];
					A_mantissa <= {1'b1, A[22:0]};
					B_sign <= B[31];
					B_exponent <= B[30:23];
					B_mantissa <= {1'b1, B[22:0]};
					isSet <= 0;
					group2 <= 0;
				end
			end
			
				// infinity = 8'b11111111 for exponent, 0 for mantissa
				// NaN = 8'b11111111 for exponent, xxxx... for mantissa
				//case if either input is NaN
			
			checks: begin
				busy <= 1;
				if (A == 0) begin
					if (!op) begin
						Y <= B;
					end
					else begin
						Y <= {!B[31], B[30:0]};
					end
					isSet <= 1;
					state <= finished;
				end
				else if (B == 0) begin
					Y <= A;
					isSet <= 1;
					state <= finished;
				end
				else if(((A_exponent == 8'b11111111) && (A_mantissa[22:0] > 0)) || ((B_exponent == 8'b11111111) && (B_mantissa[22:0] > 0))) begin
					Y <= {1'b0,8'b11111111,22'b0,1'b1};
					isSet <= 1;
					state <= finished;
				end
				//case if both inputs are infinity
				else if ((A_exponent == 8'b11111111 && A_mantissa[22:0] == 0) && (B_exponent == 8'b11111111 && B_mantissa[22:0] == 0)) begin
					if (A_sign == B_sign) begin
						if (op) begin
							Y <= {1'b0,8'b11111111,22'b0,1'b1};
							isSet <= 1;
							state <= finished;
						end
						else begin
							Y <= A;
							isSet <= 1;
							state <= finished;
						end
					end
					else begin
						if(!op) begin
							Y <= {1'b0,8'b11111111,22'b0,1'b1};
							isSet <= 1;
							state <= finished;
						end
						else begin
							Y <= A;
							isSet <= 1;
							state <= finished;
						end
					end
				end
				//case if A input is infinity
				else if (A_exponent == 8'b11111111 && A_mantissa[22:0] == 0) begin
					Y <= A;
					isSet <= 1;
					state <= finished;
				end
				//case if B input is infinity
				else if (B_exponent == 8'b11111111 && B_mantissa[22:0] == 0) begin
					Y <= B;
					isSet <= 1;
					state <= finished;
				end
				else begin
					// figure out which number is bigger
					if (A_exponent < B_exponent) begin
						A_mantissa <= A_mantissa >> (B_exponent - A_exponent);
						final_exponent <= B_exponent;
					end
					else begin 
						B_mantissa <= B_mantissa >> (A_exponent - B_exponent);
						final_exponent <= A_exponent;
					end
					state <= operation;
				end
			end
			
			// 3
			operation: begin
					// adding same sign or subtracting different signs = addition logic
					if ((!op && !A_sign && !B_sign) || (!op && A_sign && B_sign) || (op && !A_sign && B_sign) || (op && A_sign && !B_sign)) begin
						output_mantissa <= A_mantissa + B_mantissa;
						state <= addition;
					end
					else begin
						group2 <= 1;
						state <= subtraction;
					end
			end
			
			// 4
			addition: begin
				// if there's overflow
				if (output_mantissa[24] == 1) begin
					final_exponent <= final_exponent + 1;
					if (output_mantissa[0] == 1) begin
						final_mantissa <= output_mantissa[24:1] + 1;
					end
					else begin
						final_mantissa <= output_mantissa[24:1];
					end
								
					if (final_exponent == 255) begin
						final_mantissa <= 0;
					end
								
				end
				// no overflow
				else begin
					final_mantissa <= output_mantissa[23:0];
				end
	
				state <= finished;
			end
			
			// 4
			subtraction: begin
				// adding different sign or subtracting same signs
				if (A_mantissa < B_mantissa) begin 
					output_mantissa <= B_mantissa - A_mantissa;
					state <= leadingZero;
				end
				else if (B_mantissa < A_mantissa) begin
					output_mantissa <= A_mantissa - B_mantissa;
					state <= leadingZero;
				end
				else begin
						Y <= 0;
						state <= finished;
						isSet <= 1;
				end

			end
			
			// 5
			leadingZero: begin
				/*if (output_mantissa[23] != 0) begin
					final_mantissa <= output_mantissa[23:0];
					state <= finished;
				end
				else begin
					output_mantissa <= output_mantissa << 1;
					final_exponent <= final_exponent - 1;
					state <= leadingZero;
				end*/
				
				casez(output_mantissa[23:0])
					24'b1???????????????????????: begin final_mantissa <= output_mantissa[23:0]; end
					24'b01??????????????????????: begin final_mantissa <= output_mantissa[23:0] << 1; final_exponent <= final_exponent - 1; end
					24'b001?????????????????????: begin final_mantissa <= output_mantissa[23:0] << 2; final_exponent <= final_exponent - 2; end
					24'b0001????????????????????: begin final_mantissa <= output_mantissa[23:0] << 3; final_exponent <= final_exponent - 3; end
					24'b00001???????????????????: begin final_mantissa <= output_mantissa[23:0] << 4; final_exponent <= final_exponent - 4; end
					24'b000001??????????????????: begin final_mantissa <= output_mantissa[23:0] << 5; final_exponent <= final_exponent - 5; end
					24'b0000001?????????????????: begin final_mantissa <= output_mantissa[23:0] << 6; final_exponent <= final_exponent - 6; end
					24'b00000001????????????????: begin final_mantissa <= output_mantissa[23:0] << 7; final_exponent <= final_exponent - 7; end
					24'b000000001???????????????: begin final_mantissa <= output_mantissa[23:0] << 8; final_exponent <= final_exponent - 8; end
					24'b0000000001??????????????: begin final_mantissa <= output_mantissa[23:0] << 9; final_exponent <= final_exponent - 9; end
					24'b00000000001?????????????: begin final_mantissa <= output_mantissa[23:0] << 10; final_exponent <= final_exponent - 10; end
					24'b000000000001????????????: begin final_mantissa <= output_mantissa[23:0] << 11; final_exponent <= final_exponent - 11; end
					24'b0000000000001???????????: begin final_mantissa <= output_mantissa[23:0] << 12; final_exponent <= final_exponent - 12; end
					24'b00000000000001??????????: begin final_mantissa <= output_mantissa[23:0] << 13; final_exponent <= final_exponent - 13; end
					24'b000000000000001?????????: begin final_mantissa <= output_mantissa[23:0] << 14; final_exponent <= final_exponent - 14; end
					24'b0000000000000001????????: begin final_mantissa <= output_mantissa[23:0] << 15; final_exponent <= final_exponent - 15; end
					24'b00000000000000001???????: begin final_mantissa <= output_mantissa[23:0] << 16; final_exponent <= final_exponent - 16; end
					24'b000000000000000001??????: begin final_mantissa <= output_mantissa[23:0] << 17; final_exponent <= final_exponent - 17; end
					24'b0000000000000000001?????: begin final_mantissa <= output_mantissa[23:0] << 18; final_exponent <= final_exponent - 18; end
					24'b00000000000000000001????: begin final_mantissa <= output_mantissa[23:0] << 19; final_exponent <= final_exponent - 19; end
					24'b000000000000000000001???: begin final_mantissa <= output_mantissa[23:0] << 20; final_exponent <= final_exponent - 20; end
					24'b0000000000000000000001??: begin final_mantissa <= output_mantissa[23:0] << 21; final_exponent <= final_exponent - 21; end
					24'b00000000000000000000001?: begin final_mantissa <= output_mantissa[23:0] << 22; final_exponent <= final_exponent - 22; end
					default: begin final_mantissa = output_mantissa[23:0] << 23; final_exponent <= final_exponent - 23; end
				endcase
				state <= finished;
			end
			
			// 6
			finished: begin
				if (isSet) begin
				end
				else if ((A_mantissa < B_mantissa) && group2 ) begin
					Y <= {!A_sign, final_exponent, final_mantissa[22:0]};
				end
				else begin
					Y <= {A_sign, final_exponent, final_mantissa[22:0]};
				end
				ready <= 1;
				state <= idle; 
			end
			
		endcase
	end

endmodule