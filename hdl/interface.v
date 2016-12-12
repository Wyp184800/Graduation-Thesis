`include	"defines.v"

module	interface(
	input		wire			clk,			//slow clk, 20M
	input		wire			scan_clk,	//1MHZ
	input		wire			reset,
	
	input		wire			key_mode,
	input		wire			key_plus,
	input		wire			key_minus,
	input		wire			key_shift,
	input		wire			key_set,
	
	input		wire[2:0]	flash_cnt,
	
	input		wire			hold_flag,
	
	output	reg[3:0]		seg_select,
	output	reg[2:0]		seg_mode,
	output	reg[7:0]		seg_out
);

reg[39:0]			monitors[0:25];
reg[]					monitor_value[0:25];

reg[10:0]	mode_addr;		//format:P(mode[10:8]) - mode_addr[7:0]	eg: mode_addr = 11'h701 => P7-01
reg[9:0]		alm;

/*reg			key_minus_set;
reg			key_mode_set;
reg			key_plus_set;
reg			key_set_set;
reg			key_shift_set;*/

reg[2:0]		keys_set;		//3'h0:set;3'h1:shift3'h2:mode;3'h3:plus;3'h4:minus;3'h5:plus_hold;3'h6:minus_hold.
reg[12:0]	hold_cnt;

reg[39:0]	data_out;

reg[7:0]		state;

/*decode function*/
function	unsigned[7:0]	decode;

input		wire[3:0]	data_i;
			reg[7:0]		data_o;

begin
	if(data_i[3] == 1'b1)	begin
		data_o[7]	=	1'b1;	
	end	else	begin
		data_o[7]	=	1'b0;
	end
	case(data_i)
		4'h0:data_o[6:0]	=	7'b0111111;
		4'h1:data_o[6:0]	=	7'b0000110;
		4'h2:data_o[6:0]	=	7'b1011011; 
		4'h3:data_o[6:0]	=	7'b1001111;
		4'h4:data_o[6:0]	=	7'b1100110;
		4'h5:data_o[6:0]	=	7'b1101101;
		4'h6:data_o[6:0]	=	7'b1111101;
		4'h7:data_o[6:0]	=	7'b0000111;
		4'h8:data_o[6:0]	=	7'b1111111;
		4'h9:data_o[6:0]	=	7'b1101111;
		4'ha:data_o[6:0]	=	7'b1110111;
		4'hb:data_o[6:0]	=	7'b1111100;
		4'hc:data_o[6:0]	=	7'b0111001;
		4'hd:data_o[6:0]	=	7'b1011110;
		4'he:data_o[6:0]	=	7'b1111001;
		4'hf:data_o[6:0]	=	7'b1110001;
		default:data_o[6:0]	=	7'h00;
	endcase
	decode	=	data_o;
end

endfunction

//create 8 tables to save register mode, 3 bits for each
reg[191:0]	rm_table0=192'h80000092001da18024924804924920024920000000000918;
reg[153:0]	rm_table1;
reg[133:0]	rm_table2;
reg[23:0]	rm_table3;
reg[49:0]	rm_table4;
reg[199:0]	rm_table5;
reg[199:0]	rm_table6;
reg[55:0]	rm_table7;

always	@	(posedge clk)	begin		//data to be displayed
	if(!reset)	begin
		data_out				<=	32'h0;
		seg_mode				<=	`constant;
	end	else	begin
		case(state)	
			`startup:begin			//startup, flash for 5times  'CANoP'
				data_out		<=	`CANoP;
				seg_mode		<=	`flash;
			end
			`mode:begin
				data_out		<=	{8'h73,1'b0,decode(mode_addr[10:8]),8'h40,decode(mode_addr[7:4]),decode(mode_addr[3:0])};
				seg_mode		<=	`constant;
			end
			`set:begin
				data_out		<=	`SAvEd;
				seg_mode		<=	`constant;
			end
			`alarm:begin
				data_out		<=	{/*A,L*/2'b00,decode(alm[9:8]),decode(alm[7:4]),decode(alm[3:0])};
			end
			`r_only:begin
				data_out		<=	`r_onLy;
				seg_mode		<=	`constant;
			end
			`main:begin
				data_out		<=	monitor_value[monitor_add];
				seg_mode		<=	`constant;
			end
			`monitor:begin
				data_out		<=	monitors[monitor_add];
				seg_mode		<=	`constant;
			end
			default:begin
				data_out		<=	32'hFFFFFFFF;
				seg_mode		<=	`constant;
			end
		endcase
	end
end

always	@	(posedge	clk)	begin		//state control
	if(!reset)	begin
		state						<=	`main;
	end	else	begin
		case(state)
			`startup:begin
				if(flash_cnt == 3'd4)	begin
					state			<=	`main;
				end
			end
			`mode:begin
			
			end
			`set:begin
			
			end
			`main:begin
				case(keys_set)
					3'h0:	state	<=				//key_set
					3'h1:	state	<=				//key_shift
					3'h2:	state	<=	`mode;			//key_mode
					3'h3:begin					//key_plus
						state			<=	`monitor;	
						if(monitor_add == 5'h1A)	begin
							monitor_add	<=	5'h0;
						end	else	begin
							monitor_add	<=	monitor_add + 1;
						end
					end
					3'h4:begin						//key_minus
						state			<=	`monitor;
						if(monitor_add == 5'h0)	begin
							monitor_add	<=	5'h1A;
						end	else	begin
							monitor_add	<=	monitor_add - 1;
						end
					end
					//3'h5:						//key_plus_hold			//useless in mode main
					//3'h6:						//key_minus_hold			//useless in mode main
					default:begin
						state		<=	`main;
						monitor_add	<=	5'h0;
					end
				endcase
			end
			`alarm:begin
			
			end
			`r_only:begin
			
			end
			`monitor:begin
				
			end
			default:state		<=	`main;
		endcase
	end
end

always	@	(posedge	clk)	begin		//key_hold		10ms
	if(hold_cnt == 13'h2710)	begin
		hold_cnt		<=	13'h0;
		hold_flag	<=	1'b1;
	end	else	
	if(key_minus || key_plus)	begin
		hold_cnt		<=	hold_cnt	+ 1;
		hold_flag	<=	1'b0;
	end	else	begin
		hold_cnt		<=	13'h0;
		hold_flag	<=	1'b0;
	end
end


always	@	(posedge	scan_clk)	begin		//key scan, use scan_clk
	if(key_mode)	begin
		if(key_mode)	begin
			keys_set	<=	3'h3;
		end	else	begin
			keys_set	<=	3'h0;
		end
	end	else
	if(key_shift)	begin
		if(key_shift)	begin
			keys_set	<=	3'h2;
		end	else	begin
			keys_set	<=	3'h0;
		end
	end	else	
	if(key_plus)	begin
		if(key_plus)	begin
			if(hold_flag)	begin
				keys
			end	else	begin
			keys_set	<=	3'h4;
		end	else	begin
			keys_set	<=	3'h0;
		end
	end	else	
	if(key_minus)	begin
		if(key_minus)	begin
			keys_set	<=	3'h5;
		end	else	begin
			keys_set <=	3'h0;
		end
	end	else	
	if(key_set)	begin
		if(key_set)	begin
			keys_set	<=	3'h1;
		end	else	begin
			keys_set	<=	3'h0;
		end
	end	else	begin
		keys_set		<=	3'h0;
	end
end

endmodule 