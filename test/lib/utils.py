from cocotb.triggers import Timer, RisingEdge


async def advance_sim(dut):
    await Timer(1, units="ns")

async def reset(dut):
    dut.test.value = 0
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
