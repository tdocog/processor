`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111
`define MOVZ  4'b0011

module ALU(BusW, BusA, BusB, ALUCtrl, Zero);
    
    output  [63:0] BusW;
    input   [63:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    output  Zero;
    
    reg     [63:0] BusW;
    
    always @(ALUCtrl or BusA or BusB) begin
        case(ALUCtrl)
            `AND: begin
                BusW = BusA & BusB;
            end
	    `OR: begin
		BusW = BusA | BusB;
	    end
	    `ADD: begin
		BusW = BusA + BusB;
	    end
	    `SUB: begin
		BusW = BusA - BusB;
	    end
	    `PassB: begin
		BusW = BusB;
	    end
        
        `MOVZ: begin
           case(BusB[17:16])
              2'b00: begin
                 BusW = {{48{1'b0}}, BusB[15:0]};
              end
              2'b01: begin
                 BusW = {{32{1'b0}}, BusB[15:0], {16{1'b0}}};
              end
              2'b10: begin
                 BusW = {{16{1'b0}}, BusB[15:0], {32{1'b0}}};
              end
              2'b11: begin
                 BusW = {BusB[15:0], {48{1'b0}}};
              end
           endcase
        end
        endcase
    end

    assign Zero = (BusW == 64'b0);
endmodule
