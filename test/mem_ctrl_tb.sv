`default_nettype none
`timescale 1ns / 1ps
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/

module mem_ctrl_tb #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
  // CPU Interface
  input addr_register_op_e addr_reg_op,
  input addr_sel_e addr_sel,
  
  input logic[DATA_BUS_WIDTH-1:0] bus_data_in,
  output logic[24:0] addr_out
);

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("mem_ctrl.vcd");
    $dumpvars(0, mem_ctrl_instance);
    #1;
  end

  mem_ctrl #(DATA_BUS_WIDTH, ADDRESS_WIDTH) mem_ctrl_instance (
    .clock(clock),
    .reset(reset),

    .addr_reg_op(addr_reg_op),
    .addr_sel(addr_sel),

    .bus_data_in(bus_data_in),
    .addr_out(addr_out),

    // UNUSED NETS
    .op(),
    .bus_data_out(),
    .op_done_out(),
    
    .data_out(),
    .start_read(),
    .start_write(),
    .stall_txn(),
    .stop_txn(),
    .data_in(),
    .data_req(),
    .data_ready()
   );

endmodule
