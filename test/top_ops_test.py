import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from lib.utils import reset
from lib.scan_chain import ScanPattern, shift_pattern_in, shift_pattern_out
from lib.controlpack import CTRL_STATE, ALU_OP, MUX_SEL, REGISTERS_OP
from alu_test import arithmetic_params, logic_params, shift_params

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

  params = arithmetic_params + logic_params + shift_params
  for param in params:
      test_pattern=ScanPattern()
      test_pattern.set_ctrl_state(15) # default case
      test_pattern.set_alu_op(param.op.value)
      test_pattern.set_reg_sel_1(0)
      test_pattern.set_reg_sel_2(1)
      test_pattern.set_reg_sel_in(3)
      test_pattern.set_reg_op(REGISTERS_OP.REG_WRITE.value)
      test_pattern.set_op_done_out(1)
      test_pattern.set_mux_sel(MUX_SEL.MUX_ALU.value)
      test_pattern.set_register(0, param.reg1)
      test_pattern.set_register(1, param.reg2)


      await shift_pattern_in(dut, test_pattern)
      
      await RisingEdge(dut.clock)
      await RisingEdge(dut.clock)

      assert dut.reg_d.value == param.expected_result, f"Failed: {param.test_name}"

      output_pattern = await shift_pattern_out(dut)

