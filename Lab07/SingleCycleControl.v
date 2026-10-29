`define OPCODE_ANDREG 11'b10001010000
`define OPCODE_ORRREG 11'b10101010000
`define OPCODE_ADDREG 11'b10001011000
`define OPCODE_SUBREG 11'b11001011000

`define OPCODE_ADDIMM 11'b1001000100?
`define OPCODE_SUBIMM 11'b1101000100?

`define OPCODE_MOVZ   11'b110100101??

`define OPCODE_B      11'b000101?????
`define OPCODE_CBZ    11'b10110100???

`define OPCODE_LDUR   11'b11111000010
`define OPCODE_STUR   11'b11111000000

module SC_Control(
    output reg       Reg2Loc,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Uncondbranch,
    output reg [3:0] ALUOp,
    output reg [1:0] SignOp,
    input      [10:0] opcode
);

    // ALUOp encodings (assumed from earlier labs)
    localparam [3:0] ALU_AND   = 4'b0000,
                     ALU_ORR   = 4'b0001,
                     ALU_ADD   = 4'b0010,
                     ALU_SUB   = 4'b0110,
                     ALU_PASSB = 4'b0111;

    // SignOp encodings (assumed from earlier labs)
    localparam [1:0] SIGN_I   = 2'b00,
                     SIGN_D   = 2'b01,
                     SIGN_B   = 2'b10,
                     SIGN_CBZ = 2'b11;

    always @(*) begin
        casez (opcode)
            //            R2L  ALUSrc MtoR  RegW  MRd   MWr   Br    Uncond ALUOp      SignOp
            `OPCODE_ANDREG: {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'b0,  1'b0,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_AND,   SIGN_I};
            `OPCODE_ORRREG: {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'b0,  1'b0,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_ORR,   SIGN_I};
            `OPCODE_ADDREG: {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'b0,  1'b0,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_ADD,   SIGN_I};
            `OPCODE_SUBREG: {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'b0,  1'b0,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_SUB,   SIGN_I};

            `OPCODE_ADDIMM: {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'bx,  1'b1,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_ADD,   SIGN_I};
            `OPCODE_SUBIMM: {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'bx,  1'b1,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_SUB,   SIGN_I};

            `OPCODE_MOVZ:   {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'bx,  1'b1,  1'b0,  1'b1, 1'b0, 1'b0, 1'b0, 1'b0, ALU_PASSB, SIGN_I};

            `OPCODE_LDUR:   {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'bx,  1'b1,  1'b1,  1'b1, 1'b1, 1'b0, 1'b0, 1'b0, ALU_ADD,   SIGN_D};
            `OPCODE_STUR:   {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'b1,  1'b1,  1'bx,  1'b0, 1'b0, 1'b1, 1'b0, 1'b0, ALU_ADD,   SIGN_D};

            `OPCODE_CBZ:    {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'b1,  1'b0,  1'bx,  1'b0, 1'b0, 1'b0, 1'b1, 1'b0, ALU_PASSB, SIGN_CBZ};
            `OPCODE_B:      {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = {1'bx,  1'bx,  1'bx,  1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 4'bx,      SIGN_B};

            // Undefined opcodes: all control bits 0
            default:        {Reg2Loc,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,Uncondbranch,ALUOp,SignOp}
                          = 14'b0;
        endcase
    end
endmodule
