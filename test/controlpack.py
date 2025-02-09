from enum import Enum 

class ALU_OP(Enum):
        ALUNOP = 0
        THR = 1
        ADD = 2
        SUB = 3
        SHL = 4
        ROL = 5
        SHR = 6
        ROR = 7
        AND = 8
        OR = 9
        XOR = 0x0a
        NOT = 0x0b

DATA_BUS_WIDTH = 8 
NUM_REGISTERS = 4 

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
        IR_NOP = 0
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