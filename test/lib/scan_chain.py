# Scan Chain
# REG A-D 4*8 bits
# PC&MAR 2*16 bits
# MEM_CTRL_STATE 2 bits
# op_done_out 1 bit
# start_read 1 bit
# start_write 1 bit
# stall_txn
# stop_txn
# bus_data_out 8 bit
# data_out 8 bit
# CTRL_STATE 4 bits
# MEM_CTRL_OP 2 bits
# ADDR_REG_OP 3 bits
# ADDR_SEL 1 bit
# ALU_OP 4 bits
# REG_OP = 1 bit
# REG_SEL_(in|1|2) 3*2bit
# MUX_SEL 2 bits
# jmp_op_addr_sel 1 bit
# flag_(zero|carry) 2*1bit

from dataclasses import dataclass

from lib.controlpack import ADDR_SEL, ADDRESS_WIDTH, DATA_BUS_WIDTH, REGISTER_SEL, CTRL_STATE, MEM_CTRL_OP, MEM_CTRL_STATE, MUX_SEL, ALU_OP, REGISTERS_OP, ADDR_REG_OP


def variable_to_bin_array(var, length):
    arr = [int(x) for x in bin(var)[2:]]
    if len(arr) > length:
        raise ValueError("Invalid var")

    while len(arr) < length:
        arr.insert(0, 0)

    return arr

def bin_array_to_variable(arr):
    return int("".join(str(x) for x in arr), 2)

