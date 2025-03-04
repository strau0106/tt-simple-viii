from enum import Enum 

DATA_BUS_WIDTH = 8
ADDRESS_WIDTH = 16
NUM_REGISTERS = 4 

class ALU_OP(Enum):
        THR = 0
        ADD = 1
        SUB = 2
        SHL = 3
        ROL = 4
        SHR = 5
        ROR = 6
        AND = 7
        OR = 8
        XOR = 9
        NOT = 10

class REGISTERS_OP(Enum):
        REG_NOP = 0
        REG_WRITE = 1

class REGISTER_SEL(Enum):
        REG_A = 0
        REG_B = 1
        REG_C = 2
        REG_D = 3
      
class MEM_CTRL_STATE(Enum):
        ST_IDLE = 0
        ST_WAIT_READ = 1
        ST_DATA_READY = 2
        ST_WAIT_WRITE = 3  

class ADDR_REG_OP(Enum):
        AR_NOP = 0
        ABSOLUTE = 1
        REL_SUB = 2
        REL_ADD = 3
        INC = 4

class ADDR_SEL(Enum):
        MAR = 0
        PC = 1

class MEM_CTRL_OP(Enum):
        MEM_NOP = 0
        MEM_READ = 1
        MEM_WRITE = 2

class MUX_SEL(Enum):
        MUX_ALU = 0
        MUX_MEM = 1
        MUX_IO = 2

class CTRL_STATE(Enum):
        ST_FETCH = 0
        ST_DECODE = 1
        ST_ALU_OP = 2
        ST_LDX_OP = 3
        ST_LDX_WAIT_RAM_READ = 4
        ST_LDX_WAIT_FLASH_READ = 5
        ST_LDX_WAIT_WRITE = 6
        ST_JMP_WAIT_PARAM_READ = 7
        ST_INC_PC = 8
