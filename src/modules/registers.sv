import controlpack::*;

module registers #(DATA_BUS_WIDTH) (
  input logic clock, 
  input logic reset,

  input registers_op_e op,
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


  always @(registers_d or reg_data_in or op) begin
    registers_q = registers_d;
    
      if (op == INWRITE)
        registers_q[reg_1_out_sel] = reg_data_in;
  end

  always @(negedge clock or negedge reset) begin
    if (reset) begin
      registers_d <= '{default: '0};
    end else begin
      registers_d <= registers_q;
    end
  end

endmodule
