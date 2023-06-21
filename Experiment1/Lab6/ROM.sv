module ROM
#(
	parameter width = 9,
	parameter depth = 128,
	parameter addrBits = 7
)
(
	input clk,
	input wr_en,
	input [width-1:0] DATAIN,
	input [addrBits-1:0] ADDRESS,
	output [width-1:0] q
);
	localparam intFile = "ROM.bin";
	logic [width-1:0] rom [0:depth-1];
	
	// initialise ROM contents
	initial begin
		$readmemh(intFile,rom);
	end

	always_ff @ (posedge clk) begin
		if(wr_en == 1'b0) begin
			q <= rom[ADDRESS];
		end
		else
			rom[ADDRESS] <= DATAIN;
	end
endmodule