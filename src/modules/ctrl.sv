/* verilator lint_off ENUMVALUE */

module ctrl #(parameter DATA_BUS_WIDTH = 8)(
  input logic clock,
  input logic reset,

  `ifdef SCAN
  input logic test,
  input logic scan_in,
  output logic scan_out,
  `endif
  
  output mem_ctrl_op_e mem_ctrl_op, 
  output addr_register_op_e addr_reg_op,
  output addr_sel_e addr_sel,
  output alu_op_e alu_op,
  output registers_op_e reg_op,
  output register_sel_e reg_sel_in,
  output register_sel_e reg_sel_1,
  output register_sel_e reg_sel_2,
  output logic use_register_bank_in,
  output logic use_register_bank_out_1,
  output mux_sel_e mux_sel,

  input logic[DATA_BUS_WIDTH-1:0] bus_data_in,
  input logic mem_op_done,
  input logic flag_carry_in,
  input logic flag_zero_in
  );
  
  typedef enum logic[3:0] {
    ST_FETCH,
    ST_DECODE,
    ST_ALU_OP,
    ST_LDX_OP,
    ST_LDX_WAIT_RAM_READ,
    ST_LDX_WAIT_FLASH_READ,
    ST_LDX_WAIT_WRITE,
    ST_JMP_WAIT_PARAM_READ,
    ST_INC_PC
  } ctrl_state /*verilator public*/;

  ctrl_state state, state_d;
  logic[3:0] state_dt;

  logic[1:0] mem_ctrl_op_d, mem_ctrl_op_dt;
  logic[2:0] addr_reg_op_d, addr_reg_op_dt;
  logic addr_sel_d, addr_sel_dt;
  logic[3:0] alu_op_d, alu_op_dt;
  logic reg_op_d, reg_op_dt;
  logic[1:0] reg_sel_in_d, reg_sel_in_dt;
  logic[1:0] reg_sel_1_d, reg_sel_1_dt;
  logic[1:0] reg_sel_2_d, reg_sel_2_dt;
  logic use_register_bank_in_d, use_register_bank_in_dt;
  logic use_register_bank_out_1_d, use_register_bank_out_1_dt;
  logic[1:0] mux_sel_d, mux_sel_dt;
  logic jmp_op_addr_sel, jmp_op_addr_sel_d, jmp_op_addr_sel_dt;
  logic flag_carry, flag_carry_d, flag_carry_dt;
  logic flag_zero, flag_zero_d, flag_zero_dt;

  always_comb begin
    state_d = state;
    mem_ctrl_op_d = MEM_NOP;
    addr_reg_op_d = AR_NOP;
    addr_sel_d = PC;
    alu_op_d = THR;
    reg_op_d = REG_NOP;
    reg_sel_in_d = REG_A;
    reg_sel_1_d = REG_A;
    reg_sel_2_d = REG_A;
    use_register_bank_in_d = 0;
    use_register_bank_out_1_d = 0;
    mux_sel_d = MUX_ALU;
    jmp_op_addr_sel_d = 0;
    flag_zero_d = flag_zero;
    flag_carry_d = flag_carry;

    case (state)
    default: state_d = ST_FETCH;
    ST_FETCH: begin
      mem_ctrl_op_d = MEM_READ;
      addr_sel_d = PC;
      mux_sel_d = MUX_MEM;
      state_d = ST_DECODE;
    end

    ST_INC_PC: begin
      addr_reg_op_d = INC;
      addr_sel_d = PC;
      state_d = ST_FETCH;
    end

    ST_DECODE: begin
      mem_ctrl_op_d = MEM_READ;
      addr_sel_d = PC;
      mux_sel_d = MUX_MEM;

      if (mem_op_done) begin
        mem_ctrl_op_d = MEM_NOP;
        case (bus_data_in[7:6])
          NOP: begin
            if (bus_data_in[5] == 0) state_d = ST_INC_PC;
            else begin
              reg_sel_in_d = bus_data_in[4:3];
              use_register_bank_in_d = bus_data_in[2];
              mux_sel_d = MUX_IO;
              reg_op_d = REG_WRITE;
              state_d = ST_INC_PC;
            end
          end

          ALU: begin // alu instr param0: alu_op[3:0], reg_sel_1[1:0], param1: reg_sel_2[1:0], reg_sel_in[1:0]
            alu_op_d = bus_data_in[5:2];
            reg_sel_1_d = bus_data_in[1:0];
      
            addr_reg_op_d = INC;
            addr_sel_d = PC;
            state_d = ST_ALU_OP;
          end
          LDX: begin // ldx instr_l param0: ldxop, reg_sel_1[1:0]
            case (bus_data_in[5:4]) // mem to reg
             RAM2REG: begin 
              mem_ctrl_op_d = MEM_NOP;
              addr_sel_d = MAR;
              mux_sel_d = MUX_MEM;
              state_d = ST_LDX_WAIT_RAM_READ;
              reg_sel_in_d = bus_data_in[3:2];
              use_register_bank_in_d = bus_data_in[1];
             end
            REG2RAM: begin // reg to mem
              reg_sel_1_d = bus_data_in[3:2];
              use_register_bank_out_1_d = bus_data_in[1];
              alu_op_d = THR;
              mux_sel_d = MUX_ALU;
              mem_ctrl_op_d = MEM_WRITE;
              addr_sel_d = MAR;
              state_d = ST_LDX_WAIT_WRITE;
            end 
            FLASH2REG: begin // flash to reg
              mem_ctrl_op_d = MEM_NOP;
              addr_sel_d = PC;
              addr_reg_op_d = INC;
              mux_sel_d = MUX_MEM;
              state_d = ST_LDX_WAIT_FLASH_READ;
              reg_sel_in_d = bus_data_in[3:2];
              use_register_bank_in_d = bus_data_in[1];
            end
            default: state_d = ST_INC_PC;
            endcase
          end 
          JMP: begin // jmp instr_l param0: carry, zero, reg_sel_1[1:0], addr_sel (stored in jmp_op_addr_sel, because param1 has to be read first, which would overwrite it again), param1: addr_reg_op[2:0]
            if (flag_carry != bus_data_in[5] && flag_zero != bus_data_in[4]) state_d = ST_INC_PC;
            else begin 
              reg_sel_1_d = bus_data_in[3:2];
              use_register_bank_out_1_d = bus_data_in[0];
              jmp_op_addr_sel_d =  bus_data_in[1];
              addr_reg_op_d = INC;
              addr_sel_d = PC;
              state_d = ST_JMP_WAIT_PARAM_READ;

            end
          end

        endcase
      end
    end

    ST_ALU_OP: begin
      mem_ctrl_op_d = MEM_READ;
      addr_sel_d = PC;
      mux_sel_d = MUX_MEM;
      alu_op_d = alu_op; // preserve alu_op from decode
      reg_sel_1_d = reg_sel_1; // preserve reg_sel_1 from decode
      if (mem_op_done) begin
        // bus_data_in is param1
        reg_sel_2_d = bus_data_in[7:6];
        reg_sel_in_d = bus_data_in[5:4];
        use_register_bank_in_d = bus_data_in[3];
        use_register_bank_out_1_d = bus_data_in[2];

        mem_ctrl_op_d = MEM_NOP;
        mux_sel_d = MUX_ALU;
        reg_op_d = REG_WRITE;
        state_d = ST_INC_PC;
        flag_carry_d = flag_carry_in;
        flag_zero_d = flag_zero_in;
      end
    end
    ST_LDX_WAIT_RAM_READ: begin
      mem_ctrl_op_d = MEM_READ;
      addr_sel_d = MAR;
      mux_sel_d = MUX_MEM;
      reg_sel_in_d = reg_sel_in;
      use_register_bank_in_d = use_register_bank_in;
      if (mem_op_done) begin
        reg_op_d = REG_WRITE;
        state_d = ST_INC_PC;
      end
    end
    ST_LDX_WAIT_FLASH_READ: begin
      mem_ctrl_op_d = MEM_READ;
      addr_sel_d = PC;
      mux_sel_d = MUX_MEM;
      reg_sel_in_d = reg_sel_in;
      use_register_bank_in_d = use_register_bank_in;
      if (mem_op_done) begin
        reg_op_d = REG_WRITE;
        state_d = ST_INC_PC;
      end
    end
    ST_LDX_WAIT_WRITE: begin
      reg_sel_1_d = reg_sel_1;
      use_register_bank_out_1_d = use_register_bank_out_1;
      alu_op_d = THR;
      mux_sel_d = MUX_ALU;
      mem_ctrl_op_d = MEM_WRITE;
      addr_sel_d = MAR;
      if (mem_op_done) begin
        state_d = ST_INC_PC;
      end
    end
    ST_JMP_WAIT_PARAM_READ: begin
      mem_ctrl_op_d = MEM_READ;
      addr_sel_d = PC;
      mux_sel_d = MUX_MEM;
      jmp_op_addr_sel_d = jmp_op_addr_sel;
      reg_sel_1_d = reg_sel_1;
      use_register_bank_out_1_d = use_register_bank_out_1;
      alu_op_d = THR;
      if (mem_op_done) begin
        // bus_data_in is param1
        addr_sel_d = jmp_op_addr_sel;
        addr_reg_op_d = bus_data_in[7:5];
        mux_sel_d = MUX_ALU;
        state_d = ST_INC_PC;
      end
      
    end


    
  endcase

  end

  `ifndef SCAN
    wire test = 1'b0;
    wire scan_in = 1'b0;
  `endif
  always_comb begin
    state_dt = test ? {scan_in, state[3:1]} : state_d;
    mem_ctrl_op_dt = test ? {state[0], mem_ctrl_op[1]} : mem_ctrl_op_d;
    addr_reg_op_dt = test ? {mem_ctrl_op[0], addr_reg_op[2:1]} : addr_reg_op_d;
    addr_sel_dt = test ? addr_reg_op[0] : addr_sel_d;
    alu_op_dt = test ? {addr_sel, alu_op[3:1]} : alu_op_d;
    reg_op_dt = test ? alu_op[0] : reg_op_d;
    reg_sel_in_dt = test ? {reg_op, reg_sel_in[1]} : reg_sel_in_d;
    reg_sel_1_dt = test ? {reg_sel_in[0], reg_sel_1[1]} : reg_sel_1_d;
    reg_sel_2_dt = test ? {reg_sel_1[0], reg_sel_2[1]} : reg_sel_2_d;
    mux_sel_dt = test ? {reg_sel_2[0], mux_sel[1]} : mux_sel_d;
    jmp_op_addr_sel_dt = test ? mux_sel[0] : jmp_op_addr_sel_d;
    flag_carry_dt = test ? jmp_op_addr_sel : flag_carry_d;
    flag_zero_dt = test ? flag_carry : flag_zero_d;
    use_register_bank_in_dt = test ? flag_zero : use_register_bank_in_d;
    use_register_bank_out_1_dt = test ? use_register_bank_in : use_register_bank_out_1_d;
  end

  `ifdef SCAN
  assign scan_out = test ? use_register_bank_out_1 : 1'b0;
  `endif

  always_ff @(posedge clock) begin
    if (!reset) begin
      state <= ST_FETCH;
      mem_ctrl_op <= MEM_NOP;
      addr_reg_op <= AR_NOP;
      addr_sel <= MAR;
      alu_op <= THR;
      reg_op <= REG_NOP;
      reg_sel_in <= REG_A;
      reg_sel_1 <= REG_A;
      reg_sel_2 <= REG_A;
      use_register_bank_in <= 0;
      use_register_bank_out_1 <= 0;
      mux_sel <= MUX_ALU;
      jmp_op_addr_sel <= 0;
      flag_carry <= 0;
      flag_zero <= 0;
    end else begin
      state <= state_dt;
      mem_ctrl_op <= mem_ctrl_op_dt;
      addr_reg_op <= addr_reg_op_dt;
      addr_sel <= addr_sel_dt;
      alu_op <= alu_op_dt;
      reg_op <= reg_op_dt;
      reg_sel_in <= reg_sel_in_dt;
      reg_sel_1 <= reg_sel_1_dt;
      reg_sel_2 <= reg_sel_2_dt;
      use_register_bank_in <= use_register_bank_in_dt;
      use_register_bank_out_1 <= use_register_bank_out_1_dt;
      mux_sel <= mux_sel_dt;
      jmp_op_addr_sel <= jmp_op_addr_sel_dt;
      flag_carry <= flag_carry_dt;
      flag_zero <= flag_zero_dt;
    end
  end


endmodule
