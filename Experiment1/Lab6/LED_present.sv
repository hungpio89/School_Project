module d_ff_rise
#(parameter n = 9)
( 
	input [n-1:0] D,
	input En,
	input clk,
	output [n-1:0] Q
);
	
	always @(posedge clk) begin
		if (En == 1'b1) begin
			Q <= D; 
		end
	end
endmodule