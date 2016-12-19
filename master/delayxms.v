/*功耗优化：输入使能信号只控制一个always块，拓宽输入信号宽度*/

module	delayxms(
	input		wire			clk,
	input		wire			scan_clk,		//1MHZ
	input		wire			reset,
	
	input		wire			enable_i,
	input		wire[1:0]	x,
	
	output	reg			ready
);

reg[3:0]		ready_t;
reg[3:0]		done_t;
reg[20:0]	cnt[0:3];

always	@	(posedge	scan_clk or negedge rst)	begin		//10ms
	if(!reset)	begin
		ready_t[0]		<=	1'b0;
	end	else	begin
		if(enable_i)	begin
			if(done_t[0] == 1'b0)	begin
				if(cnt[0] == 17'd10000)	begin
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
end

always	@	(posedge scan_clk or negedge reset)	begin		//2s
	if(!reset)	begin
		ready_t[1]		<=	1'b0;
	end	else	begin
		if(enable_i)	begin
			if(done_t[1] == 1'b0)	begin
				if(cnt[1] == 21'd2000000)	begin
					cnt[1]		<=	21'b0;
					done_t[1]	<= 1'b1;
					ready_t[1]	<=	1'b1;
				end	else	begin
					cnt[1]		<=	cnt + 1'b1;
					done_t[1]	<=	1'b0;
					ready_t[1]	<=	1'b0;
				end
			end	else	begin
				cnt[1]			<=	21'b0;
				done_t[1]		<=	1'b0;
				ready_t[1]		<=	1'b0;
			end
		end	else	begin
			cnt[1]				<=	21'b0;
			done_t[1]			<=	1'b0;
			ready_t[1]			<=	1'b0;
		end
	end
end

always	@	(posedge	clk or negedge reset)	begin
	if(!reset)	begin
		ready	<=	1'b0;
	end	else	begin
		case(x)
			2'b00:	ready	<=	ready_t[0];
			2'b01:	ready	<=	ready_t[1];
			2'b10:	ready	<=	ready_t[2];
			2'b11:	ready	<=	ready_t[3];
			default:	ready	<=	1'b0;
		endcase
	end
end

endmodule 