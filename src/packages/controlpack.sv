typedef enum logic[3:0] { 
    THR, //register1 Input feed through result.
    ADD,
    SUB,
    SHL,
    ROL,
    SHR,
    ROR,
    AND,
    OR,
    XOR,
    NOT
} alu_op_e /*verilator public*/;

typedef struct packed {
    logic alu_zero;
    logic alu_carry;
} alu_flag_t /*verilator public*/;

typedef enum logic[1:0] {
        REG_A,
        REG_B,
        REG_C,
        REG_D
} register_sel_e /*verilator public*/;

typedef enum logic{
    REG_NOP,
    REG_WRITE
} registers_op_e /*verilator public*/;

typedef enum logic[2:0] {
        AR_NOP,
        ABSOLUTE,
        REL_SUB,
        REL_ADD,
        INC
} addr_register_op_e /*verilator public*/;

typedef enum logic {
    MAR,
    PC
} addr_sel_e /*verilator public*/;

typedef enum logic[1:0] {
    MEM_NOP,
    MEM_READ,
    MEM_WRITE
} mem_ctrl_op_e /*verilator public*/;

typedef enum logic[1:0] {
    MUX_ALU,
    MUX_MEM,
    MUX_IO
} mux_sel_e /*verilator public*/;

typedef enum logic[1:0]{
    NOP = 0, //Just load the next instruction.
    ALU = 1, //ALU Operation (lower nibble defines operation), following byte in and out
    LDX = 2, //Load memory to register
    JMP = 3
    
} instructions_e /*verilator public*/;

typedef enum logic [1:0] {
    REG2RAM,
    RAM2REG,
    FLASH2REG
} ldx_op_e /*verilator public*/;