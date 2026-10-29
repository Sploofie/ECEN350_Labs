module SingleCycleProc(
   input             reset,      // Active High
   input  [63:0]     startpc,
   output reg [63:0] currentpc,
   output [63:0]     MemtoRegOut,// output of the MemtoReg Mux
   input             CLK
   );

   // Next PC connections
   wire [63:0] nextpc;          // The next PC, to be updated on clock cycle
   wire [63:0] pcplus4;         // PC + 4
   wire [63:0] branchtarget;    // PC + (imm << 2)
   wire        PCSrc;           // Branch taken?

   // Instruction Memory connections
   wire [31:0] instruction;     // The current instruction

   // Parts of instruction
   wire [4:0]  rd;              // The destination register
   wire [4:0]  rm;              // Operand 1
   wire [4:0]  rn;              // Operand 2
   wire [10:0] opcode;

   // Control wires
   wire        Reg2Loc;
   wire        ALUSrc;
   wire        MemtoReg;
   wire        RegWrite;
   wire        MemRead;
   wire        MemWrite;
   wire        Branch;
   wire        Uncondbranch;
   wire [3:0]  ALUOp;           // (was mis-named ALUop in the skeleton)
   wire [1:0]  SignOp;

   // Register file connections
   wire [63:0] regoutA;         // Output A
   wire [63:0] regoutB;         // Output B

   // ALU connections
   wire [63:0] aluout;
   wire [63:0] alu_b;           // output of the ALUSrc mux
   wire        zero;

   // Sign Extender connections
   wire [63:0] extimm;

   // Data Memory connections
   wire [63:0] memout;

   // PC update logic
   always @(posedge CLK)
     begin
        if (reset)
          currentpc <= #3 startpc;
        else
          currentpc <= #3 nextpc;
     end

   // Parts of instruction
   assign rd     = instruction[4:0];
   assign rm     = instruction[9:5];
   assign rn     = Reg2Loc ? instruction[4:0] : instruction[20:16];
   assign opcode = instruction[31:21];

   InstructionMemory imem(
     .Data(instruction),
     .Address(currentpc)
     );

   control SingleCycleControl(
     .Reg2Loc(Reg2Loc),
     .ALUSrc(ALUSrc),
     .MemtoReg(MemtoReg),
     .RegWrite(RegWrite),
     .MemRead(MemRead),
     .MemWrite(MemWrite),
     .Branch(Branch),
     .Uncondbranch(Uncondbranch),
     .ALUOp(ALUOp),
     .SignOp(SignOp),
     .opcode(opcode)
     );

   /* ---------------- Remaining datapath ---------------- */

   // ---- Register File (Lab 5) ----
   RegisterFile regfile(
     .BusA(regoutA),
     .BusB(regoutB),
     .BusW(MemtoRegOut),   // write-back data comes from the MemtoReg mux
     .RA(rm),
     .RB(rn),
     .RW(rd),
     .RegWr(RegWrite),
     .Clk(CLK)
     );

   // ---- Sign Extender (Lab 6) ----
   SignExtender sext(
     .BusImm(extimm),
     .Imm26(instruction[25:0]),
     .Ctrl(SignOp)
     );

   // ---- ALUSrc Mux: register vs. immediate ----
   assign alu_b = ALUSrc ? extimm : regoutB;

   // ---- ALU (Lab 5) ----
   ALU alu(
     .BusW(aluout),
     .BusA(regoutA),
     .BusB(alu_b),
     .ALUCtrl(ALUOp),
     .Zero(zero)
     );

   // ---- Data Memory ----
   DataMemory dmem(
     .ReadData(memout),
     .Address(aluout),
     .WriteData(regoutB),  // STUR data always comes from BusB (Reg2Loc = 1)
     .MemoryRead(MemRead),
     .MemoryWrite(MemWrite),
     .Clock(CLK)
     );

   // ---- MemtoReg Mux (module output) ----
   assign MemtoRegOut = MemtoReg ? memout : aluout;

   // ---- Next PC logic ----
   assign pcplus4      = currentpc + 64'd4;
   assign branchtarget = currentpc + (extimm << 2);

   // Take the branch for B (Uncondbranch) or for CBZ when Zero is asserted
   assign PCSrc  = Uncondbranch | (Branch & zero);
   assign nextpc = PCSrc ? branchtarget : pcplus4;

endmodule
