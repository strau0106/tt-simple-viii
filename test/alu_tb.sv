`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module alu_tb #(parameter DATA_BUS_WIDTH = 8) (
    input alu_op_e op,
    input logic[DATA_BUS_WIDTH-1:0] register1,
    input logic[DATA_BUS_WIDTH-1:0] register2,
    output logic[DATA_BUS_WIDTH-1:0] result,
    output logic is_carry,
    output logic is_zero
  );
  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, alu_instance);
    #1;
  end

  alu #(DATA_BUS_WIDTH) alu_instance (
    .op(op),
    .register1(register1),
    .register2(register2),
    .result(result),
    .is_carry(is_carry),
    .is_zero(is_zero)

 );

endmodule
