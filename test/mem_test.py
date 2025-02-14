import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, RisingEdge, Timer
from cocotb.result import TestSuccess, TestFailure
import random
from controlpack import MEM_CTRL_OP, ADDR_SEL, ADDR_REG_OP, DATA_BUS_WIDTH

@cocotb.test()
async def test_flash_read(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    await RisingEdge(dut.clock)
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    
    dut.addr_sel.value = ADDR_SEL.PC.value
    dut.bus_data_in.value = 0x10
    dut.addr_reg_op.value = ADDR_REG_OP.ABSOLUTE.value
    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    dut.addr_reg_op.value = ADDR_REG_OP.IR_NOP.value

    dut.op.value = MEM_CTRL_OP.MEM_READ.value
    
    for i in range(500):
        await RisingEdge(dut.clock)
        if dut.op_done_out == 1:
            assert dut.bus_data_out.value == 0xA2, "Read failed"
            break
    else:
        assert False, "Read failed"

        
@cocotb.test()
async def test_ram_read_write(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    await RisingEdge(dut.clock)
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    
    dut.addr_sel.value = ADDR_SEL.PC.value
    dut.bus_data_in.value = 0x20
    dut.addr_reg_op.value = ADDR_REG_OP.ABSOLUTE.value
    await RisingEdge(dut.clock)
    dut.addr_reg_op.value = ADDR_REG_OP.IR_NOP.value
    dut.bus_data_in.value = 0xAB
    dut.op.value = MEM_CTRL_OP.MEM_WRITE.value
    dut.addr_sel.value = ADDR_SEL.MAR.value

    for i in range(500): 
        await RisingEdge(dut.clock)
        if dut.op_done_out == 1:
            break
    else: 
        assert False, "Write failed"
    dut.op.value = MEM_CTRL_OP.MEM_NOP.value
    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    await RisingEdge(dut.clock)
    dut.op.value = MEM_CTRL_OP.MEM_READ.value

    for i in range(500):
        await RisingEdge(dut.clock)
        if dut.op_done_out == 1:
            print("Read data: ", dut.bus_data_out.value)
            assert dut.bus_data_out.value == 0xAB, "Read failed"
            break
    else:
        assert False, "Read failed"
