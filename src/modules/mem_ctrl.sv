/* verilator lint_off ENUMVALUE */

module mem_ctrl #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16, parameter REGISTER_BANK_STARTING_ADDRESS = 127) (
  input logic clock, 
  input logic reset,
  
  `ifdef SCAN
  input logic test,
  input logic scan_in,
  output logic scan_out,
  `endif

  // CPU Interface
  input mem_ctrl_op_e op,
  input addr_register_op_e addr_reg_op,
  input addr_sel_e addr_sel,
  
  input logic[DATA_BUS_WIDTH-1:0] bus_data_in,
  output logic op_done_out,
  output logic[DATA_BUS_WIDTH-1:0] bus_data_out,

  // SPI interface
  output logic[24:0] addr_out,
  output logic[7:0] data_out,
  output logic start_read,
  output logic start_write,
  output logic stall_txn,
  output logic stop_txn,

  input [7:0] data_in,
  input   data_req,
  input   data_ready,

  // REGISTER BANK interface
  input logic[DATA_BUS_WIDTH*8-1:0] register_bank_in

);
  // Address Register
  logic[ADDRESS_WIDTH-1:0] addrs_d[2]; // Intermediate state of the registers
  logic[ADDRESS_WIDTH-1:0] addrs_dt[2];
  logic[ADDRESS_WIDTH-1:0] addrs[2];

  assign addr_out = {(addr_sel == PC) ? 2'b00 : 2'b10, 7'b0, addrs[addr_sel]};

  logic[ADDRESS_WIDTH-1:0] addr_in;
  assign addr_in = {8'b0, bus_data_in};

  always_comb begin
    addrs_d[0] = addrs[0];
    addrs_d[1] = addrs[1];
    

    case (addr_reg_op)
      default:
        ;
      ABSOLUTE:
        addrs_d[addr_sel] = addr_in;
      REL_SUB:
        addrs_d[addr_sel] = addrs_d[addr_sel] - addr_in;
      REL_ADD:
        addrs_d[addr_sel] = addrs_d[addr_sel] + addr_in;
      INC:
        addrs_d[addr_sel] = addrs_d[addr_sel] + 1;
      endcase
  end

  `ifndef SCAN
    wire test = 1'b0;
    wire scan_in = 1'b0;
  `endif

  always_comb begin
    addrs_dt[0] = test ? {scan_in, addrs[0][ADDRESS_WIDTH-1:1]} : addrs_d[0];
    addrs_dt[1] = test ? {addrs[0][0], addrs[1][ADDRESS_WIDTH-1:1]} : addrs_d[1];
  end

  logic scan_out_addr_reg;
  assign scan_out_addr_reg = test ? addrs_d[1][0] : 1'b0;


  always_ff @(posedge clock) begin
    if (!reset) begin 
      addrs[0] <= 0;
      addrs[1] <= 0;
    end else begin
      addrs[0] <= addrs_dt[0];
      addrs[1] <= addrs_dt[1];
    end
  end

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_WAIT_READ,
    ST_DATA_READY,
    ST_WAIT_WRITE
  } mem_ctrl_state_t /*verilator public*/;

  mem_ctrl_state_t state, state_d;
  logic op_done_out_d;
  logic start_read_d;
  logic start_write_d;
  logic stall_txn_d;
  logic stop_txn_d;
  logic [7:0] bus_data_out_d, data_out_d;


  always_comb begin
    state_d = state;
    op_done_out_d = 0;
    start_read_d= 0;
    start_write_d = 0;
    stall_txn_d = 0;
    stop_txn_d = 0;
    bus_data_out_d = bus_data_out;
    data_out_d = data_out;

    case (state)
      // TODO: Implement stall. 
      ST_IDLE: begin
        if (op == MEM_READ) begin
          if (addr_sel == PC && addrs[addr_sel] >= REGISTER_BANK_STARTING_ADDRESS && addrs[addr_sel] < REGISTER_BANK_STARTING_ADDRESS+8) begin
            op_done_out_d = 1;
            state_d = ST_DATA_READY;
          end else begin
            start_read_d = 1;
            state_d = ST_WAIT_READ;
          end
          start_read_d = 1;
          state_d = ST_WAIT_READ;
        end else if (op == MEM_WRITE) begin
          start_write_d = 1;
          state_d = ST_WAIT_WRITE;
        end
      end

      ST_WAIT_READ: begin
        
        if (op != MEM_READ) begin
          state_d = ST_IDLE;
          stop_txn_d = 1;
        end
        if (data_ready) begin
          op_done_out_d = 1;
          state_d = ST_DATA_READY;
        end
      end

      ST_DATA_READY: begin
        stall_txn_d = 1;
        op_done_out_d = 0;
        if (op != MEM_READ) begin
          state_d = ST_IDLE;
          stop_txn_d = 1;
        end
      end


      ST_WAIT_WRITE: begin
        if (op != MEM_WRITE) begin
          state_d = ST_IDLE;
          stop_txn_d = 1;
        end else if (data_req) begin
          op_done_out_d = 1;
          stop_txn_d = 1;
          state_d = ST_IDLE;
        end
      end



      default: state_d = ST_IDLE;
    endcase

    if (state_d == ST_DATA_READY && data_ready) begin
      bus_data_out_d = data_in;
    end else if (addr_sel == PC && addrs[addr_sel] >= REGISTER_BANK_STARTING_ADDRESS && addrs[addr_sel] < REGISTER_BANK_STARTING_ADDRESS+8 && op == MEM_READ) begin
      bus_data_out_d = register_bank_in[addrs[addr_sel] - REGISTER_BANK_STARTING_ADDRESS +: 8];
    end else if (state_d == ST_IDLE) begin
      bus_data_out_d = 0;
    end

    if (state_d == ST_WAIT_WRITE && start_write_d) begin
      data_out_d = bus_data_in;
    end else if (state_d == ST_IDLE) begin
      data_out_d = 0;
    end

  end

  logic[1:0] state_dt;
  logic op_done_out_dt;
  logic start_read_dt;
  logic start_write_dt;
  logic stall_txn_dt;
  logic stop_txn_dt;
  logic [7:0] bus_data_out_dt, data_out_dt;

  assign state_dt = test ? {scan_out_addr_reg, state[1]} : state_d;

  always_comb begin
    op_done_out_dt = test ? state[0] : op_done_out_d;
    start_read_dt = test ? op_done_out : start_read_d;
    start_write_dt = test ? start_read : start_write_d;
    stall_txn_dt = test ? start_write : stall_txn_d;
    stop_txn_dt = test ? stall_txn : stop_txn_d;
    bus_data_out_dt = test ? {stop_txn, bus_data_out[7:1]} : bus_data_out_d;
    data_out_dt = test ? {bus_data_out[0], data_out[7:1]} : data_out_d;
  end

  `ifdef SCAN
  assign scan_out = test ? data_out[0] : 1'b0;
  `endif

  always_ff @(posedge clock) begin
    if (!reset) begin
      state <= ST_IDLE;
      bus_data_out <= 0;
      data_out <= 0;
      op_done_out <= 0;
      start_read <= 0;
      start_write <= 0;
      stall_txn <= 0;
      stop_txn <= 0;
    end else begin
      state <= state_dt;
      op_done_out <= op_done_out_dt;
      start_read <= start_read_dt;
      start_write <= start_write_dt;
      stall_txn <= stall_txn_dt;
      stop_txn <= stop_txn_dt;
      bus_data_out <= bus_data_out_dt;
      data_out <= data_out_dt;
    end
 
 end

endmodule
