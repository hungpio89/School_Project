module regn
#(parameter n = 9)
(
	input [n-1:0] R,
	input Rin,clk,
	output reg [n-1:0] Q
);

always @(posedge clk) begin
	if (Rin == 1'b1) begin
		Q <= R;
	end
end
endmodule