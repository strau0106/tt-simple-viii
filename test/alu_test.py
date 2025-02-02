import cocotb
import pytest
from controlpack import ALU_OP
from utils import advance_sim
from collections import namedtuple

Param = namedtuple('Param', ["op", "reg1", "reg2", "expected_result", "expected_carry", "expected_zero"])
@cocotb.test()
async def test_turing_req_2111_add(dut):
    
    params = [  
    Param(0, 0, 0, 0, 0, 1), # Zero
    Param(0, 3, 2, 5, 0, 0), # Basic functionality
    Param(0, 255, 1, 0, 1, 1), # Roll over, carry flag, zero flag
    Param(0, 255, 2, 1, 1, 0) # Roll over, carry flag
    ]
    for param in params:

        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = ALU_OP.ADD.value  # Assuming ADD is encoded as 0

        await advance_sim(dut)
        assert dut.result.value == param.expected_result
        assert dut.flag.value == (param.expected_zero << 1) + param.expected_carry
        
@cocotb.test()
async def test_feature_req_2111_sub(dut):    
    params = [
        Param(0, 0, 0, 0, 0, 1),  # Zero
        Param(0, 5, 3, 2, 0, 0),  # Basic functionality
        Param(0, 0, 1, 255, 1, 0),  # Borrow, carry flag
        Param(0, 1, 1, 0, 0, 1)  # Result zero, zero flag
    ]
    for param in params:
        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = ALU_OP.SUB.value  # Assuming SUB is encoded as 1

        await advance_sim(dut)
        assert dut.result.value == param.expected_result
        assert dut.flag.value == (param.expected_zero << 1) + param.expected_carry

@cocotb.test()
async def test_feature_req_2114_logic(dut):
    params = [
        # AND operation
        Param(ALU_OP.AND.value, 0b01010111, 0b00110010, 0b00010010, 0, 0),  # Basic functionality
        Param(ALU_OP.AND.value, 0b11111111, 0b00000000, 0b00000000, 0, 1),  # Zero result
        Param(ALU_OP.AND.value, 0b11111111, 0b11111111, 0b11111111, 0, 0),  # All bits set

        # OR operation
        Param(ALU_OP.OR.value, 0b01010111, 0b00110010, 0b01110111, 0, 0),  # Basic functionality
        Param(ALU_OP.OR.value, 0b00000000, 0b00000000, 0b00000000, 0, 1),  # Zero result
        Param(ALU_OP.OR.value, 0b11111111, 0b00000000, 0b11111111, 0, 0),  # One operand all bits set

        # XOR operation
        Param(ALU_OP.XOR.value, 0b01010111, 0b00110010, 0b01100101, 0, 0),  # Basic functionality
        Param(ALU_OP.XOR.value, 0b00000000, 0b00000000, 0b00000000, 0, 1),  # Zero result
        Param(ALU_OP.XOR.value, 0b11111111, 0b11111111, 0b00000000, 0, 1),  # All bits set, zero result

        # NOT operation
        Param(ALU_OP.NOT.value, 0b10101010, 0, 0b01010101, 0, 0),  # Basic functionality
        Param(ALU_OP.NOT.value, 0b00000000, 0, 0b11111111, 0, 0),  # Zero input
        Param(ALU_OP.NOT.value, 0b11111111, 0, 0b00000000, 0, 1),  # All bits set, zero result
    ]

    for param in params:
        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = param.op

        await advance_sim(dut)
        assert dut.result.value == param.expected_result
        assert dut.flag.value == (param.expected_zero << 1) + param.expected_carry

@cocotb.test()
async def test_feature_req_2115_shift(dut):
    params = [
        # ROR operation
        Param(ALU_OP.ROR.value, 0b00000001, 0, 0b10000000, 0, 0),  # Rotate right
        Param(ALU_OP.ROR.value, 0b10000001, 0, 0b11000000, 0, 0),  # Rotate right with carry
        Param(ALU_OP.ROR.value, 0b00000000, 0, 0b00000000, 0, 1),  # Zero input

        # ROL operation
        Param(ALU_OP.ROL.value, 0b10000000, 0, 0b00000001, 0, 0),  # Rotate left
        Param(ALU_OP.ROL.value, 0b11000000, 0, 0b10000001, 0, 0),  # Rotate left with carry
        Param(ALU_OP.ROL.value, 0b00000000, 0, 0b00000000, 0, 1),  # Zero input

        # SHR operation
        Param(ALU_OP.SHR.value, 0b00000010, 0, 0b00000001, 0, 0),  # Shift right
        Param(ALU_OP.SHR.value, 0b00000001, 0, 0b00000000, 1, 1),  # Shift right to zero
        Param(ALU_OP.SHR.value, 0b00000000, 0, 0b00000000, 0, 1),  # Zero input

        # SHL operation
        Param(ALU_OP.SHL.value, 0b00000001, 0, 0b00000010, 0, 0),  # Shift left
        Param(ALU_OP.SHL.value, 0b10000000, 0, 0b00000000, 1, 1),  # Shift left with carry
        Param(ALU_OP.SHL.value, 0b00000000, 0, 0b00000000, 0, 1),  # Zero input
    ]

    for param in params:
        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = param.op

        await advance_sim(dut)
        assert dut.result.value == param.expected_result
        assert dut.flag.value == (param.expected_zero << 1) + param.expected_carry
