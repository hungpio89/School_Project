module flipflop 
( 
	input D,
	input resetn, clk,
	output Q
);
	
	always @(posedge clk, negedge resetn) begin
		if (!resetn) begin
			Q <= 0;
		end
		else
			Q <= D; 
	end
endmodule