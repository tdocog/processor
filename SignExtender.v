module SignExtender(BusImm, Imm, Ctrl); 
   output [63:0] BusImm; 
   input [25:0]  Imm; 
   input [2:0]	 Ctrl; 
   
   assign BusImm = (Ctrl == 3'b000) ? {{52{1'b0}}, Imm[21:10]} :      // I Type
	           (Ctrl == 3'b001) ? {{55{Imm[20]}}, Imm[20:12]} :   // D Type
		   (Ctrl == 3'b010) ? {{45{Imm[23]}}, Imm[23:5]} :    // CB Type
		   (Ctrl == 3'b011) ? {{38{Imm[25]}}, Imm[25:0]} :    // B Type
	   	   (Ctrl == 3'b100) ? {{46{1'b0}}, Imm[22:5]} :       // IW Type
		   {{64{1'b0}}};

   // I [21:10]
   // D [20:12]
   // CBZ [23:5]
   // B [25:0]
   // IW [20:5], LSL [22:21]

endmodule
