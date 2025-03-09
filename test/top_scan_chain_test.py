import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, RisingEdge, Timer
from cocotb.result import TestSuccess, TestFailure
import random
from lib.scan_chain import ScanPattern, scan_pattern_from_array

def pattern_from_array(pattern): 
  return scan_pattern_from_array(pattern.bin()
                                  ).bin()

@cocotb.test()
async def is_scan_pattern_implemented_correctly(_):

  pattern = ScanPattern()
  assert sum(pattern.bin()) == 0, f"Pattern {pattern.bin()} != 0"
  assert sum(scan_pattern_from_array(pattern.bin()).bin()) == 0, f"Pattern {pattern.bin()} != 0"  

  for i in range(4):
    pattern = ScanPattern()
    pattern.set_register(i, 255)

    test_pattern = pattern_from_array(pattern)
    assert pattern.bin() == test_pattern, f"Pattern for reg {i} {pattern.bin()} != {test_pattern}"

  for i in range(8):
    pattern = ScanPattern()
    pattern.set_bank_register(i, 255)

    test_pattern = pattern_from_array(pattern)
    assert pattern.bin() == test_pattern, f"Pattern for bank reg {i} {pattern.bin()} != {test_pattern}"

  for i in range(2):
    pattern = ScanPattern()
    pattern.set_addr(i, 255)

    test_pattern = pattern_from_array(pattern)
    assert pattern.bin() == test_pattern, f"Pattern for addr_reg {i} {pattern.bin()} != {test_pattern}"

  pattern = ScanPattern()
  pattern.set_mem_ctrl_state(3)

  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for mem_ctrl_state {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_op_done_out(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for op_done_out {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_start_read(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for start_read {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_start_write(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for start_write {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_stall_txn(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for stall_txn {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_stop_txn(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for stop_txn {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_bus_data_out(255)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for bus_data_out {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_data_out(255)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for data_out {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_ctrl_state(15)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for ctrl_state {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_mem_ctrl_op(3)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for mem_ctrl_op {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_addr_reg_op(7)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for addr_reg_op {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_addr_sel(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for addr_sel {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_alu_op(15)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for alu_op {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_reg_op(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for reg_op {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_reg_sel_in(3)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for reg_sel_in {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_reg_sel_1(3)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for reg_sel_1 {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_reg_sel_2(3)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for reg_sel_2 {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_mux_sel(3)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for mux_sel {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_jmp_op_addr_sel(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for jmp_op_addr_sel {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_flag_zero(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for flag_zero {pattern.bin()} != {test_pattern}"
  pattern = ScanPattern()
  pattern.set_flag_carry(1)
  test_pattern = pattern_from_array(pattern)
  assert pattern.bin() == test_pattern, f"Pattern for flag_carry {pattern.bin()} != {test_pattern}"



@cocotb.test()
async def is_scan_chain_correct_length(dut):
  clock = Clock(dut.clock, 2, units="ns") 
  cocotb.start_soon(clock.start())

  test_pattern_obj = ScanPattern()
  test_pattern = test_pattern_obj.bin()
  # insert 1 before everything else
  test_pattern.insert(0, 1)
  #test_pattern.insert(0, 1)

  dut.test.value = 1
  await RisingEdge(dut.clock)
  dut.reset.value = 0
  await RisingEdge(dut.clock)
  dut.reset.value = 1


  for i in range(len(test_pattern)):
    dut.scan_in.value = test_pattern[i] 
    await RisingEdge(dut.clock)
    if i != len(test_pattern) - 1:
      assert dut.scan_out.value != 1, f"Scan chain is too short: {i} {dut.scan_out.value}" 



  # assert 1 was shifted all the way through
  assert dut.scan_out.value == 1; 


