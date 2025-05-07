import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from lib.utils import reset
from lib.scan_chain import ScanPattern, shift_pattern_in, shift_pattern_out
from lib.controlpack import CTRL_STATE, ALU_OP, MUX_SEL, REGISTERS_OP
from alu_test import arithmetic_params, logic_params, shift_params

@cocotb.test()
async def test_nth_sum(dut):
  clock = Clock(dut.clock, 2, units="ns")
  cocotb.start_soon(clock.start())

  await RisingEdge(dut.clock)

  await reset(dut)

  for _ in range(400*15*23):
    await RisingEdge(dut.clock)
    if dut.reg_d.value == 255:
      break
  else: 
    scan_out = await shift_pattern_out(dut)

    print(scan_out._regs)

    assert False, "Failed to reach HLT instruction"
    
  scan_out = await shift_pattern_out(dut)

  print(scan_out._regs)

  assert scan_out._regs[0] == 20, "Sum is not 20"
  assert scan_out._regs[1] == 23, "Counter is not 23"

