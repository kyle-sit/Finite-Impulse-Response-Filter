module FIR_SSE (
	input logic clk, rst, stop,
	input logic [31:0] in, out_gold,
	output logic next, ready,
	output logic [31:0] out_filt, out_sse
);

logic frst, fstop, fnext, fready;
logic srst, sstop, snext, sready;
logic [31:0] fir_out;

FIR fir (
	.in(in), .out(fir_out),
	.clk(clk), .rst(frst), .stop(fstop), .next(fnext), .ready(fready)
);

SSE sse (
	.A(fir_out), .B(out_gold), .Y(out_sse),
	.clk(clk), .rst(srst), .stop(sstop), .next(snext), .ready(sready)
);

endmodule