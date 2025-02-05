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
        INWRITE = 0
        INNOP = 1

class REGISTER_SEL(Enum):
        REG_A = 0
        REG_B = 1
        REG_C = 2
        REG_D = 3
      

if __name__ == "__main__":
        for reg in REGISTER_SEL:
                print(f"Register {reg} has value {reg}")