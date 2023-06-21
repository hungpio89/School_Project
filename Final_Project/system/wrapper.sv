module wrapper
#(
	parameter width = 32
)
(
	input clk,
	input rst,
	input write_n,
	input chipselect,
	input [2:0] address,
	input [width-1:0] writedata,
	output [width-1:0] readdata
);

Final_Project FP1
(
	.clk(clk),
	.rst(rst),
	.start(wr_start),
	.angle(n_reg),
	.fn1(fn1_reg),
	.fn2(fn2_reg),
	.done(set_done_tick)
);
//-----------------------------------
//						wire
//------------------------------------
wire wr_en;
wire rd_en;
wire wr_start;
wire wr_n;
wire SW;

// --Reg n ----
reg [width-1:0] n_reg; 

//--Reg fn ----
reg [width-1:0] fn1_reg; 
reg [width-1:0] fn2_reg;


wire done_tick;
wire set_done_tick;
wire clr_done_tick;

	always @(posedge clk, posedge rst) begin
		begin
			if (rst) begin
				n_reg <= {width{1'b0}};
				done_tick <= 1'b0;
			end
			else if (wr_n == 1'b1) begin
				n_reg <= writedata[width-1:0];
			end	
			else
				if (set_done_tick == 1'b1) begin
					done_tick <= 1'b1;
				end
				else if (clr_done_tick == 1'b1) begin
					done_tick <= 1'b0;
				end	
		end
	end

// --Write decoding logic----

	always @(*) begin
	wr_en <= 0;
	rd_en <= 0;
	wr_start <= 0;
	wr_n <= 0;
	clr_done_tick <= 0;
	readdata <= 0;
		 wr_en <= (write_n == 1'b0 && chipselect == 1'b1)?1'b1:1'b0;
		 wr_n <= (address == 3'b000 && wr_en == 1'b1)?1'b1:1'b0;
		 wr_start <= (address == 3'b001 && wr_en == 1'b1)?1'b1:1'b0;
		 clr_done_tick <= (address == 3'b100 && wr_en == 1'b1)?1'b1:1'b0;

// --Read decoding logic---

		 rd_en <= (write_n == 1'b1 && chipselect == 1'b1)?1'b1:1'b0;
		case(address)
			3'b000: begin if(rd_en == 1'b1) readdata <= n_reg; end
			3'b010: begin if(rd_en == 1'b1) readdata <= fn1_reg; end
			3'b011: begin if(rd_en == 1'b1) readdata <= fn2_reg; end
			3'b100: begin if(rd_en == 1'b1) readdata[0] <= done_tick; readdata[width-1:1] <= {width-1{1'b0}}; end
			default: begin if(rd_en == 1'b1) readdata <= {width{1'b0}}; end
		endcase
	end

endmodule
