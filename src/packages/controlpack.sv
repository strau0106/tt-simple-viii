//d efine ADDR_BUS_WIDTH 9
//d efine DATA_BUS_WIDTH 8
//d efine MICRO_INSTRUCTION_WORD_WIDTH 14
//d efine CONTROL_WORD_WIDTH 25

package controlpack;
    typedef enum logic[3:0] {
        ALUNOP, 
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
    //typedef enum logic [1:0] {
    //    NONE,
    //    ZERO,
    //    CARRY,
    //    REMAINDER
    //} alu_flag_e /*verilator public*/;

    typedef struct packed {
        logic alu_zero;
        logic alu_carry;
    }alu_flag_t;

    typedef enum logic [2:0] {
        READ,
        WRITE
    } memory_op_e /*verilator public*/;

    typedef enum logic [2:0] {
            IR_NOP,
            ABSOLUTE,
            REL_SUB,
            REL_ADD,
            INC
    } address_reg_op_e /*verilator public*/;

    typedef enum logic [2:0] {
            REG_A,
            REG_B,
            REG_ADDR_LOW,
            REG_ADDR_HIGH,
            PC_ADDR_LOW,
            PC_ADDR_HIGH,
            MC_EXT_ADDR_BASE_LOW,
            MC_EXT_ADDR_BASE_HIGH
    } register_sel_e /*verilator public*/;
    
    typedef enum bit {
        MAR,
        PC
    } memory_bus_selector_e /*verilator public*/;

    typedef enum logic[1:0]{
        REG_NOP,
        LOAD,
        ENABLE
    } reg_op_e /*verilator public*/;

    typedef enum logic{
        INWRITE,
        INNOP
    } register_op_e /*verilator public*/;

    typedef enum logic{
        ALU,
        BUS
    } register_in_source_e /*verilator public*/;

    typedef enum logic{
        ADDRESS_REGISTER,
        CONTROL_ADDRESS //could be PC or microcode address (Controler decides)
    } address_source_sel_e /*verilator public*/;

    typedef enum logic[3:0]{
        NOP, //Just load the next instruction.
        LDX, //Load memory to register
        AOP //ALU Operation (lower nibble defines operation), following byte in and out
        
    } instructions_e /*verilator public*/;


    typedef struct packed {
        alu_op_e alu_op;
        memory_op_e memory_op;
        register_sel_e ControlSelInxD;    //selects where the data at the input will be stored to.
        register_sel_e ControlSelReg1xD;  //selects which register will be presented at the Reg1 output.
        register_sel_e ControlSelReg2xD;  //selects which register will be presented at the Reg2 output.
        register_in_source_e SelInSourcexS; //selects either the ALU result or data on the data bus as input to the register.
        logic reset;
        logic halt;
        logic control_unit_load; 
        logic next_instr; // could be stripped away.        
    } control_word_t;

endpackage
