module	eeprom_controller(
	input		wire			clk,
	input		wire			reset,
	
	input		wire[10:0]	addr_write,
	input		wire[31:0]	data_write,

	input		wire[10:0]	addr_read,
	output	reg[31:0]	data_read
);

endmodule 