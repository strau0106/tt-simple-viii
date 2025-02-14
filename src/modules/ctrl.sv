
import controlpack::*;

module ctrl #(parameter DATA_BUS_WIDTH = 8)(
  input logic clock,
  input logic reset,

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
  input alu_flag_t alu_flags
);
  
  typedef enum logic[3:0] {
    ST_FETCH,
    ST_DECODE,
    ST_ALU_OP,
    ST_LDX_OP,
    ST_LDX_WAIT_READ,
    ST_LDX_WAIT_WRITE,
    ST_JMP_WAIT_PARAM_READ,
    ST_INC_PC
  } ctrl_state;

  ctrl_state state, state_q;

  mem_ctrl_op_e mem_ctrl_op_q;
  addr_register_op_e addr_reg_op_q;
  addr_sel_e addr_sel_q;
  alu_op_e alu_op_q;
  registers_op_e reg_op_q;
  register_sel_e reg_sel_in_q;
  register_sel_e reg_sel_1_q;
  register_sel_e reg_sel_2_q;
  mux_sel_e mux_sel_q;
  logic jmp_op_addr_sel_q, jmp_op_addr_sel;

  always_comb begin
    state_q = state;
    mem_ctrl_op_q = MEM_NOP;
    addr_reg_op_q = AR_NOP;
    addr_sel_q = PC;
    alu_op_q = THR;
    reg_op_q = REG_NOP;
    reg_sel_in_q = REG_A;
    reg_sel_1_q = REG_A;
    reg_sel_2_q = REG_A;
    mux_sel_q = MUX_ALU;
    jmp_op_addr_sel_q = 0;

    case (state)
    default: state_q = ST_FETCH;
    ST_FETCH: begin
      mem_ctrl_op_q = MEM_READ;
      addr_sel_q = PC;
      mux_sel_q = MUX_MEM;
      state_q = ST_DECODE;
    end

    ST_INC_PC: begin
      addr_reg_op_q = INC;
      addr_sel_q = PC;
      state_q = ST_FETCH;
    end

    ST_DECODE: begin
      mem_ctrl_op_q = MEM_READ;
      addr_sel_q = PC;
      mux_sel_q = MUX_MEM;

      if (mem_op_done) begin

        case (bus_data_in[7:6])
          NOP: begin
            state_q = ST_INC_PC;
          end

          ALU: begin // alu instr param0: alu_op[2:0], reg_sel_1[1:0], param1: reg_sel_2[1:0], reg_sel_in[1:0]
            alu_op_q = alu_op_e'(bus_data_in[5:3]);
            reg_sel_1_q = register_sel_e'(bus_data_in[2:1]);
      
            addr_reg_op_q = INC;
            addr_sel_q = PC;
            state_q = ST_ALU_OP;
          end
          LDX: begin // ldx instr_l param0: dir, reg_sel_1[1:0]
            if (bus_data_in[5]) begin // mem to reg
              mem_ctrl_op_q = MEM_READ;
              addr_sel_q = MAR;
              mux_sel_q = MUX_MEM;
              state_q = ST_LDX_WAIT_READ;
              reg_sel_in_q = register_sel_e'(bus_data_in[4:3]);
            end else begin // reg to mem
              reg_sel_1_q = register_sel_e'(bus_data_in[4:3]);
              alu_op_q = THR;
              mux_sel_q = MUX_ALU;
              mem_ctrl_op_q = MEM_WRITE;
              addr_sel_q = MAR;
              state_q = ST_LDX_WAIT_WRITE;
            end 
          end
          JMP: begin // jmp instr_l param0: carry, zero, reg_sel_1[1:0], addr_sel (stored in jmp_op_addr_sel, because param1 has to be read first, which would overwrite it again), param1: addr_reg_op[2:0]
            if (alu_flags.alu_carry != bus_data_in[5] && alu_flags.alu_zero != bus_data_in[4]) state_q = ST_INC_PC;
            else begin 
              reg_sel_1_q = register_sel_e'(bus_data_in[3:2]);
              jmp_op_addr_sel_q =  bus_data_in[1];
              addr_reg_op_q = INC;
              addr_sel_q = PC;
              state_q = ST_JMP_WAIT_PARAM_READ;

            end
          end

        endcase
      end
    end

    ST_ALU_OP: begin
      mem_ctrl_op_q = MEM_READ;
      addr_sel_q = PC;
      mux_sel_q = MUX_MEM;
      alu_op_q = alu_op_e'(alu_op); // preserve alu_op from decode
      reg_sel_1_q = register_sel_e'(reg_sel_1); // preserve reg_sel_1 from decode
      if (mem_op_done) begin
        // bus_data_in is param1
        reg_sel_2_q = register_sel_e'(bus_data_in[7:6]);
        reg_sel_in_q = register_sel_e'(bus_data_in[5:4]);

        mem_ctrl_op_q = MEM_NOP;
        mux_sel_q = MUX_ALU;
        reg_op_q = REG_WRITE;
        state_q = ST_INC_PC;
      end
    end
    ST_LDX_WAIT_READ: begin
      mem_ctrl_op_q = MEM_READ;
      addr_sel_q = MAR;
      mux_sel_q = MUX_MEM;
      if (mem_op_done) begin
        reg_op_q = REG_WRITE;
        state_q = ST_INC_PC;
      end
    end
    ST_LDX_WAIT_WRITE: begin
      reg_sel_1_q = register_sel_e'(reg_sel_1);
      alu_op_q = THR;
      mux_sel_q = MUX_ALU;
      mem_ctrl_op_q = MEM_WRITE;
      addr_sel_q = MAR;
      if (mem_op_done) begin
        state_q = ST_INC_PC;
      end
    end
    ST_JMP_WAIT_PARAM_READ: begin
      mem_ctrl_op_q = MEM_READ;
      addr_sel_q = PC;
      mux_sel_q = MUX_MEM;
      jmp_op_addr_sel_q = jmp_op_addr_sel;
      if (mem_op_done) begin
        // bus_data_in is param1
        addr_sel_q = addr_sel_e'(jmp_op_addr_sel);
        addr_reg_op_q = addr_register_op_e'(bus_data_in[7:5]);
        state_q = ST_INC_PC;
      end
      
    end


    
  endcase

  end

  always @(posedge clock or negedge reset) begin
    if (!reset) begin
      state <= ST_FETCH;
      mem_ctrl_op <= MEM_NOP;
      addr_reg_op <= AR_NOP;
      addr_sel <= PC;
      alu_op <= THR;
      reg_op <= REG_NOP;
      reg_sel_in <= REG_A;
      reg_sel_1 <= REG_A;
      reg_sel_2 <= REG_A;
      mux_sel <= MUX_ALU;
      jmp_op_addr_sel <= 0;

    end else begin
      state <= state_q;
      mem_ctrl_op <= mem_ctrl_op_q;
      addr_reg_op <= addr_reg_op_q;
      addr_sel <= addr_sel_q;
      alu_op <= alu_op_q;
      reg_op <= reg_op_q;
      reg_sel_in <= reg_sel_in_q;
      reg_sel_1 <= reg_sel_1_q;
      reg_sel_2 <= reg_sel_2_q;
      mux_sel <= mux_sel_q;
      jmp_op_addr_sel <= jmp_op_addr_sel_q;
    end
  end


endmodule