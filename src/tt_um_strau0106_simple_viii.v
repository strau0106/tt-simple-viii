/*
 * Copyright (c) 2025 strau0106
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_strau0106_simple_viii #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);


  wire [3:0] spi_data_in = {uio_in[5:4], uio_in[2:1]};
  wire [3:0] spi_data_out;
  wire [3:0] spi_data_oe;
  wire       spi_clk_out;
  wire       spi_flash_select;
  wire       spi_ram_a_select;

  `ifdef SCAN
  wire test = ui_in[7];
  wire scan_in = ui_in[6];
  wire scan_out;
  wire scan_out_tmp = scan_out;
  `endif

  `ifndef SCAN
  wire scan_out_tmp = 1'b0;
  `endif

  assign uio_out = {scan_out_tmp, spi_ram_a_select, spi_data_out[3:2], 
                    spi_clk_out, spi_data_out[1:0], spi_flash_select};
  assign uio_oe = rst_n ? {2'b11, spi_data_oe[3:2], 1'b1, spi_data_oe[1:0], 1'b1} : 8'h00;


  cpu #(DATA_BUS_WIDTH, ADDRESS_WIDTH) cpu_instance (
    .clock(clk),
    .reset(rst_n),

    `ifdef SCAN
    .test(test),
    .scan_in(scan_in),
    .scan_out(scan_out),
    `endif

    .spi_data_in(spi_data_in),

    .spi_data_out(spi_data_out),
    .spi_data_oe(spi_data_oe),
    .spi_clk_out(spi_clk_out),

    .spi_flash_select(spi_flash_select),
    .spi_ram_a_select(spi_ram_a_select),
    
    .reg_d(uo_out),
    .data_in(ui_in[5:0])
  );

endmodule
