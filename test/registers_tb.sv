`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module registers_tb #(parameter DATA_BUS_WIDTH = 8) (
  input logic clock, 
  input logic reset,

  input registers_op_e op,
  input register_sel_e reg_in_sel,
  input register_sel_e reg_1_out_sel,
  input register_sel_e reg_2_out_sel,

  input logic use_register_bank_in,
  input logic use_register_bank_out_1,


  input logic[DATA_BUS_WIDTH-1:0] reg_data_in,
  
  output logic[DATA_BUS_WIDTH-1:0] reg_1_out,
  output logic[DATA_BUS_WIDTH-1:0] reg_2_out
);
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("registers.vcd");
    $dumpvars(0, registers_instance);
    #1;
  end

  registers #(DATA_BUS_WIDTH) registers_instance (
    .clock(clock),
    .reset(reset),

    .op(op),

    .reg_in_sel(reg_in_sel),
    .reg_1_out_sel(reg_1_out_sel),
    .reg_2_out_sel(reg_2_out_sel),
    .use_register_bank_in(use_register_bank_in),
    .use_register_bank_out_1(use_register_bank_out_1),

    .reg_data_in(reg_data_in),
    
    .reg_1_out(reg_1_out),
    .reg_2_out(reg_2_out)

 );

endmodule
