module Final_Project
#(parameter width = 32)
(
	input clk,
	input rst,
	input start,
	input [width-1:0] angle,
	output [width-1:0] fn1,
	output [width-1:0] fn2,
	output done
);
	
	typedef enum bit [2:0] {S0, S1, S2} states;
	wire [width-16:0] fn1_temp,fn2_temp;
	wire EN;
	wire [width-1:0] n_temp;
	
// -----select signal output is cos or sin-----

dff_nbit Dff
(
	.clk(clk),
	.rst(rst),
	.enable(EN),
	.D(angle),
	.Q(n_temp)
);

// ----------insert node---------
Cordic Cal
(
	.clock(clk),
	.rst(rst),
	.angle(n_temp),
	.cos(fn1_temp),
	.sin(fn2_temp)
);

states current_state, next_state;

//---------------------------------------
//					 		output
//---------------------------------------
always @(posedge done, posedge rst) begin
	if(done) begin
		fn1 <= {{width-17{1'b0}},fn1_temp};
		fn2 <= {{width-17{1'b0}},fn2_temp};
	end
	else
		if(rst) begin
			fn1 <= {width{1'b0}};
			fn2 <= {width{1'b0}};
		end
end

//----------------------------------------
//							FSM
//-----------------------------------------
always @(posedge rst, posedge clk) begin
	if(rst) begin
		current_state <= S0;
	end
	else
		current_state <= next_state;
end

always @(current_state, start, done) begin
	case(current_state)
		S0: begin if(start == 1'b1) next_state = S1;
					 else next_state = S0;
			 end
		S1:
			next_state = S2;
		S2: 
		begin
			if(done == 1'b1) begin
				next_state = S0;
			end
			else
				next_state = S2;
		end
		default: 
				next_state = S0;
	endcase
end

always @(current_state) begin
	done <= 1'b0;
	EN <= 1'b0;
	case(current_state)
		S0: begin
				EN <= 1'b1;
			 end
		S1: begin
				EN <= 1'b0;
			 end
		S2: begin
				done <= 1'b1;
			 end
	endcase
end
endmodule