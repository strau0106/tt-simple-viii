import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, RisingEdge, Timer
from cocotb.result import TestSuccess, TestFailure
import random
from controlpack import REGISTERS_OP, REGISTER_SEL, DATA_BUS_WIDTH

async def reset(dut):
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)

async def write_register(dut, reg_sel, data):
    dut.op.value = REGISTERS_OP.REG_WRITE.value
    dut.reg_in_sel.value = reg_sel.value
    dut.reg_data_in.value = data
    await RisingEdge(dut.clock)
    dut.op.value = REGISTERS_OP.REG_NOP.value

async def read_registers(dut, reg_1_sel, reg_2_sel):
    dut.reg_1_out_sel.value = reg_1_sel.value
    dut.reg_2_out_sel.value = reg_2_sel.value
    await Timer(1, units="ns")
    return dut.reg_1_out.value, dut.reg_2_out.value

@pytest.mark.dependency()
@cocotb.test()
async def test_basic_sequential_write_read(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset(dut)
     
    for reg in REGISTER_SEL:
        test_value = random.randint(0, 2**DATA_BUS_WIDTH - 1)
        await write_register(dut, reg, test_value)
        reg_1_out, _ = await read_registers(dut, reg, REGISTER_SEL.REG_A)
        assert reg_1_out == test_value, f"Write/Read failed: Register {reg.name} expected {test_value}, got {reg_1_out}"

@pytest.mark.dependency(depends=["test_basic_sequential_write_read"])
@cocotb.test() 
async def test_reset_functionality(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())

    for reg in REGISTER_SEL:
        test_value = random.randint(0, 2**DATA_BUS_WIDTH - 1)
        await write_register(dut, reg, test_value)

    await RisingEdge(dut.clock)

    await reset(dut)
    
    for reg in REGISTER_SEL:
        reg_1_out, reg_2_out = await read_registers(dut, reg, reg)
        assert reg_1_out == 0 and reg_2_out == 0, f"Reset failed: Register {reg.name} not zeroed out"


@cocotb.test()
async def test_nop_operation(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset(dut)
    
    test_value = random.randint(0, 2**DATA_BUS_WIDTH - 1)
    await write_register(dut, REGISTER_SEL.REG_A, test_value)
    dut.op.value = REGISTERS_OP.REG_NOP.value
    dut.reg_1_out_sel.value = REGISTER_SEL.REG_A.value
    dut.reg_data_in.value = 0xa
    await RisingEdge(dut.clock)
 
    reg_1_out, _ = await read_registers(dut, REGISTER_SEL.REG_A, REGISTER_SEL.REG_A)
    
    assert reg_1_out == test_value, f"NOP failed: Register A expected {test_value}, got {reg_1_out}"

@cocotb.test()
async def test_concurrent_read_write(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset(dut)
    
    test_value = random.randint(0, 2**DATA_BUS_WIDTH - 1)
    await write_register(dut, REGISTER_SEL.REG_B, test_value)
    reg_1_out, reg_2_out = await read_registers(dut, REGISTER_SEL.REG_B, REGISTER_SEL.REG_C)
    
    assert reg_1_out == test_value and reg_2_out == 0, f"Concurrent Read/Write failed: Register B expected {test_value}, Register C expected 0"

@cocotb.test()
async def test_multi_register_writes(dut):
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    await reset(dut)
    
    test_values = {}
    for reg in REGISTER_SEL:
        test_value = random.randint(0, 2**DATA_BUS_WIDTH - 1)
        test_values[reg] = test_value
        await write_register(dut, reg, test_value)
    
    for reg in REGISTER_SEL:
        reg_1_out, _ = await read_registers(dut, reg, REGISTER_SEL.REG_A)
        assert reg_1_out == test_values[reg], f"Multi-register write failed: Register {reg.name} expected {test_values[reg]}, got {reg_1_out}"

