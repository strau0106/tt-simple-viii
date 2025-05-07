from lib.instructions import JMP, LDX, AOP, NOP
from lib.controlpack import REGISTER_SEL, ALU_OP, LDX_OP, ADDR_REG_OP, ADDR_SEL


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

def nth_sum_program():
  """
  LDB 0
  LDC 0 ; Init the registers with 0
  LDA 1 ; Load 1 into register A
  ADB   ; Add registers A and B and store into B
  MCA   ; Move register C into A
  ADC   ; Add registers A and B and store into C
  JNC 5 ; Jump four instructions backward if carry not set. 
  ; Jump is instructed to one beforehand so, it points to ADB after the increment
  HLT   ; Halt computer
  """
  instructions = []

  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_B).set_immediate_value(0))
  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_C).set_immediate_value(1))

  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_A).set_immediate_value(5))

  instructions.append(AOP().set_op(ALU_OP.ADD).set_sel_1(REGISTER_SEL.REG_B).set_sel_2(REGISTER_SEL.REG_C).set_sel_in(REGISTER_SEL.REG_B))
  #instructions.append(AOP().set_op(ALU_OP.THR).set_sel_1(REGISTER_SEL.REG_D).set_sel_in(REGISTER_SEL.REG_D))
  instructions.append(AOP().set_op(ALU_OP.ADD).set_sel_1(REGISTER_SEL.REG_D).set_sel_2(REGISTER_SEL.REG_B).set_sel_in(REGISTER_SEL.REG_D))
  
  instructions.append(JMP().set_carry(0).set_zero(1).set_sel_1(REGISTER_SEL.REG_A).set_ar_op(ADDR_REG_OP.ABSOLUTE).set_ar_sel(ADDR_SEL.PC))
  instructions.append(AOP().set_sel_1(REGISTER_SEL.REG_D).set_sel_in(REGISTER_SEL.REG_A).set_op(ALU_OP.THR))
  instructions.append(LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_D).set_immediate_value(255)) # HLT

  return instructions

def brainfuck():
  bf_prog = "++>>+++++[-[-]]>>+++"


  plus_instructions = [LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_B).set_immediate_value(1), LDX().set_ldxop(LDX_OP.RAM2REG).set_sel(REGISTER_SEL.REG_A), AOP().set_op(ALU_OP.ADD).set_sel_1(REGISTER_SEL.REG_A).set_sel_2(REGISTER_SEL.REG_B).set_sel_in(REGISTER_SEL.REG_A), LDX().set_ldxop(LDX_OP.REG2RAM).set_sel(REGISTER_SEL.REG_A)]
  minus_instructions = [LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_B).set_immediate_value(1), LDX().set_ldxop(LDX_OP.RAM2REG).set_sel(REGISTER_SEL.REG_A), AOP().set_op(ALU_OP.SUB).set_sel_1(REGISTER_SEL.REG_A).set_sel_2(REGISTER_SEL.REG_B).set_sel_in(REGISTER_SEL.REG_A), LDX().set_ldxop(LDX_OP.REG2RAM).set_sel(REGISTER_SEL.REG_A)]
  greater_instructions = [LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_B).set_immediate_value(1), JMP().set_carry(0).set_zero(0).set_sel_1(REGISTER_SEL.REG_B).set_ar_op(ADDR_REG_OP.REL_ADD).set_ar_sel(ADDR_SEL.MAR)]
  lesser_instructions = [LDX().set_ldxop(LDX_OP.FLASH2REG).set_sel(REGISTER_SEL.REG_B).set_immediate_value(1), JMP().set_carry(0).set_zero(0).set_sel_1(REGISTER_SEL.REG_B).set_ar_op(ADDR_REG_OP.REL_SUB).set_ar_sel(ADDR_SEL.MAR)]
  

if __name__ == "__main__":
  with open("top_fib_test.hex", "w") as f:
    for instruction in fibonacci_program():
      f.write(instruction.to_hex() + "\n")

  with open("top_nth_sum_test.hex", "w") as f:
    for instruction in nth_sum_program():
      f.write(instruction.to_hex() + "\n")
  

