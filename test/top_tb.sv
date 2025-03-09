`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/

module top_tb #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
  `ifdef SCAN
  input logic test, 
  input logic scan_in, 
  output logic scan_out,
  `endif

  output [7:0] reg_d
  );
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile(`DUMPFILE);
    $dumpvars(0, cpu_instance);
    //#1;
  end

  logic [3:0] spi_data_in, spi_data_out;
  logic spi_clk_out;

  logic spi_flash_select, spi_ram_a_select, spi_ram_b_select;

  logic [7:0] uio_out;
  logic [7:0] uio_in;
  logic [7:0] ui_in;

  defparam sim_qspi_instance.INIT_FILE = `PROG_FILE;

  sim_qspi sim_qspi_instance (
    .qspi_data_in(spi_data_in),
    .qspi_data_out(spi_data_out),
    .qspi_clk(spi_clk_out),
    .qspi_flash_select(spi_flash_select),
    .qspi_ram_a_select(spi_ram_a_select),
    .qspi_ram_b_select(1'b1),

    .debug_clk(),
    .debug_addr(),  
    .debug_data()

  );

  logic [24:0] addr = {24'b0, 1'b1};

  assign {scan_out, spi_ram_a_select, spi_data_in[3:2], 
                    spi_clk_out, spi_data_in[1:0], spi_flash_select} = uio_out; 

  assign uio_in = {2'b00, spi_data_out[3:2], 1'b0, spi_data_out[1:0], 1'b0};

  `ifdef SCAN  
  assign ui_in = {test, scan_in, 6'b000000};
  `endif
  
  //spi_data_out = {uio_in[5:4], uio_in[2:1]};
  
  `ifdef USE_POWER_PINS
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
  `endif


  tt_um_strau0106_simple_viii #(DATA_BUS_WIDTH, ADDRESS_WIDTH) cpu_instance (
        // powerpins for gate level simulation
    `ifdef USE_POWER_PINS
      .VPWR(VPWR),
      .VGND(VGND),
    `endif
    
    .ui_in(ui_in),
    .uo_out(reg_d),
    .uio_out(uio_out),
    .uio_in(uio_in),
    .uio_oe(),
    .clk(clock),
    .rst_n(reset),
    .ena()

  );

endmodule
