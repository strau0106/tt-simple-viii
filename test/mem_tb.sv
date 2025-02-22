`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module mem_tb #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
  // CPU Interface
  input mem_ctrl_op_e op,
  input addr_register_op_e addr_reg_op,
  input addr_sel_e addr_sel,
  
  input logic[DATA_BUS_WIDTH-1:0] bus_data_in,
  output logic op_done_out,
  output logic[DATA_BUS_WIDTH-1:0] bus_data_out
  );
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("mem.vcd");
    $dumpvars(0, mem_instance);
    #1;
  end


  logic [3:0] spi_data_in, spi_data_out;
  logic spi_clk_out;

  logic qspi_flash_select, qspi_ram_a_select, qspi_ram_b_select;


  sim_qspi sim_qspi_instance (
    .qspi_data_in(spi_data_in),
    .qspi_data_out(spi_data_out),
    .qspi_clk(spi_clk_out),
    .qspi_flash_select(qspi_flash_select),
    .qspi_ram_a_select(qspi_ram_a_select),
    .qspi_ram_b_select(qspi_ram_b_select),

    .debug_clk(),
    .debug_addr(),
    .debug_data()

  );

  defparam sim_qspi_instance.INIT_FILE = `PROG_FILE;

  mem #(DATA_BUS_WIDTH, ADDRESS_WIDTH) mem_instance (
    .clock(clock),
    .reset(reset),

    .op(op),
    .addr_reg_op(addr_reg_op),
    .addr_sel(addr_sel),

    .bus_data_in(bus_data_in),
    .op_done_out(op_done_out),
    .bus_data_out(bus_data_out),

    .spi_data_in(spi_data_out),
    .spi_data_out(spi_data_in),
    .spi_data_oe(),

    .spi_clk_out(spi_clk_out),
    .spi_flash_select(qspi_flash_select),
    .spi_ram_a_select(qspi_ram_a_select),
    .spi_ram_b_select(qspi_ram_b_select)
    
  );

endmodule
