module cpu #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
  // SPI interface
  input [3:0] spi_data_in, 
  output [3:0] spi_data_out,
  output [3:0] spi_data_oe,
  output spi_clk_out,
  
  output spi_flash_select,
  output spi_ram_a_select,

  output [7:0] bus_data
);

logic [7:0] alu_out;
logic [7:0] mem_out;

/* verilator lint_off PINCONNECTEMPTY */
// MUX
mux_sel_e mux_sel;
mux mux_instance (
  .sel(mux_sel),
  .alu_in(alu_out),
  .mem_in(mem_out),
  .i_o_in(),
  .out(bus_data)
);

// Registers
registers_op_e reg_op;
register_sel_e reg_in_sel;
register_sel_e reg_1_out_sel;
register_sel_e reg_2_out_sel;

logic [7:0] reg_1;
logic [7:0] reg_2;

registers #(DATA_BUS_WIDTH) registers_instance (
  .clock(clock),
  .reset(reset),
  .op(reg_op),
  .reg_in_sel(reg_in_sel),
  .reg_1_out_sel(reg_1_out_sel),
  .reg_2_out_sel(reg_2_out_sel),
  .reg_data_in(bus_data),
  .reg_1_out(reg_1),
  .reg_2_out(reg_2)
);

// ALU
alu_op_e alu_op;
logic flag_carry;
logic flag_zero;

alu #(DATA_BUS_WIDTH) alu_instance (
  .op(alu_op),
  .register1(reg_1),
  .register2(reg_2),
  .is_carry(flag_carry),
  .is_zero(flag_zero),
  .result(alu_out)
);

// Memory
mem_ctrl_op_e mem_ctrl_op;
addr_register_op_e addr_reg_op;
addr_sel_e addr_sel;

logic op_done;

mem #(DATA_BUS_WIDTH, ADDRESS_WIDTH) mem_instance (
  .clock(clock),
  .reset(reset),
  .op(mem_ctrl_op),
  .addr_reg_op(addr_reg_op),
  .addr_sel(addr_sel),
  .bus_data_in(bus_data),
  .op_done_out(op_done),
  .bus_data_out(mem_out),
  .spi_data_in(spi_data_in),
  .spi_data_out(spi_data_out),
  .spi_data_oe(spi_data_oe),
  .spi_clk_out(spi_clk_out),
  .spi_flash_select(spi_flash_select),
  .spi_ram_a_select(spi_ram_a_select),
  .spi_ram_b_select()
);

// Control
ctrl ctrl_instance (
  .clock(clock),
  .reset(reset),
  .mem_ctrl_op(mem_ctrl_op),
  .addr_reg_op(addr_reg_op),
  .addr_sel(addr_sel),
  .alu_op(alu_op),
  .reg_op(reg_op),
  .reg_sel_in(reg_in_sel),
  .reg_sel_1(reg_1_out_sel),
  .reg_sel_2(reg_2_out_sel),
  .mux_sel(mux_sel),
  .bus_data_in(bus_data),
  .mem_op_done(op_done),
  .flag_zero_in(flag_zero),
  .flag_carry_in(flag_carry)
);



/* verilator lint_on PINCONNECTEMPTY */

endmodule
