// icarus does not properly support
// 1800-2012 IEEE :(
// TODO: Retest for loops for array assignments/other solution
module registers #(parameter DATA_BUS_WIDTH = 8) (
  input logic clock, 
  input logic reset,

  input registers_op_e op,
  input register_sel_e reg_in_sel,
  input register_sel_e reg_1_out_sel,
  input register_sel_e reg_2_out_sel,

  input logic[DATA_BUS_WIDTH-1:0] reg_data_in,
  
  output logic[DATA_BUS_WIDTH-1:0] reg_1_out,
  output logic[DATA_BUS_WIDTH-1:0] reg_2_out
);
  
  logic[DATA_BUS_WIDTH-1:0] registers_q[4]; // Intermediate state of the registers
  logic[DATA_BUS_WIDTH-1:0] registers_d[4]; 

  assign reg_1_out = registers_d[reg_1_out_sel];
  assign reg_2_out = registers_d[reg_2_out_sel];


 always_comb begin
    registers_q[0] = registers_d[0];
    registers_q[1] = registers_d[1];
    registers_q[2] = registers_d[2];
    registers_q[3] = registers_d[3];
    
      if (op == REG_WRITE)
        registers_q[reg_in_sel] = reg_data_in;
  end

  always_ff @(posedge clock or negedge reset) begin
    if (!reset) begin
      registers_d[0] <= 0;
      registers_d[1] <= 0;
      registers_d[2] <= 0;
      registers_d[3] <= 0;

    end else begin
      // iverilog...
      registers_d[0] <= registers_q[0];
      registers_d[1] <= registers_q[1];
      registers_d[2] <= registers_q[2];
      registers_d[3] <= registers_q[3];
    
    end
  end

endmodule
