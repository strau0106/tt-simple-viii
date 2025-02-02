// Section 1.3.1: Arithmetic Logic Unit
import controlpack ::*;

module alu #(parameter DATA_BUS_WIDTH = 8)
(
    input alu_op_e op,
    input logic[DATA_BUS_WIDTH-1:0] register1,
    input logic[DATA_BUS_WIDTH-1:0] register2,
    output logic[DATA_BUS_WIDTH-1:0] result,
    output alu_flag_t flag
);

    logic[DATA_BUS_WIDTH:0] tmp;
    logic is_zero;
    logic is_carry;

    always @ (register1 or register2 or op or is_carry or is_zero or tmp or result) begin
    //Default asignments (make sure that every signal has a value at any time in order to avoid latches)
    flag.alu_carry = 0;
    flag.alu_zero = 0;
    tmp = 0;
    is_carry = 0;
    is_zero = 0;
    result = 0;
    //do the ALU magic...
    case (op)
      default:
        ;
      THR:
        begin
          tmp = {1'b0, register1}; //feedthrough
        end
      ADD:
        begin
          tmp = {1'b0, register1} + register2;
          is_carry = tmp[DATA_BUS_WIDTH];
        end
      SUB:
        begin
          tmp = {1'b0, register1} - register2;
          is_carry = tmp[DATA_BUS_WIDTH];
        end
      SHL:
        begin
          tmp = {1'b0, register1} << 1;
          is_carry = tmp[DATA_BUS_WIDTH]; 
        end
      ROL: 
        begin
          tmp = {1'b0, register1[DATA_BUS_WIDTH-2:0], register1[DATA_BUS_WIDTH-1]};        
          is_carry = 0;
        end
      SHR:
        begin
          tmp = {1'b0, register1} >> 1;        
          is_carry = register1[0];
        end
      ROR:
        begin
          tmp = {1'b0, register1[0:0], register1[DATA_BUS_WIDTH-1:1]};        
          is_carry = 0;
        end
      AND:
        begin
          tmp = {1'b0, register1 & register2};        
          is_carry = 0;
        end
      OR:
        begin
          tmp = {1'b0, register1 | register2};        
          is_carry = 0;
        end
      XOR:
        begin
          tmp = {1'b0, register1 ^ register2};        
          is_carry = 0;
        end
      NOT:
        begin
          tmp = {1'b0, ~register1};        
          is_carry = 0;
        end
      INC1:
        begin                          //used for PC after 1 Byte instructions
          tmp = {1'b0, register1} + 1;         
          is_carry = tmp[DATA_BUS_WIDTH];
        end
      INC2:
        begin                          //used for PC after 2 Byte instructions
          tmp = {1'b0, register1} + 2;        
          is_carry = tmp[DATA_BUS_WIDTH];
        end
      INC3:
        begin                          //used for PC after 3 Byte instructions
          tmp = {1'b0, register1} + 3;        
          is_carry = tmp[DATA_BUS_WIDTH];
        end
    endcase
    result = tmp[DATA_BUS_WIDTH-1:0];
    
    if (result == 0) 
    begin
      if (!(op == NOP)) 
        is_zero = 1;
    end
    flag.alu_carry = is_carry;
    flag.alu_zero = is_zero;
  end
endmodule
