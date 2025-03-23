from lib.instructions import JMP, LDX, AOP, NOP
from lib.controlpack import REGISTER_SEL, ALU_OP, LDX_OP


def fibonacci_program():
  """
  LDA 0 ; Initalize register A with 0
LDB 1 ; Initalize register B with 1
ADD ; Add register A and B and store into register C
MBA ; Move register B to A
MCB ; Move register C to B
... ; Repeat ADD, MBA, MCB n times to reach the (n+1)th element
HLT ; Signal execution is complete
  """

  instructions = []
  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_A).set_immediate_value(0))
  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_B).set_immediate_value(1))
  for i in range(10):
    instructions.append(AOP().set_op(ALU_OP.ADD).set_sel_1(REGISTER_SEL.REG_A).set_sel_2(REGISTER_SEL.REG_B).set_sel_in(REGISTER_SEL.REG_C))
    instructions.append(AOP().set_op(ALU_OP.THR).set_sel_1(REGISTER_SEL.REG_B).set_sel_in(REGISTER_SEL.REG_A))
    instructions.append(AOP().set_op(ALU_OP.THR).set_sel_1(REGISTER_SEL.REG_C).set_sel_in(REGISTER_SEL.REG_B))

  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_D).set_immediate_value(255)) # HLT
  
  return instructions


if __name__ == "__main__":
  with open("top_fib_test.hex", "w") as f:
    for instruction in fibonacci_program():
      f.write(instruction.to_hex() + "\n")
  

