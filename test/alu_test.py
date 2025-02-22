import cocotb
import pytest
from controlpack import ALU_OP
from utils import advance_sim
from collections import namedtuple

Param = namedtuple('Param', ["op", "reg1", "reg2", "expected_result", "expected_carry", "expected_zero", "test_name"])

@cocotb.test()
async def test_turing_req_2111_arithmetics(dut):
    params = [
        Param(ALU_OP.ADD, 0, 0, 0, 0, 1, "Zero"),  # Zero
        Param(ALU_OP.ADD, 3, 2, 5, 0, 0, "Basic functionality"),  # Basic functionality
        Param(ALU_OP.ADD, 255, 1, 0, 1, 1, "Roll over, carry flag, zero flag"),  # Roll over, carry flag, zero flag
        Param(ALU_OP.ADD, 255, 2, 1, 1, 0, "Roll over, carry flag"),  # Roll over, carry flag

        Param(ALU_OP.SUB, 0, 0, 0, 0, 1, "Zero"),  # Zero
        Param(ALU_OP.SUB, 5, 3, 2, 0, 0, "Basic functionality"),  # Basic functionality
        Param(ALU_OP.SUB, 0, 1, 255, 1, 0, "Borrow, carry flag"),  # Borrow, carry flag
        Param(ALU_OP.SUB, 1, 1, 0, 0, 1, "Result zero, zero flag")  # Result zero, zero flag
    ]
    for param in params:
        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = param.op.value  # Assuming ADD is encoded as 0

        await advance_sim(dut)
        assert dut.result.value == param.expected_result, f"Failed: {param.test_name}"
        assert dut.is_zero.value == param.expected_zero, f"Failed: {param.test_name}"
        assert dut.is_carry.value == param.expected_carry, f"Failed: {param.test_name}"

@cocotb.test()
async def test_feature_req_2114_logic(dut):
    params = [
        # AND operation
        Param(ALU_OP.AND, 0b01010111, 0b00110010, 0b00010010, 0, 0, "AND Basic functionality"),  # Basic functionality
        Param(ALU_OP.AND, 0b11111111, 0b00000000, 0b00000000, 0, 1, "AND Zero result"),  # Zero result
        Param(ALU_OP.AND, 0b11111111, 0b11111111, 0b11111111, 0, 0, "AND All bits set"),  # All bits set

        # OR operation
        Param(ALU_OP.OR, 0b01010111, 0b00110010, 0b01110111, 0, 0, "OR Basic functionality"),  # Basic functionality
        Param(ALU_OP.OR, 0b00000000, 0b00000000, 0b00000000, 0, 1, "OR Zero result"),  # Zero result
        Param(ALU_OP.OR, 0b11111111, 0b00000000, 0b11111111, 0, 0, "OR One operand all bits set"),  # One operand all bits set

        # XOR operation
        Param(ALU_OP.XOR, 0b01010111, 0b00110010, 0b01100101, 0, 0, "XOR Basic functionality"),  # Basic functionality
        Param(ALU_OP.XOR, 0b00000000, 0b00000000, 0b00000000, 0, 1, "XOR Zero result"),  # Zero result
        Param(ALU_OP.XOR, 0b11111111, 0b11111111, 0b00000000, 0, 1, "XOR All bits set, zero result"),  # All bits set, zero result

        # NOT operation
        Param(ALU_OP.NOT, 0b10101010, 0, 0b01010101, 0, 0, "NOT Basic functionality"),  # Basic functionality
        Param(ALU_OP.NOT, 0b00000000, 0, 0b11111111, 0, 0, "NOT Zero input"),  # Zero input
        Param(ALU_OP.NOT, 0b11111111, 0, 0b00000000, 0, 1, "NOT All bits set, zero result"),  # All bits set, zero result
    ]

    for param in params:
        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = param.op.value

        await advance_sim(dut)
        assert dut.result.value == param.expected_result, f"Failed: {param.test_name}"
        assert dut.is_zero.value == param.expected_zero, f"Failed: {param.test_name}"
        assert dut.is_carry.value == param.expected_carry, f"Failed: {param.test_name}"

@cocotb.test()
async def test_feature_req_2115_shift(dut):
    params = [
        # ROR operation
        Param(ALU_OP.ROR, 0b00000001, 0, 0b10000000, 0, 0, "ROR Rotate right"),  # Rotate right
        Param(ALU_OP.ROR, 0b10000001, 0, 0b11000000, 0, 0, "ROR Rotate right with carry"),  # Rotate right with carry
        Param(ALU_OP.ROR, 0b00000000, 0, 0b00000000, 0, 1, "ROR Zero input"),  # Zero input

        # ROL operation
        Param(ALU_OP.ROL, 0b10000000, 0, 0b00000001, 0, 0, "ROL Rotate left"),  # Rotate left
        Param(ALU_OP.ROL, 0b11000000, 0, 0b10000001, 0, 0, "ROL Rotate left with carry"),  # Rotate left with carry
        Param(ALU_OP.ROL, 0b00000000, 0, 0b00000000, 0, 1, "ROL Zero input"),  # Zero input

        # SHR operation
        Param(ALU_OP.SHR, 0b00000010, 0, 0b00000001, 0, 0, "SHR Shift right"),  # Shift right
        Param(ALU_OP.SHR, 0b00000001, 0, 0b00000000, 1, 1, "SHR Shift right to zero"),  # Shift right to zero
        Param(ALU_OP.SHR, 0b00000000, 0, 0b00000000, 0, 1, "SHR Zero input"),  # Zero input

        # SHL operation
        Param(ALU_OP.SHL, 0b00000001, 0, 0b00000010, 0, 0, "SHL Shift left"),  # Shift left
        Param(ALU_OP.SHL, 0b10000000, 0, 0b00000000, 1, 1, "SHL Shift left with carry"),  # Shift left with carry
        Param(ALU_OP.SHL, 0b00000000, 0, 0b00000000, 0, 1, "SHL Zero input"),  # Zero input
    ]

    for param in params:
        dut.register1.value = param.reg1
        dut.register2.value = param.reg2
        dut.op.value = param.op.value

        await advance_sim(dut)
        assert dut.result.value == param.expected_result, f"Failed: {param.test_name}"
        assert dut.is_zero.value == param.expected_zero, f"Failed: {param.test_name}"
        assert dut.is_carry.value == param.expected_carry, f"Failed: {param.test_name}"
