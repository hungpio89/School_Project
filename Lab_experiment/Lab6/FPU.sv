module FPU
#(parameter n = 9)
(
	input [n-1:0] DATAIN_1, DATAIN_2,
	input  AddSubF,
	output [3:0] exp_Diff,
	output [3:0] smaller_fract,
	output [3:0] larger_fract,
	output [5:0] pre_out,
	output [5:0] shifted_fract,
	output [5:0] pre_fract,
	output [n-1:0] DATAOUT	
);
	 //smaller_fract;
	reg [2:0] exp_A, exp_B;
//	reg [3:0] exp_Diff;
	reg [4:0] fract_Diff;
	
	
	wire [2:0] shift_amount;
	
	wire [2:0] exp_com;
	wire [3:0] OUT1,OUT2;
	wire Result_sign;

	always @(DATAIN_1[7:4], DATAIN_2[7:4]) begin
		exp_A = (DATAIN_1[7] == 0)?DATAIN_1[6:4]:~DATAIN_1[6:4];
		exp_B = (DATAIN_2[7] == 0)?DATAIN_2[6:4]:~DATAIN_2[6:4];
	end
	
	assign exp_Diff = exp_A - exp_B;
	assign fract_Diff = DATAIN_1[3:0] - DATAIN_2[3:0];
	
	always @(exp_Diff, fract_Diff, DATAIN_1[3:0], DATAIN_2[3:0], exp_A, exp_B) begin
		larger_fract <= 0;
		smaller_fract <= 0;
		if(exp_Diff[3] == 1'b0) begin
		
			if (exp_Diff[2:0] != 3'b000) begin
				larger_fract <= DATAIN_1[3:0];
				smaller_fract <= DATAIN_2[3:0];
				shift_amount = exp_Diff[2:0];
				exp_com = exp_A;
			end
			
			else if (exp_Diff[2:0] == 3'b000) begin
				if(fract_Diff[4] == 1'b0) begin
					larger_fract <= DATAIN_1[3:0];
					smaller_fract <= DATAIN_2[3:0];
					shift_amount = exp_Diff[2:0];
					exp_com = exp_A;
				end
				else begin
					larger_fract <= DATAIN_2[3:0];
					smaller_fract <= DATAIN_1[3:0];
					shift_amount = exp_Diff[2:0];
					exp_com = exp_B;
				end
			end
		end
		else begin 
			if(exp_Diff[3] == 1'b1) begin
				larger_fract <= DATAIN_2[3:0];
				smaller_fract <= DATAIN_1[3:0];
				shift_amount = ~exp_Diff[2:0];
				exp_com = exp_B;
			end
		end
	end

	Shifter S1 (smaller_fract, shift_amount, shifted_fract);
	
	assign pre_fract = {2'b01,{larger_fract}};
	
	always @(AddSubF, pre_fract, shifted_fract) begin
		pre_out = {6{1'b0}};
		if(AddSubF == 1'b0) begin
			pre_out <= pre_fract + shifted_fract;
		end
		else
			pre_out <= 0;
	end

	Normalize N1 (pre_out, exp_com, OUT1, OUT2);
	
	always @(exp_Diff, fract_Diff, DATAIN_1, DATAIN_2) begin
		if (exp_Diff[3] == 0) begin
			if(exp_Diff[2:0] != 0) begin
				Result_sign = DATAIN_1[8];
			end
			else
				if (fract_Diff[4] == 0) begin
					Result_sign = DATAIN_1[8];
				end
				else
					Result_sign = DATAIN_2[8];
		end
		else
			Result_sign = DATAIN_2[8];
	end
	
	assign DATAOUT[7:4] = OUT1;
	assign DATAOUT[3:0] = OUT2;
	assign DATAOUT[8] = Result_sign;
endmodule