module Lab6
#(parameter n = 9)
( 
	input [n-1:0] DIN,
	input resetn, clk, Run,
	output [n-1:0] DOUT,
	output [n-1:0] ADDR,
	output W,
	output Done
);

typedef enum bit [2:0] {T0 = 3'b000, T1 = 3'b001, T2 = 3'b010, T3 = 3'b011, T4 = 3'b100, T5 = 3'b101} state;

wire [0:7] Rin, Rout;
wire [n-1:0] BusWires, Sum, SumF;
wire IRin, ADDRin, DINout, DOUTin, Ain, AFin, Gin, GFin, AddSub, AddSubF;
wire [1:0] Gout;
state Tstep_Q,Tstep_D;

reg [2:0] I;
reg [0:7] Xreg, Yreg;
reg [n-1:0] R0, R1, R2, R3, R4, R5, R6, R7, A, AF, GF, G;
reg [1:n] IR;
wire pc_incr, W_D, Z_D;

	// Control FSM state table
	always @(Tstep_Q, Run, Done) begin
		case (Tstep_Q)
			T0: // data is loaded into IR in this time step
				if (!Run) Tstep_D = T0;
				else Tstep_D = T1;
			T1: //
				Tstep_D = T2;
			T2: //
				Tstep_D = T3;
			T3: //
			begin
				if(Done == 1'b1) Tstep_D = T0;
				else Tstep_D = T4;
			end
			T4: //
				Tstep_D = T5;
			T5: //
				if(Done == 1'b1) Tstep_D = T0;
				else Tstep_D = T5;
			default: Tstep_D = T0;
		endcase
	end
	
	// Control FSM flip-flops
	always @(posedge clk, negedge resetn) begin
		if (!resetn) begin
			Tstep_Q <= T0;
		end
		else
			Tstep_Q <= Tstep_D;
	end

	assign I = IR[1:3];
	dec3to8 DecX (IR[4:6], 1'b1, Xreg);
	dec3to8 DecY (IR[7:9], 1'b1, Yreg);
 
//-- Instruction Table
//-- 000: mv Rx,Ry  : Rx <- [Ry]
//-- 001: mvi Rx,#D : Rx <- D
//-- 010: add Rx,Ry : Rx <- [Rx] + [Ry]
//-- 011: sub Rx,Ry : Rx <- [Rx] - [Ry]
//-- 100: ld Rx,[Ry] : Rx <- [[Ry]]
//-- 101: st Rx,[Ry] : [Ry] <- [Rx]
//-- 110: mvnz Rx,Ry : if Z != 0, Rx <- [Ry]
//-- OPCODE format: III XXX YYY UUUUUUU, where 
//-- III = instruction, XXX = Rx, YYY = Ry, and U = unused bit. For mvi,
//-- a second word of data is read in the following clock cycle
//--
//-- R7 is the program counter

	always @(Tstep_Q, I, Xreg, Yreg, Z_D, Run) begin
		case(Tstep_Q)
			T0: // -- fetch the instruction
			begin
					Rout <= 8'b00000001; 	 //-- R7 is program counter (pc)
					ADDRin <= 1'b1;
					pc_incr <= Run; 		    //-- to increment pc
			end
			T1: // -- wait cycle for synchronous memory
				 //-- in case the instruction turns out to be mvi, read memory
			begin
					Rout <= 8'b00000001; 	 //-- R7 is program counter (pc)
					ADDRin <= 1'b1;
			end
			T2: // -- store DIN in IR 
					IRin <= 1'b1;
			T3: // -- define signals in T3
				case(I)
					3'b000: // -- mv Rx,Ry
					begin
							Rout <= Yreg;
							Rin <= Xreg;
							Done_tick <= 1'b1;
					end
					3'b001: // -- mvi Rx,#D
					begin
						 // -- data is available now on DIN
							DINout <= 1'b1;
							Rin <= Xreg;
							pc_incr <= 1'b1;
							Done <= 1'b1;
					end
					3'b010: // -- add
					begin
							Rout <= Xreg;
							Ain <= 1'b1;
					end
					3'b011: // -- sub
					begin
							Rout <= Xreg;
							Ain <= 1'b1;
					end
					3'b100: // -- ld Rx,[Ry]
					begin
							Rout <= Yreg;
							ADDRin <= 1'b1;
					end
					3'b101: // -- st [Ry],Rx
					begin
							Rout <= Yreg;
							ADDRin <= 1'b1;
					end
					3'b110: // -- mvnz Rx,Ry 
					begin
							if (Z_D == 1'b1) begin
								Rout <= Yreg;
								Rin <= Xreg;
								Done <= 1'b1;
							end
							else
								Rout <= 8'b00000000;
								Rin  <= 8'b00000000;
								Done <= 1'b1;
					end
					default: 
					begin 
						Rout <= 8'b00000000;
						Rin  <= 8'b00000000;
					end
					3'b111: // -- addf Rx,Ry
					begin
						Rout <= Xreg;
						AFin <= 1'b1;
					end
				endcase
					
			T4: // -- define signals T4
					case(I)
						3'b010: // -- add
						begin
							Rout <= Yreg;
							Gin <= 1'b1;
						end
						3'b011: // -- sub
						begin
							Rout <= Yreg;
							AddSub <= 1'b1;
							Gin <= 1'b1;
						end
						3'b100: // -- ld Rx,[Ry]
						begin
							W_D <= 1'b0; 		  // -- do nothing--wait cycle for synchronous memory
						end
						3'b101: // -- st [Ry],Rx
						begin
							Rout <= Xreg;
							DOUTin <= 1'b1;
							W_D <= 1'b1;
						end
						3'b111: // -- addf
						begin
							Rout <= Yreg;
							GFin <= 1'b1;
							AddSubF <= 1'b0;
						end
					endcase
			T5: // -- define signal in T5
					case(I)
						3'b010: // -- for add instruction step
						begin
							Gout <= 2'b10;
							Rin <= Xreg;
							Done_tick <= 1'b1;
						end
						3'b011: // --  for sub instruction step
						begin
							Gout <= 2'b10;
							Rin <= Xreg;
							Done_tick <= 1'b1;
						end
						3'b100: // --  ld Rx,[Ry]
						begin
							DINout <= 1'b1;
							Rin <= Xreg;
							Done_tick <= 1'b1; 
						end
						3'b101: // -- st [Ry],Rx
						begin
							Done_tick <= 1'b1;  //  -- wait cycle for synhronous memory
						end
						3'b111: // Addf
						begin
							Gout <= 2'b01;
							Rin <= Xreg;
							Done_tick <= 1'b1;
						end
					endcase
		endcase
	end
 
	regn Reg_0 (BusWires, Rin[0], clk, R0);
	regn Reg_1 (BusWires, Rin[1], clk, R1);
	regn Reg_2 (BusWires, Rin[2], clk, R2);
	regn Reg_3 (BusWires, Rin[3], clk, R3);
	regn Reg_4 (BusWires, Rin[4], clk, R4);
	regn Reg_5 (BusWires, Rin[5], clk, R5);
	regn Reg_6 (BusWires, Rin[6], clk, R6);
	Counter pc    (BusWires, resetn , clk, pc_incr, Rin[7], R7);
	regn Reg_A     (BusWires, Ain   , clk, A);
	regn Reg_AF		(BusWires, AFin  , clk, AF);
	regn Reg_DOUT  (BusWires, DOUTin, clk, DOUT);
	regn Reg_ADDR  (BusWires, ADDRin, clk, ADDR);
	regn Reg_IR    (DIN     , IRin  , clk, IR);
	FlipFlop_withoutreset Reg_W (W_D     , clk, W);
	FPU F1 (AF, BusWires, AddSubF, SumF);
 
	always @(AddSub, A, BusWires) begin
		if(AddSub == 1'b0) begin
			Sum <= A + BusWires; // -- ADD operation
		end
		else
			Sum <= A - BusWires; // -- SUBTRACT operation
	end
	
	regn Reg_G (Sum, Gin, clk, G);
	regn Reg_GF (SumF, GFin, clk, GF);
	
	assign Z_D = (G == '0)?1'b0:1'b1;
 
// -- define the internal processor bus
	
	Multiplexers MUX (R0, R1, R2, R3, R4, R5, R6, R7, G, GF, DIN, Rout[0:7], Gout, DINout, BusWires);
	
assign Done = Done_tick;
endmodule