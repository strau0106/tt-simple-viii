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
  
  logic[DATA_BUS_WIDTH-1:0] registers[4];
  logic[DATA_BUS_WIDTH-1:0] registers_d[4]; 

  assign reg_1_out = registers[reg_1_out_sel];
  assign reg_2_out = registers[reg_2_out_sel];


 always_comb begin
    registers_d[0] = registers[0];
    registers_d[1] = registers[1];
    registers_d[2] = registers[2];
    registers_d[3] = registers[3];
    
      if (op == REG_WRITE)
        registers_d[reg_in_sel] = reg_data_in;
  end

  always_ff @(posedge clock) begin
    if (!reset) begin
      registers[0] <= 0;
      registers[1] <= 0;
      registers[2] <= 0;
      registers[3] <= 0;

    end else begin
      // iverilog...
      registers[0] <= registers_d[0];
      registers[1] <= registers_d[1];
      registers[2] <= registers_d[2];
      registers[3] <= registers_d[3];
    
    end
  end

endmodule
