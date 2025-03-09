import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from lib.utils import reset
from lib.scan_chain import ScanPattern, shift_pattern_in, shift_pattern_out
from lib.controlpack import CTRL_STATE, ALU_OP, MUX_SEL, REGISTERS_OP

@cocotb.test()
async def top_alu_test(dut):
  clock = Clock(dut.clock, 2, units="ns") 
  cocotb.start_soon(clock.start())
  dut.test.value = 0
  dut.reset.value = 0
  await RisingEdge(dut.clock)
  dut.reset.value = 1
  
  for _ in range(800):
    await RisingEdge(dut.clock)

@cocotb.test()
async def test_alu_op(dut):
  clock = Clock(dut.clock, 2, units="ns")
  cocotb.start_soon(clock.start())
  dut.scan_in.value = 0
  await reset(dut)

  test_pattern=ScanPattern()
  test_pattern.set_ctrl_state(15) # default case
  test_pattern.set_alu_op(ALU_OP.ADD.value)
  test_pattern.set_reg_sel_1(0)
  test_pattern.set_reg_sel_2(1)
  test_pattern.set_reg_sel_in(3)
  test_pattern.set_reg_op(REGISTERS_OP.REG_WRITE.value)
  test_pattern.set_op_done_out(1)
  test_pattern.set_mux_sel(MUX_SEL.MUX_ALU.value)
  test_pattern.set_register(0, 23)
  test_pattern.set_register(1, 27)


  await shift_pattern_in(dut, test_pattern)
  
  await RisingEdge(dut.clock)
  await RisingEdge(dut.clock)

  assert dut.reg_d.value == 50, f"ALU_OP ADD failed: Expected 50, got {dut.reg_d.value}"

  output_pattern = await shift_pattern_out(dut)

  assert output_pattern._regs[3] == 50, f"ALU_OP ADD failed: Expected 50, got {output_pattern._regs[2]}"

@cocotb.test()
async def test_mapped_register_bank(dut):
  clock = Clock(dut.clock, 2, units="ns")
  cocotb.start_soon(clock.start())
  dut.scan_in.value = 0
  await reset(dut)

  test_pattern=ScanPattern()
  test_pattern.set_ctrl_state(0)
  test_pattern.set_addr(1, 127)
  test_pattern.set_register(0, 1)
  test_pattern.set_register(1, 1)
  test_pattern.set_register(2, 10)
  test_pattern.set_bank_register(0, 0x44) 
  test_pattern.set_bank_register(1, 0x40) # AOP; ADD; REG_A; REG_B; REG_A
  test_pattern.set_bank_register(3, 0x44)
  test_pattern.set_bank_register(4, 0x80)
  test_pattern.set_bank_register(5, 0x40)
  test_pattern.set_bank_register(6, 0x30)

  await shift_pattern_in(dut, test_pattern)

  await RisingEdge(dut.clock)

  for _ in range(800):
    await RisingEdge(dut.clock)