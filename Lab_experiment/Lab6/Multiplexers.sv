module Multiplexers
(
	input [8:0] R0,R1,R2,R3,R4,R5,R6,R7,G,GF,DIN,
	input [0:7] Rout,
	input [1:0] Gout,
	input DINout,
	output [8:0] BusWires
);
	
	always @(*) begin
		if(Rout[0] == 1) begin
			BusWires = R0;
		end
		else if(Rout[1] == 1) begin
			BusWires = R1;
		end
		else if(Rout[2] == 1) begin
			BusWires = R2;
		end
		else if(Rout[3] == 1) begin
			BusWires = R3;
		end
		else if(Rout[4] == 1) begin
			BusWires = R4;
		end
		else if(Rout[5] == 1) begin
			BusWires = R5;
		end
		else if(Rout[6] == 1) begin
			BusWires = R6;
		end
		else if(Rout[7] == 1) begin
			BusWires = R7;
		end
		else if(Gout == 2'b10) begin
			BusWires = G;
		end
		else if(Gout == 2'b01) begin
			BusWires = GF;
		end
		else if(DINout == 1) begin
			BusWires = DIN;
		end
		else
			BusWires = 0;
	end
endmodule