module FlipFlop_withoutreset
(
	input D,
	input clk,
	output Q
);
	always @(posedge clk) begin
		Q <= D; 
	end
endmodule