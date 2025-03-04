module mem_ctrl #(parameter DATA_BUS_WIDTH = 8, parameter ADDRESS_WIDTH = 16) (
  input logic clock, 
  input logic reset,
  
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
  input   data_ready

);
  // Address Register
  logic[ADDRESS_WIDTH-1:0] addrs_d[2]; // Intermediate state of the registers
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


  always_ff @(posedge clock) begin
    if (!reset) begin 
      addrs[0] <= 0;
      addrs[1] <= 0;
    end else begin
      addrs[0] <= addrs_d[0];
      addrs[1] <= addrs_d[1];
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
    end else if (state_d == ST_IDLE) begin
      bus_data_out_d = 0;
    end

    if (state_d == ST_WAIT_WRITE && start_write_d) begin
      data_out_d = bus_data_in;
    end else if (state_d == ST_IDLE) begin
      data_out_d = 0;
    end

  end

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
      state <= state_d;
      op_done_out <= op_done_out_d;
      start_read <= start_read_d;
      start_write <= start_write_d;
      stall_txn <= stall_txn_d;
      stop_txn <= stop_txn_d;
      bus_data_out <= bus_data_out_d;
      data_out <= data_out_d;
    end
 
 end

endmodule
