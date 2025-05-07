import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from lib.utils import reset
from lib.scan_chain import ScanPattern, shift_pattern_in, shift_pattern_out
from lib.controlpack import CTRL_STATE, ALU_OP, MUX_SEL, REGISTERS_OP
from alu_test import arithmetic_params, logic_params, shift_params


@cocotb.test()
async def test_register_write(dut):   
  clock = Clock(dut.clock, 2, units="ns")
  cocotb.start_soon(clock.start())
  dut.scan_in.value = 0
  await RisingEdge(dut.clock)
  await reset(dut)
  
  test_pattern = ScanPattern()
  test_pattern.set_register(0, 5)
  test_pattern.set_alu_op(0) # THR
  test_pattern.set_reg_sel_1(0)
  test_pattern.set_reg_sel_in(1) # REG_B
  test_pattern.set_reg_op(1) # WRITE

  await shift_pattern_in(dut, test_pattern)

  await RisingEdge(dut.clock)

  output_pattern = await shift_pattern_out(dut)

  assert output_pattern._regs[1] == 5





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