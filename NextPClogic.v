module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch); 
   input [63:0] CurrentPC, SignExtImm64; 
   input 	Branch, ALUZero, Uncondbranch; 
   output reg [63:0] NextPC; 

   wire [63:0] offset = (SignExtImm64 << 2); // Compute the offset

   always @* // Perform the appropriate PC computation
      begin
         if (Uncondbranch) // Unconditional Branch
		 NextPC = CurrentPC + offset;
	 else if (Branch & ALUZero) // Conditional Branch AND Zero
		 NextPC = CurrentPC + offset;
	 else // Default Case
		 NextPC = CurrentPC + 4;
      end
endmodule
