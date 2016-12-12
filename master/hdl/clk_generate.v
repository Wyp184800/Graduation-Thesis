module	clk_generate(
	input		wire		clk,			//20MHZ
	input		wire		reset,
	
	output	reg		scan_clk,	//1MHZ
	output	reg		flash_clk	//10HZ
	
//	output	reg		decoder_clk	//64MHZ
);

reg[3:0]		scan_clk_cnt;
reg[19:0]	flash_clk_cnt;

always	@	(posedge	clk)	begin		//scan_clk	generate	1MHZ
	if(!reset)	begin
		scan_clk				<=	1'b0;
		scan_clk_cnt		<=	4'h0;
	end	else	begin
		if(scan_clk_cnt == 4'ha)	begin		//clk=20M, flip=10
			scan_clk			<=	~scan_clk;
			scan_clk_cnt	<=	4'h0;
		end	else	begin
			scan_clk_cnt	<=	scan_clk_cnt + 1;
		end
	end
end

always	@	(posedge	clk)	begin		//flash_clk generate 10HZ
	if(!reset)	begin
		flash_clk		<=	1'b0;
		flash_clk_cnt	<=	20'h0;
	end	else	begin
		if(flash_clk_cnt == 20'hF4240)	begin		//clk=20M,flip=1000000
			flash_clk		<=	~flash_clk;
			flash_clk_cnt	<=	20'b0;
		end	else	begin
			flash_clk_cnt	<=	flash_clk_cnt + 1;
		end
	end
end

//use EMP IP to generate decoder_clk

endmodule 