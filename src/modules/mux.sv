module mux (
  input mux_sel_e sel,
  input [7:0] alu_in,
  input [7:0] mem_in,
  input [7:0] i_o_in,
  output logic [7:0] out
);

  always_comb begin
    case (sel)
      MUX_ALU: out = alu_in;
      MUX_MEM: out = mem_in;
      MUX_IO: out = i_o_in;
      default: out = 8'b0;
    endcase
  end

endmodule
