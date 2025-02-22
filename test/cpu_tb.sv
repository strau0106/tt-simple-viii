`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/

module cpu_tb #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
  output [7:0] bus_data
  );
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, cpu_instance);
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
    .qspi_ram_b_select(),

    .debug_clk(),
    .debug_addr(),
    .debug_data()

  );

  defparam sim_qspi_instance.INIT_FILE = `PROG_FILE;

  cpu #(DATA_BUS_WIDTH, ADDRESS_WIDTH) cpu_instance (
    .clock(clock),
    .reset(reset),

    .spi_data_in(spi_data_out),
    .spi_data_out(spi_data_in),
    .spi_data_oe(),

    .spi_clk_out(spi_clk_out),
    .spi_flash_select(qspi_flash_select),
    .spi_ram_a_select(qspi_ram_a_select),
    
    .bus_data(bus_data)
  );

endmodule
