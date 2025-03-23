import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from lib.utils import reset
from lib.scan_chain import ScanPattern, shift_pattern_in, shift_pattern_out
from lib.controlpack import CTRL_STATE, ALU_OP, MUX_SEL, REGISTERS_OP
from alu_test import arithmetic_params, logic_params, shift_params

@cocotb.test()
async def test_mapped_register_bank(dut):
  clock = Clock(dut.clock, 2, units="ns")
  cocotb.start_soon(clock.start())

  await RisingEdge(dut.clock)

  await reset(dut)

  for _ in range(100000):
    await RisingEdge(dut.clock)
    if dut.reg_d.value == 255:
      break
  else: 
    assert False, "Failed to reach HLT instruction"

  scan_out = await shift_pattern_out(dut)

  assert scan_out._regs[1] == 89, "Result is not 89"

