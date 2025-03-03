`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module ctrl_tb #(parameter DATA_BUS_WIDTH = 8) (
  input clock,
  input reset,

  output mem_ctrl_op_e mem_ctrl_op, 
  output addr_register_op_e addr_reg_op,
  output addr_sel_e addr_sel,
  output alu_op_e alu_op,
  output registers_op_e reg_op,
  output register_sel_e reg_sel_in,
  output register_sel_e reg_sel_1,
  output register_sel_e reg_sel_2,
  output mux_sel_e mux_sel,

  input logic[DATA_BUS_WIDTH-1:0] bus_data_in,
  input logic mem_op_done,
  input flag_zero,
  input flag_carry
  );
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("ctrl.vcd");
    $dumpvars(0, ctrl_instance);
    #1;
  end

  ctrl #(DATA_BUS_WIDTH) ctrl_instance(
    .clock(clock),
    .reset(reset),

    .mem_ctrl_op(mem_ctrl_op),
    .addr_reg_op(addr_reg_op),
    .addr_sel(addr_sel),
    .alu_op(alu_op),
    .reg_op(reg_op),
    .reg_sel_in(reg_sel_in),
    .reg_sel_1(reg_sel_1),
    .reg_sel_2(reg_sel_2),
    .mux_sel(mux_sel),

    .bus_data_in(bus_data_in),
    .mem_op_done(mem_op_done),
    .flag_zero_in(flag_zero),
    .flag_carry_in(flag_carry)

);

endmodule
