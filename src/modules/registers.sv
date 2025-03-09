// icarus does not properly support
// 1800-2012 IEEE :(
// TODO: Retest for loops for array assignments/other solution
module registers #(parameter DATA_BUS_WIDTH = 8, parameter REGISTERS_IN_BANK_WITH_SCAN_CHAIN = 8, parameter ADDITIONAL_REGISTERS_IN_BANK = 8) (
  input logic clock, 
  input logic reset,

  `ifdef SCAN
  input logic test,
  input logic scan_in,
  output logic scan_out,
  `endif

  input registers_op_e op,
  input register_sel_e reg_in_sel,
  input register_sel_e reg_1_out_sel,
  input register_sel_e reg_2_out_sel,

  input logic use_register_bank_in,
  input logic use_register_bank_out_1,

  input logic[DATA_BUS_WIDTH-1:0] reg_data_in,
  
  output logic[DATA_BUS_WIDTH-1:0] reg_1_out,
  output logic[DATA_BUS_WIDTH-1:0] reg_2_out,

  output logic[DATA_BUS_WIDTH-1:0] reg_d_out,

  output logic[DATA_BUS_WIDTH*8-1:0] register_bank_out
);
  
  logic[DATA_BUS_WIDTH-1:0] registers[4];
  logic[DATA_BUS_WIDTH-1:0] registers_d[4]; 
  logic[DATA_BUS_WIDTH-1:0] registers_dt[4];

  localparam TOTAL_REGISTERS_IN_BANK = REGISTERS_IN_BANK_WITH_SCAN_CHAIN + ADDITIONAL_REGISTERS_IN_BANK;
  localparam BANK_INDEX_WIDTH = $clog2(TOTAL_REGISTERS_IN_BANK);

  logic[DATA_BUS_WIDTH-1:0] register_bank[TOTAL_REGISTERS_IN_BANK];
  logic[DATA_BUS_WIDTH-1:0] register_bank_d[TOTAL_REGISTERS_IN_BANK];
  logic[DATA_BUS_WIDTH-1:0] register_bank_dt[REGISTERS_IN_BANK_WITH_SCAN_CHAIN];



  assign reg_1_out = use_register_bank_out_1 ? register_bank[registers[reg_1_out_sel][BANK_INDEX_WIDTH-1:0]] : registers[reg_1_out_sel];
  assign reg_2_out = registers[reg_2_out_sel];

  assign reg_d_out = registers[3];

  always_comb begin
    for (int i = 0; i < 8; i = i+1) begin
    register_bank_out[i*8 +: 8] = register_bank[i];
    end
  end


 always_comb begin
    for (int i = 0; i < 4; i=i+1) begin
      registers_d[i] = registers[i];
    end

    for (int i = 0; i < TOTAL_REGISTERS_IN_BANK; i=i+1) begin
      register_bank_d[i] = register_bank[i];
    end
    
    if (op == REG_WRITE) begin
      if (use_register_bank_in)
        register_bank_d[registers[reg_in_sel][BANK_INDEX_WIDTH-1:0]] = reg_data_in;
      else 
        registers_d[reg_in_sel] = reg_data_in;
    end

  end

  `ifndef SCAN
    wire test = 1'b0;
    wire scan_in = 1'b0;
  `endif

  always_comb begin
    registers_dt[0] = test ? {scan_in, registers[0][DATA_BUS_WIDTH-1:1]} : registers_d[0];
    for (int i = 1; i < 4; i++) begin
      registers_dt[i] = test ? {registers[i-1][0], registers[i][DATA_BUS_WIDTH-1:1]} : registers_d[i];
    end
    register_bank_dt[0] = test ? {registers[3][0], register_bank[0][DATA_BUS_WIDTH-1:1]} : register_bank_d[0];
    for (int i = 1; i < REGISTERS_IN_BANK_WITH_SCAN_CHAIN; i++) begin
      register_bank_dt[i] = test ? {register_bank[i-1][0], register_bank[i][DATA_BUS_WIDTH-1:1]} : register_bank_d[i];
    end
    end

  `ifdef SCAN
  assign scan_out = test ? register_bank[REGISTERS_IN_BANK_WITH_SCAN_CHAIN-1][0] : 1'b0;
  `endif

  always_ff @(posedge clock) begin
    if (!reset) begin
      for (int i = 0; i < 4; i++) begin
        registers[i] <= 0;
      end

      for (int i = 0; i < TOTAL_REGISTERS_IN_BANK; i++) begin
        register_bank[i] <= 0;
      end

    end else begin
      // iverilog...
      for (int i = 0; i < 4; i++) begin
      registers[i] <= registers_dt[i];
      end

      for (int i = 0; i < TOTAL_REGISTERS_IN_BANK; i++) begin
      register_bank[i] <= (i < REGISTERS_IN_BANK_WITH_SCAN_CHAIN) ? register_bank_dt[i] : register_bank_d[i];
      end
    end
  end

endmodule
