
module labmininios (
	clk_clk,
	reset_reset,
	sdram_clk_clk,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	h_bridge_export,
	lcd_export,
	switch_export);	

	input		clk_clk;
	input		reset_reset;
	output		sdram_clk_clk;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output	[2:0]	h_bridge_export;
	output	[10:0]	lcd_export;
	input	[9:0]	switch_export;
endmodule
