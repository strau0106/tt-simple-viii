class Instruction():
  def __init__(self):
    pass



class LDX(Instruction):
  LDX_OP_CODE = 0b10
  _ldxop = 0
  _ldxop_len = 2
  _sel = 0
  _sel_len = 2
  _use_register_bank = 0
  _use_register_bank_len = 1
  _immediate_value = 0
  _immediate_value_len = 8
  
  def set_ldxop(self, ldxop):
    self._ldxop = ldxop.value
    return self

  def set_sel(self, reg_sel):
    self._sel = reg_sel.value
    return self

  def set_use_register_bank(self, value):
    self._use_register_bank = value
    return self

  def set_immediate_value(self, value):
    self._immediate_value = value
    return self

  def to_hex(self):
    return hex((self.LDX_OP_CODE << 6) | (self._ldxop << 4) | (self._sel << 2) | (self._use_register_bank << 1))[2:] + " " + hex(self._immediate_value)[2:]
  

class AOP(Instruction):
  AOP_OP_CODE = 0b01
  _op = 0
  _op_len = 4
  _sel_1 = 0
  _sel_1_len = 2
  _sel_2 = 0
  _sel_2_len = 2
  _sel_in = 0
  _sel_in_len = 2
  _use_register_bank_in = 0
  _use_register_bank_len = 1
  _use_register_bank_out = 0
  _use_register_bank_out_len = 1

  def set_op(self, op):
    self._op = op.value
    return self
  
  def set_sel_1(self, reg_sel):
    self._sel_1 = reg_sel.value
    return self

  def set_sel_2(self, reg_sel):
    self._sel_2 = reg_sel.value
    return self

  def set_sel_in(self, reg_sel):
    self._sel_in = reg_sel.value
    return self

  def set_use_register_bank_in(self, value):
    self._use_register_bank_in = value
    return self

  def set_use_register_bank_out(self, value):
    self._use_register_bank_out = value
    return self

  def to_hex(self):
    return hex((self.AOP_OP_CODE << 6) | (self._op << 2) | (self._sel_1))[2:] + " " + hex((self._sel_2 << 6) | (self._sel_in << 4) | 
               (self._use_register_bank_in << 3) | (self._use_register_bank_out << 2))[2:]
  

class NOP(Instruction):

  def to_hex(self):
    return hex(0)[2:]
  
class JMP(Instruction):
  JMP_OP_CODE = 0b11
  _carry = 0
  _carry_len = 1
  _zero = 0
  _zero_len = 1
  _sel_1 = 0
  _sel_1_len = 2
  _ar_sel = 0
  _ar_sel_len = 1
  _use_register_bank = 0
  _use_register_bank_len = 1
  _ar_op = 0
  _ar_op_len = 3

  def set_carry(self, value):
    self._carry = value
    return self
  
  def set_zero(self, value):
    self._zero = value
    return self

  def set_sel_1(self, reg_sel):
    self._sel_1 = reg_sel.value
    return self

  def set_ar_sel(self, ar_sel):
    self._ar_sel = ar_sel.value
    return self

  def set_use_register_bank(self, op):
    self._use_register_bank = op.value
    return self

  def set_ar_op(self, ar_op):
    self._ar_op = ar_op.value
    return self

  def to_hex(self):
    return hex((self.JMP_OP_CODE << 6) | (self._carry << 5) | (self._zero << 4) | (self._sel_1 << 2) | 
               (self._ar_sel << 1) | self._use_register_bank)[2:] + " " + hex(self._ar_op << 5)[2:] 