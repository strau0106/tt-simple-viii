import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, RisingEdge, Timer
from cocotb.result import TestSuccess, TestFailure
import random
from controlpack import ADDR_REG_OP, ADDR_SEL, DATA_BUS_WIDTH

async def reset(dut):
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)

@cocotb.test()
async def test_write_absolute(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    for addr in ADDR_SEL:
        await reset(dut)
        dut.addr_reg_op.value = ADDR_REG_OP.ABSOLUTE.value
        dut.addr_sel.value = addr.value
        dut.bus_data_in.value = 0x10
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        assert dut.addr_out.value == 0x10+((1<<24) if addr == ADDR_SEL.MAR else 0), "Absolute address write failed"

@cocotb.test()
async def test_write_relative_sub(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    for addr in ADDR_SEL:
        await reset(dut)
        dut.addr_reg_op.value = ADDR_REG_OP.ABSOLUTE.value
        dut.addr_sel.value = addr.value
        dut.bus_data_in.value = 0x20
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        
        dut.addr_reg_op.value = ADDR_REG_OP.REL_SUB.value
        dut.bus_data_in.value = 0x10
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        assert dut.addr_out.value == 0x10+((1<<24) if addr == ADDR_SEL.MAR else 0), "Relative subtract address write failed"

@cocotb.test()
async def test_write_relative_add(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    for addr in ADDR_SEL:
        await reset(dut)
        dut.addr_reg_op.value = ADDR_REG_OP.ABSOLUTE.value
        dut.addr_sel.value = addr.value
        dut.bus_data_in.value = 0x20
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        
        dut.addr_reg_op.value = ADDR_REG_OP.REL_ADD.value
        dut.bus_data_in.value = 0x10
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        assert dut.addr_out.value == 0x30+((1<<24) if addr == ADDR_SEL.MAR else 0), "Relative add address write failed"

@cocotb.test()
async def test_write_increment(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    for addr in ADDR_SEL:
        await reset(dut)
        dut.addr_reg_op.value = ADDR_REG_OP.ABSOLUTE.value
        dut.addr_sel.value = addr.value
        dut.bus_data_in.value = 0x20
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        
        dut.addr_reg_op.value = ADDR_REG_OP.INC.value
        await RisingEdge(dut.clock)
        await RisingEdge(dut.clock)
        assert dut.addr_out.value == 0x21+((1<<24) if addr == ADDR_SEL.MAR else 0), "Increment address write failed"

