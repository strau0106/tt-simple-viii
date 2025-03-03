import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def top_alu_test(dut):
  clock = Clock(dut.clock, 2, units="ps") 
  cocotb.start_soon(clock.start())

  dut.reset.value = 0
  await RisingEdge(dut.clock)
  dut.reset.value = 1
  
  for _ in range(800):
    await RisingEdge(dut.clock)
