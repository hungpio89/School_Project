module Shifter
(
	input [3:0] smaller_fract,
	input [2:0] shift_amount,
	output [5:0] shifted_fract
);
	wire [5:0] pre_smaller_fract;
	assign pre_smaller_fract = {2'b01,{smaller_fract}};
	always @(shift_amount, pre_smaller_fract) begin
		case(shift_amount)
			3'b000: shifted_fract = pre_smaller_fract;
			3'b001: shifted_fract = {1'b0,{pre_smaller_fract[5:1]}};
			3'b010: shifted_fract = {2'b00,{pre_smaller_fract[5:2]}};
			3'b011: shifted_fract = {3'b000,{pre_smaller_fract[5:3]}};
			default: shifted_fract = {6{1'b0}};
		endcase
	end
endmodule