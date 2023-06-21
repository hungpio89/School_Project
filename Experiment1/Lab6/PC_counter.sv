module Counter
#(parameter n = 9)
( 
	input [n-1:0] R,
	input resetn, clk, incr_PC, PC_EN,
	output [n-1:0] Q
);
	wire [n-1:0] Count;
	always @(posedge clk, negedge resetn) begin
		if (!resetn) begin
			Count <= {n{1'b0}};
		end
		else 
			if (PC_EN == 1'b1) begin
				Count <= R;
			end
			else if (incr_PC == 1) begin
				Count <= Count + 1;
			end
	end
assign Q = Count;
endmodule