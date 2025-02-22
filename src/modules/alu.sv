module alu #(parameter DATA_BUS_WIDTH = 8)
(
    input alu_op_e op,
    input logic[DATA_BUS_WIDTH-1:0] register1,
    input logic[DATA_BUS_WIDTH-1:0] register2,
    output logic[DATA_BUS_WIDTH-1:0] result,
    output logic is_zero, 
    output logic is_carry
);

    logic[DATA_BUS_WIDTH:0] tmp;

    always_comb begin
    //Default asignments (make sure that every signal has a value at any time in order to avoid latches)
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
    endcase
    result = tmp[DATA_BUS_WIDTH-1:0];
    
    if (result == 0) 
        is_zero = 1;
  end
endmodule
