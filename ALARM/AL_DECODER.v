// AL_DECODER.v

module AL_DECODER(
	BCD, SEG_DOT,
	SEG_DATA, 
);

input [3:0] BCD;
input wire SEG_DOT;
output wire [7:0] SEG_DATA;

reg [6:0] BUFF;

always @(BCD)
begin
	case (BCD)
		4'b0000 : BUFF = 7'b1111110; // 0
		4'b0001 : BUFF = 7'b0110000;  //1 
		4'b0010 : BUFF = 7'b1101101;  //2 
		4'b0011 : BUFF = 7'b1111001;  //3 
		4'b0100 : BUFF = 7'b0110011;  //4 
		4'b0101 : BUFF = 7'b1011011;  //5 
		4'b0110 : BUFF = 7'b1011111;  //6 
		4'b0111 : BUFF = 7'b1110000;  //7 
		4'b1000 : BUFF = 7'b1111111;  //8 
		4'b1001 : BUFF = 7'b1111011;  //9 
		default : BUFF = 7'b0000000;  //NULL 
	endcase
end	

assign SEG_DATA = {BUFF, SEG_DOT};

endmodule