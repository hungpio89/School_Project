module wrapper
#(parameter n = 9)
(
	input [1:0] KEY,
	input [9:9] SW,
	output [9:0 ]LEDR
);

// -------------------------------------------------------------------
	wire WR_EN, LED_ENABLE, W, LED_EN, w1, w2;
	wire [n-1:0] DIN, ADDR_BusWires, DOUT_BusWires;
// ------------------------------------------------------------------- 
 
// -- proc(DIN, resetn, Clock, Run, Done, BusWires);
Lab5 processor 
(
	.DIN(DIN), 
	.resetn(KEY[0]), 
	.clk(KEY[1]), 
	.Run(SW[9]), 
	.DOUT(DOUT_BusWires), 
	.ADDR(ADDR_BusWires), 
	.W(W), 
	.Done(LEDR[9])
);
 
	assign w2 = DOUT_BusWires[8] | DOUT_BusWires[7];

// --RAM_clk(clk,wr_en,datain,addr,q)

	assign WR_EN = ~(w2) & W;
	
ROM Memory 
(
	.clk(KEY[1]),
	.wr_en(WR_EN), 
	.DATAIN(DOUT_BusWires),
	.ADDRESS(ADDR_BusWires[6:0]), 
	.q(DIN)
);
	assign w1 = ~DOUT_BusWires[7] | DOUT_BusWires[8]; 
	assign LED_EN = ~w1 & W;
	
d_ff_rise LED_display 
(
	.D(DOUT_BusWires), 
	.En(LED_EN), 
	.clk(), 
	.Q(LEDR[8:0])
);

endmodule












