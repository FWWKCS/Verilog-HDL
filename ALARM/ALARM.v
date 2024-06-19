module ALARM(
	CLK,
	SEG_COM, SEG_DATA,
	BTN_INC, BTN_DEC, BTN_secmin,
	BTN_VIEW, BTN_SETC, BTN_SETA, BTN_ACTIVEA,
	LED_VIEW, LED_SETC, LED_SETA, LED_ACTIVEA,
	PIEZO
);

input CLK; // power
input BTN_INC, BTN_DEC; // decrese count, increse count 
input BTN_secmin; // Determines whether the time to set is seconds or minutes

input BTN_VIEW; // View current time
input BTN_SETC; // Set the current time
input BTN_SETA; // Set the alarm time
input BTN_ACTIVEA; // Enable alarm status


// Store previous button status for each clock cycle
reg prev_BTN_SETC, prev_BTN_SETA;

output reg LED_VIEW = 1; // Indicates that you are looking at the time
output reg LED_SETC = 0; // Indicates that you have entered the current time setting mode
output reg LED_SETA = 0; // Indicates that you have entered alarm setting mode
output reg LED_ACTIVEA = 0; // Indicates that the alarm is active

output reg [3:0] SEG_COM;
output wire [7:0] SEG_DATA;
reg SEG_DOT;

output wire PIEZO;



integer CLK_CNT;
integer CNT_SCAN;


reg [3:0] NUM; // the final value to be displayed


wire [3:0] M10, M1, S10, S1;
reg [6:0] MIN, SEC;


wire [3:0] sCM10, sCM1, sCS10, sCS1; 
reg [6:0] setCsec, setCmin;
wire [6:0] tmpCsec, tmpCmin;


wire [3:0] sAM10, sAM1, sAS10, sAS1;
reg [6:0] setAsec, setAmin;
wire [6:0] tmpAsec, tmpAmin;

// Variable to store the alarm time
reg [6:0] alarmMIN, alarmSEC;


reg secSelected = 1; // Applies in the current time setting mode and alarm time setting mode

reg viewCurrentMode = 1; // Flag to view the current time
reg setCurrentMode; // Flag to set the current time
reg setAlarmTimeMode; // Flag to set alarm time
reg alarm_active; // Alarm sound activation flag


// The increase/decrease value is stored in tmp, 
// which is contained in count in real time 
// The action here is necessary to float the value in the FND
always @* begin 
   setCsec <= tmpCsec;
	setCmin <= tmpCmin;
	
	setAsec <= tmpAsec;
	setAmin <= tmpAmin;
end

always @(posedge CLK)
begin
	// If the set time is determined, it will be initialized to zero
	if (setCurrentMode && BTN_SETC && ~prev_BTN_SETC) CLK_CNT = 0;

	if (CLK_CNT >= 999999) CLK_CNT = 0;
	else CLK_CNT = CLK_CNT + 1;
end

// The passage of time must always last
always @(posedge CLK)
begin
	// If the set time is determined, it will be initialized to that number of seconds
	if (setCurrentMode && BTN_SETC && ~prev_BTN_SETC) SEC = setCsec;

	if (CLK_CNT == 999999)
	begin // 1000 CLK_CNT = 1sec
		if (SEC >= 59) SEC = 0;
		else SEC = SEC + 1;
	end
end

always @(posedge CLK)
begin
	// If the set time is determined, it will be initialized to that number of seconds
	if (setCurrentMode && BTN_SETC && ~prev_BTN_SETC) MIN = setCmin;

	if ((CLK_CNT == 999999) && (SEC == 59))
	begin
		// 60sec = 1min
		// 60min = 1h
		if (MIN >= 59) MIN = 0;
		else MIN = MIN + 1;
	end
end

/* Button Trigger */
// Choose between minutes and seconds

// Continue to check and save the status change of the button
always @(posedge CLK) begin
    prev_BTN_SETC <= BTN_SETC;
    prev_BTN_SETA <= BTN_SETA;
end

// Determines the number of seconds to set
// Applies only in the [current time/alarm] setting mode
always @(posedge BTN_secmin)
begin
	if (!viewCurrentMode) secSelected = ~secSelected;
end

always @(posedge CLK)
begin
	// You have to press one button to change the mode
	if (BTN_VIEW && ~BTN_SETC && ~BTN_SETA)
	begin
		// Change the current time to view mode
		if (~viewCurrentMode)
		begin
			// Other modes must be disabled
			setCurrentMode = 0;
			setAlarmTimeMode = 0;
			LED_SETC = 0;
			LED_SETA = 0;
			
			viewCurrentMode = 1;
			LED_VIEW = 1;
		end
	end 
	
	else if (~BTN_VIEW && BTN_SETC && ~BTN_SETA)
	begin
		// Change to the current time setting mode
		if (~setCurrentMode && ~prev_BTN_SETC) 
		begin
			// Other modes must be disabled
			viewCurrentMode = 0;
			setAlarmTimeMode = 0;
			LED_VIEW = 0;
			LED_SETA = 0;
			
			setCurrentMode = 1;
			LED_SETC = 1;
		end
		else if (setCurrentMode && ~prev_BTN_SETC)
		begin
			// Forced into time view mode
			setCurrentMode = 0;
			setAlarmTimeMode = 0;
			LED_SETC = 0;
			LED_SETA = 0;
			
			viewCurrentMode = 1;
			LED_VIEW = 1;
		end
	end
	
	else if (~BTN_VIEW && ~BTN_SETC && BTN_SETA)
	begin
		// Change to alarm time setting mode
		if (~setAlarmTimeMode && ~prev_BTN_SETA) 
		begin
			// Other modes must be disabled
			viewCurrentMode = 0;
			setCurrentMode = 0;
			LED_VIEW = 0;
			LED_SETC = 0;
			
			setAlarmTimeMode = 1;
			LED_SETA = 1;
		end
		else if (setAlarmTimeMode && ~prev_BTN_SETA)
		begin
			// The alarm time is saved
			alarmMIN = setAmin;
			alarmSEC = setAsec;
			
			// Forced into time view mode
			setCurrentMode = 0;
			setAlarmTimeMode = 0;
			LED_SETC = 0;
			LED_SETA = 0;
			
			viewCurrentMode = 1;
			LED_VIEW = 1;
		end
	end 
