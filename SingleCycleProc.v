module singlecycle(
		   input 	     resetl,
		   input [63:0]      startpc,
		   output reg [63:0] currentpc,
		   output [63:0]     MemtoRegOut,  // this should be
						   // attached to the
						   // output of the
						   // MemtoReg Mux
		   input 	     CLK
		   );

   // Next PC connections
   wire [63:0] 			     nextpc;       // The next PC, to be updated on clock cycle

   // Instruction Memory connections
   wire [31:0] 			     instruction;  // The current instruction

   // Parts of instruction
   wire [4:0] 			     rd;            // The destination register
   wire [4:0] 			     rm;            // Operand 1
   wire [4:0] 			     rn;            // Operand 2
   wire [10:0] 			     opcode;
   wire [25:0]               imm;           // SGP added

   // Control wires
   wire 			     reg2loc;
   wire 			     alusrc;
   wire 			     mem2reg;
   wire 			     regwrite;
   wire 			     memread;
   wire 			     memwrite;
   wire 			     branch;
   wire 			     uncond_branch;
   wire [3:0] 			     aluctrl;
   wire [2:0] 			     signop;

   // Register file connections
   wire [63:0] 			     regoutA;     // Output A
   wire [63:0] 			     regoutB;     // Output B

   // ALU connections
   wire [63:0] 			     aluout;
   wire 			     zero;

   // Sign Extender connections
   wire [63:0] 			     extimm;

   // Data Memory connections
   wire [63:0]               ReadData;

   // PC update logic
   always @(negedge CLK)
     begin
        if (resetl)
          currentpc <= #3 nextpc;
        else
          currentpc <= #3 startpc;
     end

   // Parts of instruction
   assign rd = instruction[4:0];
   assign rm = instruction[9:5];
   assign rn = reg2loc ? instruction[4:0] : instruction[20:16];
   assign opcode = instruction[31:21];
   assign imm = instruction[25:0]; // SGP added

   InstructionMemory imem(
			  .Data(instruction),
			  .Address(currentpc)
			  );

   control control(
		   .reg2loc(reg2loc),
		   .alusrc(alusrc),
		   .mem2reg(mem2reg),
		   .regwrite(regwrite),
		   .memread(memread),
		   .memwrite(memwrite),
		   .branch(branch),
		   .uncond_branch(uncond_branch),
		   .aluop(aluctrl),
		   .signop(signop),
		   .opcode(opcode)
		   );

   /*
    * Connect the remaining datapath elements below.
    * Do not forget any additional multiplexers that may be required.
    */
   
   NextPClogic NextPClogic(
       .NextPC(nextpc),
       .CurrentPC(currentpc),
       .SignExtImm64(extimm),
       .Branch(branch),
       .ALUZero(zero),
       .Uncondbranch(uncond_branch)
       );
   
   RegisterFile regfile(
       .BusA(regoutA),
       .BusB(regoutB),
       .BusW(MemtoRegOut),
       .RA(rm),
       .RB(rn),
       .RW(rd),
       .RegWr(regwrite),
       .Clk(CLK)
       );
   
   SignExtender SignExtender(
      .BusImm(extimm),
      .Imm(imm),
      .Ctrl(signop)
      );
   
// ALUSrc Mux
   wire [63:0] alusrcout;
   assign alusrcout = alusrc ? extimm : regoutB;
   
   ALU ALU(
       .BusW(aluout),
       .BusA(regoutA),
       .BusB(alusrcout),
       .ALUCtrl(aluctrl),
       .Zero(zero)
       );
   
   DataMemory DataMemory(
       .ReadData(ReadData),
       .Address(aluout),
       .WriteData(regoutB),
       .MemoryRead(memread),
       .MemoryWrite(memwrite),
       .Clock(CLK)
       );
   
   assign MemtoRegOut = mem2reg ? ReadData : aluout;
endmodule

