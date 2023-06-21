module Normalize
(
	input [5:0] DATAIN,
	input [2:0] exp_com,
	output [3:0] Exp,
	output [3:0] DATAOUT
);
	wire [3:0] pre_DATAOUT;
	wire [3:0] pre_Exp;
	always @(DATAIN, exp_com) begin
		pre_DATAOUT = 0;
		pre_Exp = 0;
		if(DATAIN[5] == 1) begin
			pre_DATAOUT = DATAIN[4:1];
			pre_Exp = exp_com + 3'b001;
		end
		else 
			if (DATAIN[4] == 1) begin
				pre_DATAOUT = DATAIN[3:0];
				pre_Exp = exp_com;
			end
			else
				if (DATAIN[3] == 1) begin
					pre_DATAOUT = {{DATAIN[2:0]},1'b0};
					pre_Exp = exp_com - 3'b001;
				end
				else
					if(DATAIN[2] == 1) begin
						pre_DATAOUT = {{DATAIN[1:0]},2'b00};
						pre_Exp = exp_com - 3'b010;
					end
					else
						if (DATAIN[1] == 1) begin
							pre_DATAOUT = {{DATAIN[0]},3'b000};
							pre_Exp = exp_com - 3'b011;
						end
						else 
							if (DATAIN[0] == 1) begin
								pre_DATAOUT = 0;
								pre_Exp = exp_com - 3'b100;
							end
	end
	assign DATAOUT = pre_DATAOUT;
	assign Exp = pre_Exp;
endmodule