def scan_pattern_from_array(array):
    array.reverse()
    pattern = ScanPattern()
    for i in range(4):
        pattern.set_register(i, bin_array_to_variable(array[i*DATA_BUS_WIDTH:(i+1)*DATA_BUS_WIDTH]))
    for i in range(2):
        pattern.set_addr(i, bin_array_to_variable(array[i*ADDRESS_WIDTH:(i+1)*ADDRESS_WIDTH]))
    i = 4*DATA_BUS_WIDTH+2*ADDRESS_WIDTH
    j = pattern._mem_ctrl_state_length
    pattern.set_mem_ctrl_state(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._op_done_out_length
    pattern.set_op_done_out(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._start_read_length
    pattern.set_start_read(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._start_write_length
    pattern.set_start_write(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._stall_txn_length
    pattern.set_stall_txn(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._stop_txn_length
    pattern.set_stop_txn(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._bus_data_out_length
    pattern.set_bus_data_out(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._data_out_length
    pattern.set_data_out(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._ctrl_state_length
    pattern.set_ctrl_state(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._mem_ctrl_op_length
    pattern.set_mem_ctrl_op(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._addr_reg_op_length
    pattern.set_addr_reg_op(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._addr_sel_length
    pattern.set_addr_sel(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._alu_op_length
    pattern.set_alu_op(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._reg_op_length
    pattern.set_reg_op(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._reg_sel_in_length
    pattern.set_reg_sel_in(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._reg_sel_1_length
    pattern.set_reg_sel_1(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._reg_sel_2_length
    pattern.set_reg_sel_2(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._mux_sel_length
    pattern.set_mux_sel(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._jmp_op_addr_sel_length
    pattern.set_jmp_op_addr_sel(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._flag_zero_length
    pattern.set_flag_zero(bin_array_to_variable(array[i:i+j]))
    i += j
    j = pattern._flag_carry_length
    pattern.set_flag_carry(bin_array_to_variable(array[i:i+j]))
    return pattern

@dataclass
class ScanPattern():
    _regs = [0, 0, 0, 0]
    _regs_length = DATA_BUS_WIDTH
    _addrs = [0, 0]
    _addrs_length = ADDRESS_WIDTH
    _mem_ctrl_state = 0
    _mem_ctrl_state_length = 2
    _op_done_out = 0
    _op_done_out_length = 1
    _start_read = 0
    _start_read_length = 1
    _start_write = 0
    _start_write_length = 1
    _stall_txn = 0
    _stall_txn_length = 1
    _stop_txn = 0
    _stop_txn_length = 1
    _bus_data_out = 0
    _bus_data_out_length = 8
    _data_out = 0
    _data_out_length = 8
    _ctrl_state = 0
    _ctrl_state_length = 4
    _mem_ctrl_op = 0
    _mem_ctrl_op_length = 2
    _addr_reg_op = 0
    _addr_reg_op_length = 3
    _addr_sel = 0
    _addr_sel_length = 1
    _alu_op = 0
    _alu_op_length = 4
    _reg_op = 0
    _reg_op_length = 1
    _reg_sel_in = 0
    _reg_sel_in_length = 2
    _reg_sel_1 = 0
    _reg_sel_1_length = 2
    _reg_sel_2 = 0
    _reg_sel_2_length = 2
    _mux_sel = 0
    _mux_sel_length = 2
    _jmp_op_addr_sel = 0
    _jmp_op_addr_sel_length = 1
    _flag_zero = 0
    _flag_zero_length = 1
    _flag_carry = 0
    _flag_carry_length = 1

    def set_register(self, reg_sel: REGISTER_SEL, value):
        self._regs[reg_sel] = value
        return self

    def set_addr(self, addr_sel: ADDR_SEL, value):
        self._addrs[addr_sel] = value
        return self

    def set_mem_ctrl_state(self, value: MEM_CTRL_STATE):
        self._mem_ctrl_state = value
        return self

    def set_op_done_out(self, value):
        self._op_done_out = value
        return self

    def set_start_read(self, value):
        self._start_read = value
        return self

    def set_start_write(self, value):
        self._start_write = value
        return self

    def set_stall_txn(self, value):
        self._stall_txn = value
        return self

    def set_stop_txn(self, value):
        self._stop_txn = value
        return self

    def set_bus_data_out(self, value):
        self._bus_data_out = value
        return self

    def set_data_out(self, value):
        self._data_out = value
        return self

    def set_ctrl_state(self, value: CTRL_STATE):
        self._ctrl_state = value
        return self

    def set_mem_ctrl_op(self, value: MEM_CTRL_OP):
        self._mem_ctrl_op = value
        return self

    def set_addr_reg_op(self, value: ADDR_REG_OP):
        self._addr_reg_op = value
        return self

    def set_addr_sel(self, value: ADDR_SEL):
        self._addr_sel = value
        return self

    def set_alu_op(self, value: ALU_OP):
        self._alu_op = value
        return self

    def set_reg_op(self, value: REGISTERS_OP):
        self._reg_op = value
        return self

    def set_reg_sel_in(self, value: REGISTER_SEL):
        self._reg_sel_in = value
        return self

    def set_reg_sel_1(self, value: REGISTER_SEL):
        self._reg_sel_1 = value
        return self

    def set_reg_sel_2(self, value: REGISTER_SEL):
        self._reg_sel_2 = value
        return self

    def set_mux_sel(self, value: MUX_SEL):
        self._mux_sel = value
        return self

    def set_jmp_op_addr_sel(self, value):
        self._jmp_op_addr_sel = value
        return self

    def set_flag_zero(self, value):
        self._flag_zero = value
        return self

    def set_flag_carry(self, value):
        self._flag_carry = value
        return self

    def bin(self) -> list[int]:
        bin_array = [
            sum([variable_to_bin_array(
                x, self._regs_length) for x in self._regs], []),
            sum([variable_to_bin_array(x, self._addrs_length) for x in self._addrs], []),
            variable_to_bin_array(
                self._mem_ctrl_state,
                self._mem_ctrl_state_length),
            variable_to_bin_array(self._op_done_out, self._op_done_out_length),
            variable_to_bin_array(self._start_read, self._start_read_length),
            variable_to_bin_array(self._start_write, self._start_write_length),
            variable_to_bin_array(self._stall_txn, self._stall_txn_length),
            variable_to_bin_array(self._stop_txn, self._stop_txn_length),
            variable_to_bin_array(
                self._bus_data_out,
                self._bus_data_out_length),
            variable_to_bin_array(self._data_out, self._data_out_length),
            variable_to_bin_array(self._ctrl_state, self._ctrl_state_length),
            variable_to_bin_array(self._mem_ctrl_op, self._mem_ctrl_op_length),
            variable_to_bin_array(self._addr_reg_op, self._addr_reg_op_length),
            variable_to_bin_array(self._addr_sel, self._addr_sel_length),
            variable_to_bin_array(self._alu_op, self._alu_op_length),
            variable_to_bin_array(self._reg_op, self._reg_op_length),
            variable_to_bin_array(self._reg_sel_in, self._reg_sel_in_length),
            variable_to_bin_array(self._reg_sel_1, self._reg_sel_1_length),
            variable_to_bin_array(self._reg_sel_2, self._reg_sel_2_length),
            variable_to_bin_array(self._mux_sel, self._mux_sel_length),
            variable_to_bin_array(
                self._jmp_op_addr_sel,
                self._jmp_op_addr_sel_length),
            variable_to_bin_array(self._flag_zero, self._flag_zero_length),
            variable_to_bin_array(self._flag_carry, self._flag_carry_length)
        ]
        bin_array = sum(bin_array, [])
        bin_array.reverse()
        return bin_array
    
    
