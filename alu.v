module alu(
  input clk, rst,
  input[15:0] opXin, opYin,
  input[15:0] currentPCIn, instructionIn,
  output reg[15:0] res,
  output reg t_written, t
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

reg [15:0] currentPC, instruction, opX, opY;

always @ (negedge clk or negedge rst)
begin 
  if (!rst)
  begin
    currentPC = 0;
	 instruction = NOP[15:0];
	 opX = 0;
	 opY = 0;
  end
  else
  begin
    currentPC = currentPCIn;
	 instruction = instructionIn;
	 opX = opXin;
	 opY = opYin;
  end
end

wire[15:0] extend8u = {8'b00000000, instruction[7:0]};
wire[15:0] extend8s = { {8{instruction[7]}}, instruction[7:0]};
wire[15:0] extend4s = { {12{instruction[3]}}, instruction[3:0]};

wire[3:0] shiftimm = instruction[4:2] ? instruction[4:2] : 8;

always @(posedge clk or negedge rst)
begin
  if (!rst) 
  begin
    t_written = 1;
    t = 0;
    res = 0;
  end
  else
  begin
    case (instruction[15:11])
      ADDSP3[15:11]:
        res = opX + extend8s;
	   ADDIU3[15:11]:
        res = opX + extend4s;
      ADDIU[15:11]:
        res = opX + extend8s;
      SHIFTS[15:11]:
        case (instruction[1:0])
          SLL[1:0]:   
			res = opX << shiftimm;
          SRL[1:0]:   
			res = opX >> shiftimm;
          SRA[1:0]:   
			res = opX >>> shiftimm;
        endcase
      SLTI[15:11]:
      begin
        t_written = 0;
        t = $signed(opX) < extend8s;
      end
      ADDSP[15:11]:
        case (instruction[10:8])
          ADDSP[10:8]:
            res = opX + extend8s;
          MTSP[10:8]:
            res = opX;
        endcase
      LI[15:11]:
        res = extend8u;
      MOVE[15:11]:
        res = opX;
      SW_SP[15:11]:
        res = opX;
      SW[15:11]:
        res = opX;
      ADDU[15:11]:
        case (instruction[1:0])
          ADDU[1:0]:   
			res = opX + opY;
          SUBU[1:0]:   
			res = opX - opY;
        endcase
      MIH[15:11]:                       
        case (instruction[1:0])
          MFIH[1:0]:
            res = opX;
          MTIH[1:0]:
            res = opX;
        endcase
	  MFPC[15:11]:                         
        case (instruction[4:0])
          MFPC[4:0]:                     
            case (instruction[7:5])
              MFPC[7:5]:
                res = currentPC;
            endcase
          SLT[4:0]:
          begin
            t_written = 0;
            t = $signed(opX) < $signed(opY);
          end
          SRLV[4:0]:
            res = opX >> opY;
          SRAV[4:0]:
            res = opX >>> opY;
          CMP[4:0]:
          begin
            t_written = 0;
            t = opX != opY;
          end
          AND[4:0]:
            res = opX & opY;
          OR[4:0]:
            res = opX | opY;
        endcase
    endcase
  end
end

endmodule


//module alu(
//  input clk, rst,
//  input[15:0] opXin, opYin,
//  input[15:0] currentPCIn, instructionIn,
//  output reg[15:0] res,
//  output reg t_written, t
//);
//
//reg [15:0] currentPC, instruction, opX, opY;
//
//wire[15:0] imm16 = {8'd0, instruction[7:0]};
//wire[15:0] imm16s = { {8{instruction[7]}}, instruction[7:0]};
//wire[15:0] imm16from4s = { {12{instruction[3]}}, instruction[3:0]};
//wire[3:0] shift_imm4 = instruction[4:2] ? instruction[4:2] : 8;
//
//always @ (negedge clk or negedge rst)
//begin
//  if (!rst)
//  begin
//    currentPC = 0;
//	 instruction = 16'b0000100000000000; // nop
//	 opX = 0;
//	 opY = 0;
//  end
//  else
//  begin
//    currentPC = currentPCIn;
//	 instruction = instructionIn;
//	 opX = opXin;
//	 opY = opYin;
//  end
//end
//
//always @(posedge clk or negedge rst)
//begin
//  t_written = 1;
//  t = 0;
//  res = 0;
//  if (!rst) // the negedge of rst
//  begin
//    t_written = 1;
//    t = 0;
//    res = 0;
//  end
//  else
//  begin
//    case (instruction[15:11])
//      5'b00000:                         // addsp3
//        res = opX + imm16s;
//      5'b00110:                         // sll, srl, sra
//        case (instruction[1:0])
//          2'b00:   res = opX << shift_imm4;  // sll
//          2'b10:   res = opX >> shift_imm4;  // srl
//          2'b11:   res = opX >>> shift_imm4; // sra
//        endcase
//      5'b01000:                         // addiu3
//        res = opX + imm16from4s;
//      5'b01001:                         // addiu
//        res = opX + imm16s;
//      5'b01010:                         // slti
//      begin
//        t_written = 0;
//        t = $signed(opX) < imm16s;
//      end
//      5'b01100:                         // addsp, bteqz, btnez, mtsp
//        case (instruction[10:8])
//          3'b011:                       // addsp
//            res = opX + imm16s;
//          3'b100:                       // mtsp
//            res = opX;
//        endcase
//      5'b01101:                         // li
//        res = imm16;
//      5'b01111:                         // move
//        res = opX;
//      5'b11010:                         // sw_sp
//        res = opX;
//      5'b11011:                         // sw
//        res = opX;
//      5'b11100:                         // addu, subu
//        case (instruction[1:0])
//          2'b01:   res = opX + opY;           // addu
//          2'b11:   res = opX - opY;           // subu
//        endcase
//      5'b11101:                         //  jr, mfpc, srav, srlv, cmp, and, or
//        case (instruction[4:0])
//          5'b00000:                     // jr, mfpc
//            case (instruction[7:5])
//              //3'b000:                   // jr
//              3'b010:                   // mfpc
//                res = currentPC;
//            endcase
//          5'b00010:                     // slt
//          begin
//            t_written = 0;
//            t = $signed(opX) < $signed(opY);
//          end
//          5'b00110:                     // srlv
//            res = opX >> opY;
//          5'b00111:                     // srav
//            res = opX >>> opY;
//          5'b01010:                     // cmp
//          begin
//            t_written = 0;
//            t = opX != opY;
//          end
//          5'b01100:                     // and
//            res = opX & opY;
//          5'b01101:                     // or
//            res = opX | opY;
//        endcase
//      5'b11110:                         // mfih, mtih
//        case (instruction[0])
//          1'b0:                         // mfih
//            res = opX;
//          1'b1:                         // mtih
//            res = opX;
//        endcase
//    endcase
//  end
//end
//
//endmodule
