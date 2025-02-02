from cocotb.triggers import Timer


async def advance_sim(dut):
    await Timer(1, units="ns")
