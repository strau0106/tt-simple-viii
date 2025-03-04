import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, RisingEdge, Timer
from cocotb.result import TestSuccess, TestFailure
import random
from lib.scan_chain import ScanPattern

@cocotb.test()
async def is_scan_chain_correct_length(dut):
  clock = Clock(dut.clock, 2, units="ns") 
  cocotb.start_soon(clock.start())

  test_pattern_obj = ScanPattern()
  test_pattern = test_pattern_obj.bin()
  print(test_pattern)
  # insert 1 before everything else
  test_pattern.insert(0, 1)

  dut.reset.value = 0
  await RisingEdge(dut.clock)
  dut.reset.value = 1

  dut.test.value = 1

  for i in range(len(test_pattern)):
    dut.scan_in.value = test_pattern[i] 
    await RisingEdge(dut.clock)



  # assert 1 was shifted all the way through
  assert dut.scan_out.value == 1; 

