module Cordic
#(parameter width = 32)
(
	input clock,
	input rst, 
	input [width-1:0] angle, 
	output signed [width-16:0] cos, sin
);
	
   reg  signed  [width -17:0] Xin;
   reg  signed  [width -17:0] Yin;
	
   //arctan_table
   
   // Note: The atan_table was chosen to be 31 bits wide giving resolution up to atan(2^-30)
   wire signed [width-1:0] atan_table [0:width-2];
   
   // upper 2 bits = 2'b00 which represents 0 - PI/2 range
   // upper 2 bits = 2'b01 which represents PI/2 to PI range
   // upper 2 bits = 2'b10 which represents PI to 3*PI/2 range (i.e. -PI/2 to -PI)
   // upper 2 bits = 2'b11 which represents 3*PI/2 to 2*PI range (i.e. 0 to -PI/2)
   // The upper 2 bits therefore tell us which quadrant we are in.
   assign atan_table[00] = 32'b00100000000000000000000000000000; // 45.000 degrees -> atan(2^0) we decode (45*(2^32/360)) = dec; transform into bin with width = 30 bit
   assign atan_table[01] = 32'b00010010111001000000010100011101; // 26.565 degrees -> atan(2^-1)
   assign atan_table[02] = 32'b00001001111110110011100001011011; // 14.036 degrees -> atan(2^-2)
   assign atan_table[03] = 32'b00000101000100010001000111010100; // 7.125  degrees -> atan(2^-3)
   assign atan_table[04] = 32'b00000010100010110000110101000011; // 3.576  degrees -> atan(2^-4)
   assign atan_table[05] = 32'b00000001010001011101011111100001; // 1.789  degrees -> atan(2^-5)
   assign atan_table[06] = 32'b00000000101000101111011000011110; // 0.895  degrees -> atan(2^-6)
   assign atan_table[07] = 32'b00000000010100010111110001010101; // 0.447  degrees -> atan(2^-7)
   assign atan_table[08] = 32'b00000000001010001011111001010011; // 0.224  degrees -> atan(2^-8)
   assign atan_table[09] = 32'b00000000000101000101111100101110; // 0.112  degrees -> atan(2^-9)
   assign atan_table[10] = 32'b00000000000010100010111110011000; // 0.056  degrees -> atan(2^-10)
   assign atan_table[11] = 32'b00000000000001010001011111001100; // 0.028  degrees -> atan(2^-11)
   assign atan_table[12] = 32'b00000000000000101000101111100110; 
   assign atan_table[13] = 32'b00000000000000010100010111110011; 
   assign atan_table[14] = 32'b00000000000000001010001011111001; 
   assign atan_table[15] = 32'b00000000000000000101000101111101; 
   assign atan_table[16] = 32'b00000000000000000010100010111110; 
   assign atan_table[17] = 32'b00000000000000000001010001011111;
   assign atan_table[18] = 32'b00000000000000000000101000101111; 
   assign atan_table[19] = 32'b00000000000000000000010100011000; 
   assign atan_table[20] = 32'b00000000000000000000001010001100;
   assign atan_table[21] = 32'b00000000000000000000000101000110; 
   assign atan_table[22] = 32'b00000000000000000000000010100011;
   assign atan_table[23] = 32'b00000000000000000000000001010001; 
   assign atan_table[24] = 32'b00000000000000000000000000101000; 
   assign atan_table[25] = 32'b00000000000000000000000000010100; 
   assign atan_table[26] = 32'b00000000000000000000000000001010;
   assign atan_table[27] = 32'b00000000000000000000000000000101;
   assign atan_table[28] = 32'b00000000000000000000000000000010;
   assign atan_table[29] = 32'b00000000000000000000000000000001; //atan(2^-29)
   assign atan_table[30] = 32'b00000000000000000000000000000000; // 0      degrees -> atan(2^-30)
   
   //------------------------------------------------------------------------------
   //                              registers
   //------------------------------------------------------------------------------
   
   //stage outputs
   reg signed [width-16 :0] X [0:width-17];
   reg signed [width-16 :0] Y [0:width-17];
   reg signed    [width-1:0] Z [0:width-17]; // 32bit
		
   //------------------------------------------------------------------------------
   //                               stage 0
   //------------------------------------------------------------------------------
   wire                 [1:0] quadrant;
   assign   quadrant = angle[31:30];
   always @(posedge clock, posedge rst) begin // make sure the rotation angle is in the -pi/2 to pi/2 range.  If not then pre-rotate
		Xin = 16'b0100101111100111;  // K-coeficient 0.6072 convert into bin
		Yin = {16{1'b0}};
		if(rst) begin
			X[0] <= 0;
			Y[0] <= 0;
			Z[0] <= 0;
		end
		else
			case (quadrant)
				2'b00,2'b11: begin    // X[n], Y[n] is 1 bit larger than Xin, Yin, but Verilog handles the assignments properly
					X[0] <= Xin;
					Y[0] <= Yin;
					Z[0] <= angle;
				end
				2'b01: begin
					X[0] <= -Yin;
					Y[0] <= Xin;
					Z[0] <= {2'b00,{angle[29:0]}}; // subtract pi/2 from angle for this quadrant
				end
				2'b10: begin
					X[0] <= Yin;
					Y[0] <= -Xin;
					Z[0] <= {2'b11,{angle[29:0]}}; // add pi/2 to angle for this quadrant
				end
			endcase
	end
   
   //------------------------------------------------------------------------------
   //                           generate stages 1 to STG-1
   //------------------------------------------------------------------------------
   genvar i;

   generate
   for (i=0; i < 15; i=i+1) begin: XYZ
      wire                   Z_sign;
		wire signed  [width-16 :0] X_shr, Y_shr;  
		
      assign X_shr = X[i] >> i; // signed shift right
      assign Y_shr = Y[i] >> i;
   
      //the sign of the current rotation angle
      assign Z_sign = Z[i][31]; // Z_sign = 1 if Z[i] < 0
		
      always @(*) begin
			// add/subtract shifted data
			X[i+1] <= Z_sign ? X[i] + Y_shr         : X[i] - Y_shr;
			Y[i+1] <= Z_sign ? Y[i] - X_shr         : Y[i] + X_shr;
			Z[i+1] <= Z_sign ? Z[i] + atan_table[i] : Z[i] - atan_table[i];
      end
   end
   endgenerate
   
   
   //------------------------------------------------------------------------------
   //                                 output
   //------------------------------------------------------------------------------
	always @(posedge clock) begin
		if (rst) begin
			cos <= 0;
			sin <= 0;
		end 
		else 
			cos <= X[15];
			sin <= Y[15];
	end

endmodule