module dff_nbit
#(parameter width = 32)
(
  	input clk,
	input rst,
	input enable,
	input [width-1:0] D,
	output [width-1:0] Q
);
always @(posedge clk, posedge rst) begin
	if(rst) begin
		Q <= {width{1'b0}};
	end
	else 
		if(enable == 1'b1) begin
			Q <= D;
		end
end
endmodule