module	delayxms(
	input		wire			clk,		//20MHZ
	input		wire			reset,
	
	input		wire			enable_i,
	input		wire[1:0]	x,
	
	output	reg			ready
);

reg[3:0]		ready_t;
reg[3:0]		done_t;
reg[0:20]	cnt[0:3];

always	@	(posedge	clk or negedge rst)	begin		//10ms
	if(!reset)	begin
		ready_t[0]		<=	1'b0;
	end	else	
	if(enable_i)	begin
		if(done_t[0] == 1'b0)	begin
			if(cnt[0] == 18'd200000)	begin
				cnt[0]		<=	18'b0;
				done_t[0]	<= 1'b1;
				ready_t[0]	<=	1'b1;
			end	else	begin
				cnt[0]		<=	cnt + 1'b1;
				done_t[0]	<=	1'b0;
				ready_t[0]	<=	1'b0;
			end
		end	else	begin
			cnt[0]			<=	18'b0;
			done_t[0]		<=	1'b0;
			ready_t[0]		<=	1'b0;
		end
	end	else	begin
		cnt[0]				<=	18'b0;
		done_t[0]			<=	1'b0;
		ready_t[0]			<=	1'b0;
	end
end

endmodule 