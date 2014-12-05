module memAddressCalculator (
  input clk, rst,
  input [15:0] instructionIn,
  input [15:0] opMem,
  output reg [1:0] memControl,
  output reg [15:0] memAddr
);

wire [15:0] imm16sfrom5, imm16sfrom8;
reg [15:0] instruction, rm;

assign imm16sfrom5 = { {11{instruction[4]}}, instruction[4:0]};
assign imm16sfrom8 = { {8{instruction[7]}}, instruction[7:0]};

always @ (negedge clk or negedge rst)
  if (!rst)
  begin
    instruction = 16'b0000100000000000;
    rm = 0;
  end
  else
  begin
    instruction = instructionIn;
    rm = opMem;
  end

always @ (posedge clk or negedge rst)
begin
  memAddr = 16'hFFFF;
  memControl = 2'b00;
  if (!rst)
  begin
    memAddr = 16'hFFFF;
    memControl = 2'b00;
  end
  else
  begin
    case (instruction[15:11])
      5'b10010:                         // lw_sp
      begin
        memAddr = rm + imm16sfrom8;
        memControl = 2'b10; // read
      end
      5'b10011:                         // lw
      begin
        memAddr = rm + imm16sfrom5;
        memControl = 2'b10; // read
      end
      5'b11010:                         // sw_sp
      begin
        memAddr = rm + imm16sfrom8;
        memControl = 2'b01; // write
      end
      5'b11011:                         // sw
      begin
        memAddr = rm + imm16sfrom5;
        memControl = 2'b01; // write
      end
    endcase
  end
end

endmodule
