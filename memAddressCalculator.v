module memAddressCalculator (
  input clk, rst,
  input [15:0] instructionIn,
  input [15:0] opMem,
  output reg [1:0] memControl,
  output reg [15:0] memAddr
);
parameter 
ADDIU  = 16'b0100100000000000,
ADDIU3 = 16'b0100000000000000,
ADDSP	 = 16'b0110001100000000,
ADDSP3 = 16'b0000000000000000,
ADDU	 = 16'b1110000000000001,
AND	 = 16'b1110100000001100,
B		 = 16'b0001000000000000,
BEQZ	 = 16'b0010000000000000,
BNEZ	 = 16'b0010100000000000,
BTEQZ	 = 16'b0110000000000000,
BTNEZ  = 16'b0110000100000000,
CMP	 = 16'b1110100000001010,
JR	    = 16'b1110100000000000,
LI     = 16'b0110100000000000,
LW	    = 16'b1001100000000000,
LW_SP  = 16'b1001000000000000,
MFIH	 = 16'b1111000000000000,
MFPC	 = 16'b1110100001000000,
MOVE   = 16'b0111100000000000,
MTIH	 = 16'b1111000000000000,
MTSP   = 16'b0110010000000000,
NOP	 = 16'b0000100000000000,
OR		 = 16'b1110100000001101,
SLL	 = 16'b0011000000000000,
SLTI	 = 16'b0101000000000000,
SRA	 = 16'b0011000000000011,
SRL	 = 16'b0011000000000010,
SRLV	 = 16'b1110100000000110,
SUBU	 = 16'b1110000000000011,
SW	 	 = 16'b1101100000000000,
SW_SP	 = 16'b1101000000000000;

localparam
IDLE = 2'b00,
READ = 2'b10,
WRITE = 2'b01;

localparam
LAST_ADDR = 16'hFFFF;
wire [15:0] extend5s, extend8s;
reg [15:0] instruction, rm;

assign extend5s = { {11{instruction[4]}}, instruction[4:0]};
assign extend8s = { {8{instruction[7]}}, instruction[7:0]};

always @ (negedge clk or negedge rst)
  if (!rst)
  begin
    instruction = NOP[15:0];
    rm = 0;
  end
  else
  begin
    instruction = instructionIn;
    rm = opMem;
  end

always @ (posedge clk or negedge rst)
begin
  if (!rst)
  begin
    memAddr = LAST_ADDR;
    memControl = IDLE;
  end
  else if (instruction[15:11] == LW_SP[15:11])
      begin
        memAddr = rm + extend8s;
        memControl = READ;
      end
	else if (instruction[15:11] == LW[15:11])
      begin
        memAddr = rm + extend5s;
        memControl = READ;
      end
	else if (instruction[15:11] == SW_SP[15:11])
      begin
        memAddr = rm + extend8s;
        memControl = WRITE;
      end
	else if (instruction[15:11] == SW[15:11])
      begin
        memAddr = rm + extend5s;
        memControl = WRITE;
      end
end

endmodule


//module memAddressCalculator (
//  input clk, rst,
//  input [15:0] instructionIn,
//  input [15:0] opMem,
//  output reg [1:0] memControl,
//  output reg [15:0] memAddr
//);
//
//wire [15:0] imm16sfrom5, imm16sfrom8;
//reg [15:0] instruction, rm;
//
//assign imm16sfrom5 = { {11{instruction[4]}}, instruction[4:0]};
//assign imm16sfrom8 = { {8{instruction[7]}}, instruction[7:0]};
//
//always @ (negedge clk or negedge rst)
//  if (!rst)
//  begin
//    instruction = 16'b0000100000000000;
//    rm = 0;
//  end
//  else
//  begin
//    instruction = instructionIn;
//    rm = opMem;
//  end
//
//always @ (posedge clk or negedge rst)
//begin
//  memAddr = 16'hFFFF;
//  memControl = 2'b00;
//  if (!rst)
//  begin
//    memAddr = 16'hFFFF;
//    memControl = 2'b00;
//  end
//  else
//  begin
//    case (instruction[15:11])
//      5'b10010:                         // lw_sp
//      begin
//        memAddr = rm + imm16sfrom8;
//        memControl = 2'b10; // read
//      end
//      5'b10011:                         // lw
//      begin
//        memAddr = rm + imm16sfrom5;
//        memControl = 2'b10; // read
//      end
//      5'b11010:                         // sw_sp
//      begin
//        memAddr = rm + imm16sfrom8;
//        memControl = 2'b01; // write
//      end
//      5'b11011:                         // sw
//      begin
//        memAddr = rm + imm16sfrom5;
//        memControl = 2'b01; // write
//      end
//    endcase
//  end
//end
//
//endmodule
