`include	"defines.v"

module	display(
	input		wire			scan_clk,
	input		wire			flash_clk,
	input		wire			reset,
	input		wire[39:0]	data_in,
	input		wire[2:0]	seg_mode,
	input		wire[3:0]	flash_select,

	output	reg[7:0]		seg_out,
	output	reg[3:0]		seg_select,
	output	reg[2:0]		flash_cnt
);

always	@	(posedge	scan_clk)	begin
	if(!reset)	begin
		seg_select		<=	4'h0;
	end	else	begin
		if(seg_select == 4'h4)	begin
			seg_select	<=	4'h0;
		end	else	begin
			seg_select	<=	seg_select + 1;
		end
	end
end

always	@	(posedge	flash_clk)	begin
	if(!reset)	begin
		flash_cnt		<=	3'h0;
	end	else	begin
		if(flash_cnt == 3'h7)	begin
			flash_cnt	<=	3'h0;
		end	else	begin
			flash_cnt	<=	flash_cnt + 1;
		end
	end
end

always	@	(posedge	scan_clk)	begin
	if(!reset)	begin
		seg_out						<=	8'h0;
	end	else	begin
		case(seg_mode)
			`constant:begin
				case(seg_select)
					3'h0:	seg_out	<=	data_in[7:0];
					3'h1:	seg_out	<=	data_in[15:8];
					3'h2:	seg_out	<=	data_in[23:16];
					3'h3:	seg_out	<=	data_in[31:24];
					3'h4:	seg_out	<=	data_in[39:32];
					default:seg_out	<=	8'hFF;
				endcase
			end
			`flash:begin
				if(flash_cnt[0] == 1'b1)	begin		
					case(seg_select)
						3'h0:	seg_out	<=	8'hFF;
						3'h1:	seg_out	<=	8'hFF;
						3'h2:	seg_out	<=	8'hFF;
						3'h3:	seg_out	<=	8'hFF;
						3'h4:	seg_out	<=	8'hFF;
						default:seg_out	<=	8'hFF;
					endcase
				end	else	begin
					case(seg_select)
						3'h0:	seg_out	<=	data_in[7:0];
						3'h1:	seg_out	<=	data_in[15:8];
						3'h2:	seg_out	<=	data_in[23:16];
						3'h3:	seg_out	<=	data_in[31:24];
						3'h4:	seg_out	<=	data_in[39:32];
						default:seg_out	<=	8'hFF;
					endcase
				end
			end
			`single_flash:begin
				case(flash_select)
					3'h0:begin
						case(seg_select)
							3'h0:begin
								if(flash_cnt[0] == 1'b1)	begin
									seg_out	<=	8'hFF;
								end	else	begin
									seg_out	<=	data_in[7:0];
								end
							end
							3'h1:seg_out	<=	data_in[15:8];
							3'h2:seg_out	<=	data_in[23:16];
							3'h3:seg_out	<=	data_in[31:24];
							3'h4:seg_out	<=	data_in[39:32];
							default:seg_out	<=	8'hFF;
						endcase
					end
					3'h1:begin
						case(seg_select)
							3'h0:seg_out	<=	data_in[7:0];
							3'h1:begin
								if(flash_cnt[0] == 1'b1)	begin
									seg_out	<=	8'hFF;
								end	else	begin
									seg_out	<=	data_in[15:8];
								end
							end
							3'h2:seg_out	<=	data_in[23:16];
							3'h3:seg_out	<=	data_in[31:24];
							3'h4:seg_out	<=	data_in[39:32];
							default:seg_out	<=	8'hFF;
						endcase
					end
					3'h2:begin
						case(seg_select)
							3'h0:seg_out	<=	data_in[7:0];
							3'h1:seg_out	<=	data_in[15:8];
							3'h2:begin
								if(flash_cnt[0] == 1'b1)	begin
									seg_out	<=	8'hFF;
								end	else	begin
									seg_out	<=	data_in[23:16];
								end
							end
							3'h3:seg_out	<=	data_in[31:24];
							3'h4:seg_out	<=	data_in[39:32];
							default:seg_out	<=	8'hFF;
						endcase
					end
					3'h3:begin
						case(seg_select)
							3'h0:seg_out	<=	data_in[7:0];
							3'h1:seg_out	<=	data_in[15:8];
							3'h2:seg_out	<=	data_in[23:16];
							3'h3:begin
								if(flash_cnt[0] == 1'b1)	begin
									seg_out	<=	8'hFF;
								end	else	begin
									seg_out	<=	data_in[31:24];
								end
							end
							3'h4:seg_out	<=	data_in[39:32];
							default:seg_out	<=	8'hFF;
						endcase
					end
					3'h4:begin
						case(seg_select)
							3'h0:seg_out	<=	data_in[7:0];
							3'h1:seg_out	<=	data_in[15:8];
							3'h2:seg_out	<=	data_in[23:16];
							3'h3:seg_out	<=	data_in[31:24];
							3'h4:begin
								if(flash_cnt[0] == 1'b1)	begin
									seg_out	<=	8'hFF;
								end	else	begin
									seg_out	<=	data_in[39:32];
								end
							end
							default:seg_out	<=	8'hFF;
						endcase
					end
					default:seg_out		<=	8'hFF;
				endcase
			end
		endcase
	end
end

endmodule 