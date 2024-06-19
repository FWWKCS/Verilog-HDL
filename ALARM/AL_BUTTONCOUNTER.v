// AL_BUTTONCOUNTER.v

module AL_BUTTONCOUNTER(
	CLK, BTN_INC, BTN_DEC, BTN_SET, 
	count, setFlag, targetFlag, prev_SET,
	tmp
);

input CLK, BTN_DEC, BTN_INC, BTN_SET; 
input setFlag, targetFlag, prev_SET;
input [6:0] count;

output [6:0] tmp;

integer btn_clock = 0; // if you press dec/inc button, time count
reg try_dec = 1'b0; // do decrese
reg try_inc = 1'b0; // do increse
reg count_change = 1'b0; // detects when you release the button too quickly

reg [6:0] internal_count;

always @(posedge CLK) 
begin
	if (~BTN_DEC & ~BTN_INC) btn_clock = 0;
	else 
	begin
		if (btn_clock > 250000) btn_clock = 0;
		else btn_clock = btn_clock + 1;
	end
end

always @(posedge CLK)
begin
	if (~setFlag && BTN_SET && ~prev_SET) internal_count = 0;
	else internal_count = count;

	if (setFlag && targetFlag) 
	begin
		if (BTN_DEC & ~try_inc) // press decrese button
		// ignore dec while pressing inc button
		begin
			try_dec = 1'b1;
			
			if (btn_clock > 250000)
			begin
				count_change = 1'b1;
				if (internal_count == 6'b000000) internal_count = 6'b111011; // 59
				else internal_count = internal_count - 1;
			end
		end
		
		else if (BTN_INC) // press increse button
		begin
			try_inc = 1'b1;

			if (btn_clock > 250000)
			begin
				count_change = 1'b1;
				if (internal_count == 6'b111011) internal_count = 6'b000000;
				else internal_count = internal_count + 1;
			end
		end
		
		else if (try_dec & ~BTN_DEC) // when you release the dec button
		begin
			if (~count_change) 
			begin
				// If the count change flag hasn't changed, it's taken off too quickly
				if (internal_count == 6'b000000) internal_count = 6'b111011;
				else internal_count = internal_count - 1;
			end
			
			try_dec = 1'b0;
			count_change = 1'b0; // Considering that the count will change, it should be reset
		end
		
		
		else if (try_inc & ~BTN_INC) // when you release the inc button
		begin
			if (~count_change) 
			begin
				// If the count change flag hasn't changed, it's taken off too quickly
				if (internal_count == 6'b111011) internal_count = 6'b000000; // 0
				else internal_count = internal_count + 1; 
			end
			
			try_inc = 1'b0; 
			count_change = 1'b0; // Considering that the count will change, it should be reset
		end
		
		else if (~BTN_DEC & ~BTN_INC) 
		begin
			count_change = 1'b0; // reset change state
			try_dec = 1'b0; // reset dec state
			try_inc = 1'b0; // reset int state
		end
	end
end

assign tmp = internal_count;

endmodule