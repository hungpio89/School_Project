module dec3to8  
( 
	input [2:0] sel,
	input En,
	output [0:7] Y
);
	always @(sel,En) begin
		if (En == 1) begin
			case (sel)
				3'b000:  Y = 8'b10000000;
				3'b001:  Y = 8'b01000000;
				3'b010:  Y = 8'b00100000;
				3'b011:  Y = 8'b00010000;
				3'b100:  Y = 8'b00001000;
				3'b101:  Y = 8'b00000100;
				3'b110:  Y = 8'b00000010;
				default:  Y = 8'b00000001;
			endcase
		end
		else
			Y <= 8'b00000000;
	end
endmodule