end

// Change whether the alarm works or not
// The activation of the alarm action can be checked through the LED
always @(posedge BTN_ACTIVEA) 
begin
	if (alarm_active)
	begin
		// Disable alarm
		alarm_active = 0;
		LED_ACTIVEA = 0;
	end
	else
	begin
		// Enable alarm
		alarm_active = 1;
		LED_ACTIVEA = 1;
	end
end


// CNT_SCAN 0~3 increment
always @(posedge CLK)
begin
	begin
		if (CNT_SCAN >= 3)
			CNT_SCAN = 0;
		else
			CNT_SCAN = CNT_SCAN + 1;
	end
end

// scanning
always @(posedge CLK)
begin
		case (CNT_SCAN)
		0:
		begin
			SEG_COM = 4'b0111;
			
			if (setCurrentMode) NUM = sCM10;
			else if (setAlarmTimeMode) NUM = sAM10;
			else NUM = M10;
			
			SEG_DOT = 1'b0;
		end
		
		1:
		begin
			SEG_COM = 4'b1011;
			
			if (setCurrentMode) NUM = sCM1;
			else if (setAlarmTimeMode) NUM = sAM1;
			else NUM = M1;
			
			if ((setCurrentMode || setAlarmTimeMode) && ~secSelected)
			begin
				if (CLK_CNT < 500000) SEG_DOT = 1'b0;
				else SEG_DOT = 1'b1;
			end
			else SEG_DOT = 1'b1;
		end 
		
		2:
		begin
			SEG_COM = 4'b1101;
			
			if (setCurrentMode) NUM = sCS10;
			else if (setAlarmTimeMode) NUM = sAS10;
			else NUM = S10;
			
			SEG_DOT = 1'b0;
		end
		
		3:
		begin
			SEG_COM = 4'b1110;
			
			if (setCurrentMode) NUM = sCS1;
			else if (setAlarmTimeMode) NUM = sAS1;
			else NUM = S1;
			
			if ((setCurrentMode || setAlarmTimeMode) && secSelected)
			begin
				if (CLK_CNT < 500000) SEG_DOT = 1'b0;
				else SEG_DOT = 1'b1;
			end
			else SEG_DOT = 1'b1;
		end
		endcase
end

AL_SEP s_sep(SEC, S10, S1);
AL_SEP m_sep(MIN, M10, M1);

AL_SEP Cs_sep(setCsec, sCS10, sCS1);
AL_SEP Cm_sep(setCmin, sCM10, sCM1);

AL_SEP As_sep(setAsec, sAS10, sAS1);
AL_SEP Am_sep(setAmin, sAM10, sAM1);


AL_BUTTONCOUNTER setCurrentSEC(
	 .CLK(CLK),
	 .BTN_INC(BTN_INC),
	 .BTN_DEC(BTN_DEC),
	 .BTN_SET(BTN_SETC),
	 .count(setCsec),
	 .setFlag(setCurrentMode),
	 .targetFlag(secSelected),
	 .prev_SET(prev_BTN_SETC),
	 .tmp(tmpCsec)
);
	
AL_BUTTONCOUNTER setAlarmSEC(
	 .CLK(CLK),
	 .BTN_INC(BTN_INC),
	 .BTN_DEC(BTN_DEC),
	 .BTN_SET(BTN_SETA),
	 .count(setAsec),
	 .setFlag(setAlarmTimeMode),
	 .targetFlag(secSelected),
	 .prev_SET(prev_BTN_SETA),
	 .tmp(tmpAsec)
);

AL_BUTTONCOUNTER setCurrentMIN(
	 .CLK(CLK),
	 .BTN_INC(BTN_INC),
	 .BTN_DEC(BTN_DEC),
	 .BTN_SET(BTN_SETC),
	 .count(setCmin),
	 .setFlag(setCurrentMode),
	 .targetFlag(~secSelected),
	 .prev_SET(prev_BTN_SETC),
	 .tmp(tmpCmin)
);	

AL_BUTTONCOUNTER setAlarmMIN(
	 .CLK(CLK),
	 .BTN_INC(BTN_INC),
	 .BTN_DEC(BTN_DEC),
	 .BTN_SET(BTN_SETA),
	 .count(setAmin),
	 .setFlag(setAlarmTimeMode),
	 .targetFlag(~secSelected),
	 .prev_SET(prev_BTN_SETA),
	 .tmp(tmpAmin)
);


AL_DECODER decode(NUM, SEG_DOT, SEG_DATA);

AL_PIEZO piezo(CLK, alarm_active, MIN, SEC, alarmMIN, alarmSEC, PIEZO);

endmodule