// AL_SEP.v

module AL_SEP(
	NUMBER,
	SEP_A, SEP_B
);

input [6:0] NUMBER;
output reg [3:0] SEP_A, SEP_B;

always @(NUMBER)
begin
	SEP_A = NUMBER / 10;
	SEP_B = NUMBER % 10;
end

endmodule