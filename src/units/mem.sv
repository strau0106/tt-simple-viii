module mem #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
  // CPU Interface
  input mem_ctrl_op_e op,
  input addr_register_op_e addr_reg_op,
  input addr_sel_e addr_sel,
  
  input logic[DATA_BUS_WIDTH-1:0] bus_data_in,
  output logic op_done_out,
  output logic[DATA_BUS_WIDTH-1:0] bus_data_out,

  // SPI interface
  input [3:0] spi_data_in, 
  output reg [3:0] spi_data_out,
  output reg [3:0] spi_data_oe,
  output reg spi_clk_out,

  output reg spi_flash_select,
  output reg spi_ram_a_select,
  output reg spi_ram_b_select
);

logic [24:0] addr;
logic [7:0] data_qi_mo;
logic start_read;
logic start_write;
logic stall_txn;
logic stop_txn;

logic [7:0] data_qo_mi;
logic data_req;
logic data_ready;




qspi_ctrl  qspi_ctrl_instance(
    .clk(clock),
    .rstn(reset),
    .spi_data_in(spi_data_in),
    .spi_data_out(spi_data_out),
    .spi_data_oe(spi_data_oe),
    .spi_clk_out(spi_clk_out),
    .spi_flash_select(spi_flash_select),
    .spi_ram_a_select(spi_ram_a_select),
    .spi_ram_b_select(spi_ram_b_select),
    .addr_in(addr),
    .data_in(data_qi_mo),
    .start_read(start_read),
    .start_write(start_write),
    .stall_txn(stall_txn),
    .stop_txn(stop_txn),
    .data_out(data_qo_mi),
    .data_req(data_req),
    .data_ready(data_ready),
    /* verilator lint_off PINCONNECTEMPTY */
    .busy()
    /* verilator lint_on PINCONNECTEMPTY */
);


mem_ctrl #(DATA_BUS_WIDTH, ADDRESS_WIDTH) mem_ctrl_instance (
  .clock(clock),
  .reset(reset),

  .op(op),
  .addr_reg_op(addr_reg_op),
  .addr_sel(addr_sel),

  .bus_data_in(bus_data_in),
  .op_done_out(op_done_out),
  .bus_data_out(bus_data_out),
  
  .addr_out(addr),
  .data_out(data_qi_mo),
  .start_read(start_read),
  .start_write(start_write),
  .stall_txn(stall_txn),
  .stop_txn(stop_txn),
  .data_in(data_qo_mi),
  .data_req(data_req),
  .data_ready(data_ready)

);


endmodule
