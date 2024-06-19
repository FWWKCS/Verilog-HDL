// AL_PIEZO.v

module AL_PIEZO(
	CLK, alarm_active,
	currentMIN, currentSEC, alarmMIN, alarmSEC,
	PIEZO
);

input CLK;

// If the alarm action is enabled, output the PIEZO sound
// Even if it's turned off, the score will continue
input alarm_active; 

// Use to check if the alarm times match
input [6:0] currentMIN, currentSEC;
input [6:0] alarmMIN, alarmSEC;

output wire PIEZO;


reg SCORE_END = 0; // When the score ends or stops, it's a flag that indicates that the performance is over

reg BUFF;
reg check; // Flag to check for an alarm when a match is checked
integer CLK_CNT;
integer CNT_SOUND;

integer IDX;

// scale
parameter D1 = 6810;
parameter EP1 = 6428;
parameter E1 = 6067;
parameter F1 = 5726;
parameter FS1 = 5405;
parameter G1 = 5102;
parameter GS1 = 4815;
parameter A1 = 4545;
parameter BP1 = 4290;
parameter B1 = 4049;

parameter C2 = 3822;
parameter CS2 = 3607;
parameter D2 = 3405;
parameter EP2 = 3214;
parameter E2 = 3033;
parameter F2 = 2863; 
parameter FS2 = 2702;
parameter G2 = 2551;
parameter GS2 = 2407;
parameter A2 = 2272;
parameter BP2 = 2145;
parameter B2 = 2024;

parameter C3 = 1911;
parameter CS3 = 1803;
parameter D3 = 1702;
parameter EP3 = 1607;
parameter E3 = 1516;
parameter F3 = 1431;
parameter FS3 = 1351;
parameter G3 = 1275;
parameter GS3 = 1203;
parameter A3 = 1136;
parameter BP3 = 1072;
parameter B3 = 1012;

parameter C4 = 955;
parameter CS4 = 901;
parameter D4 = 851;
parameter EP4 = 803;
parameter E4 = 758;
parameter F4 = 715;
parameter FS4 = 675;
parameter G4 = 637;
parameter GS4 = 601;
parameter A4 = 568;
parameter BP4 = 536;
parameter B4 = 506;

parameter C5 = 477;
parameter CS5 = 450;
parameter D5 = 425;
parameter EP5 = 401;
parameter E5 = 379;
parameter F5 = 357;
parameter FS5 = 337;
parameter G5 = 318;

// break
parameter N = -1;

// duration 
parameter W = 2_000_000; // whole
parameter H = 1_000_000; // half
parameter Q = 500_000; // quarter
parameter E = 250_000; // eighth
parameter S = 125_000; // sixteenth
parameter T = 62_500; // thirty-second


// a score to be played
parameter SIZE = 518;
integer score [0:SIZE][0:1];

// Initialize the array

initial begin
	score[0][0] = D2;   score[0][1] = T;
	score[1][0] = N;    score[1][1] = T;
	score[2][0] = D2;   score[2][1] = T;
	score[3][0] = N;    score[3][1] = T;
	score[4][0] = D3;   score[4][1] = S;
	score[5][0] = N;    score[5][1] = S;
	score[6][0] = A2;   score[6][1] = S;
	score[7][0] = N;    score[7][1] = S;
	score[8][0] = N;    score[8][1] = S;
	score[9][0] = GS2;  score[9][1] = T;
	score[10][0] = N;   score[10][1] = T;
	score[11][0] = N;   score[11][1] = S;
	score[12][0] = G2;  score[12][1] = S;
	score[13][0] = N;   score[13][1] = S;
	score[14][0] = F2;  score[14][1] = S + S;
	score[15][0] = D2;  score[15][1] = T;
	score[16][0] = N;   score[16][1] = T;
	score[17][0] = F2;  score[17][1] = T;
	score[18][0] = N;   score[18][1] = T;
	score[19][0] = G2;  score[19][1] = T;
	score[20][0] = N;   score[20][1] = T; // 1
	
	score[21][0] = C2;   score[21][1] = T;
	score[22][0] = N;    score[22][1] = T;
	score[23][0] = C2;   score[23][1] = T;
	score[24][0] = N;    score[24][1] = T;
	score[25][0] = D3;   score[25][1] = S;
	score[26][0] = N;    score[26][1] = S;
	score[27][0] = A2;   score[27][1] = S;
	score[28][0] = N;    score[28][1] = S;
	score[29][0] = N;    score[29][1] = S;
	score[30][0] = GS2;  score[30][1] = T;
	score[31][0] = N;   score[31][1] = T;
	score[32][0] = N;   score[32][1] = S;
	score[33][0] = G2;  score[33][1] = S;
	score[34][0] = N;   score[34][1] = S;
	score[35][0] = F2;  score[35][1] = S + S;
	score[36][0] = D2;  score[36][1] = T;
	score[37][0] = N;   score[37][1] = T;
	score[38][0] = F2;  score[38][1] = T;
	score[39][0] = N;   score[39][1] = T;
	score[40][0] = G2;  score[40][1] = T;
	score[41][0] = N;   score[41][1] = T; // 2
	
	score[42][0] = B1;   score[42][1] = T;
	score[43][0] = N;    score[43][1] = T;
	score[44][0] = B1;   score[44][1] = T;
	score[45][0] = N;    score[45][1] = T;
	score[46][0] = D3;   score[46][1] = S;
	score[47][0] = N;    score[47][1] = S;
	score[48][0] = A2;   score[48][1] = S;
	score[49][0] = N;    score[49][1] = S;
	score[50][0] = N;    score[50][1] = S;
	score[51][0] = GS2;  score[51][1] = T;
	score[52][0] = N;   score[52][1] = T;
	score[53][0] = N;   score[53][1] = S;
	score[54][0] = G2;  score[54][1] = S;
	score[55][0] = N;   score[55][1] = S;
	score[56][0] = F2;  score[56][1] = S + S;
	score[57][0] = D2;  score[57][1] = T;
	score[58][0] = N;   score[58][1] = T;
	score[59][0] = F2;  score[59][1] = T;
	score[60][0] = N;   score[60][1] = T;
	score[61][0] = G2;  score[61][1] = T;
	score[62][0] = N;   score[62][1] = T; // 3
	
	score[63][0] = BP1;   score[63][1] = T;
	score[64][0] = N;    score[64][1] = T;
	score[65][0] = BP1;   score[65][1] = T;
	score[66][0] = N;    score[66][1] = T;
	score[67][0] = D3;   score[67][1] = S;
	score[68][0] = N;    score[68][1] = S;
	score[69][0] = A2;   score[69][1] = S;
	score[70][0] = N;    score[70][1] = S;
	score[71][0] = N;    score[71][1] = S;
	score[72][0] = GS2;  score[72][1] = T;
	score[73][0] = N;   score[73][1] = T;
	score[74][0] = N;   score[74][1] = S;
	score[75][0] = G2;  score[75][1] = S;
	score[76][0] = N;   score[76][1] = S;
	score[77][0] = F2;  score[77][1] = S + S;
	score[78][0] = D2;  score[78][1] = T;
	score[79][0] = N;   score[79][1] = T;
	score[80][0] = F2;  score[80][1] = T;
	score[81][0] = N;   score[81][1] = T;
	score[82][0] = G2;  score[82][1] = T;
	score[83][0] = N;   score[83][1] = T; // 4
	
	score[84][0] = D3;   score[84][1] = T;
	score[85][0] = N;    score[85][1] = T;
	score[86][0] = D3;   score[86][1] = T;
	score[87][0] = N;    score[87][1] = T;
	score[88][0] = D4;   score[88][1] = S;
	score[89][0] = N;    score[89][1] = S;
	score[90][0] = A3;   score[90][1] = S;
	score[91][0] = N;    score[91][1] = S;
	score[92][0] = N;    score[92][1] = S;
	score[93][0] = GS3;  score[93][1] = T;
	score[94][0] = N;   score[94][1] = T;
	score[95][0] = N;   score[95][1] = S;
	score[96][0] = G3;  score[96][1] = S;
	score[97][0] = N;   score[97][1] = S;
	score[98][0] = F3;  score[98][1] = S + S;
	score[99][0] = D3;  score[99][1] = T;
	score[100][0] = N;   score[100][1] = T;
	score[101][0] = F3;  score[101][1] = T;
	score[102][0] = N;   score[102][1] = T;
	score[103][0] = G3;  score[103][1] = T;
	score[104][0] = N;   score[104][1] = T; // 5
	
	score[105][0] = C3;   score[105][1] = T;
	score[106][0] = N;    score[106][1] = T;
	score[107][0] = C3;   score[107][1] = T;
	score[108][0] = N;    score[108][1] = T;
	score[109][0] = D4;   score[109][1] = S;
	score[110][0] = N;    score[110][1] = S;
	score[111][0] = A3;   score[111][1] = S;
	score[112][0] = N;    score[112][1] = S;
	score[113][0] = N;    score[113][1] = S;
	score[114][0] = GS3;  score[114][1] = T;
	score[115][0] = N;   score[115][1] = T;
	score[116][0] = N;   score[116][1] = S;
	score[117][0] = G3;  score[117][1] = S;
	score[118][0] = N;   score[118][1] = S;
	score[119][0] = F3;  score[119][1] = S + S;
	score[120][0] = D3;  score[120][1] = T;
	score[121][0] = N;   score[121][1] = T;
	score[122][0] = F3;  score[122][1] = T;
	score[123][0] = N;   score[123][1] = T;
	score[124][0] = G3;  score[124][1] = T;
	score[125][0] = N;   score[125][1] = T; // 6
	
	score[126][0] = B2;   score[126][1] = T;
	score[127][0] = N;    score[127][1] = T;
	score[128][0] = B2;   score[128][1] = T;
	score[129][0] = N;    score[129][1] = T;
	score[130][0] = D4;   score[130][1] = S;
	score[131][0] = N;    score[131][1] = S;
	score[132][0] = A3;   score[132][1] = S;
	score[133][0] = N;    score[133][1] = S;
	score[134][0] = N;    score[134][1] = S;
	score[135][0] = GS3;  score[135][1] = T;
	score[136][0] = N;   score[136][1] = T;
	score[137][0] = N;   score[137][1] = S;
	score[138][0] = G3;  score[138][1] = S;
	score[139][0] = N;   score[139][1] = S;
	score[140][0] = F3;  score[140][1] = S + S;
	score[141][0] = D3;  score[141][1] = T;
	score[142][0] = N;   score[142][1] = T;
	score[143][0] = F3;  score[143][1] = T;
	score[144][0] = N;   score[144][1] = T;
	score[145][0] = G3;  score[145][1] = T;
	score[146][0] = N;   score[146][1] = T; // 7
	
	score[147][0] = BP2;   score[147][1] = T;
	score[148][0] = N;    score[148][1] = T;
	score[149][0] = BP2;   score[149][1] = T;
	score[150][0] = N;    score[150][1] = T;
	score[151][0] = D4;   score[151][1] = S;
	score[152][0] = N;    score[152][1] = S;
	score[153][0] = A3;   score[153][1] = S;
	score[154][0] = N;    score[154][1] = S;
	score[155][0] = N;    score[155][1] = S;
	score[156][0] = GS3;  score[156][1] = T;
	score[157][0] = N;   score[157][1] = T;
	score[158][0] = N;   score[158][1] = S;
	score[159][0] = G3;  score[159][1] = S;
	score[160][0] = N;   score[160][1] = S;
	score[161][0] = F3;  score[161][1] = S + S;
	score[162][0] = D3;  score[162][1] = T;
	score[163][0] = N;   score[163][1] = T;
	score[164][0] = F3;  score[164][1] = T;
	score[165][0] = N;   score[165][1] = T;
	score[166][0] = G3;  score[166][1] = T;
	score[167][0] = N;   score[167][1] = T; // 8

   score[168][0] = F4;   score[168][1] = S;
   score[169][0] = N;    score[169][1] = S;
   score[170][0] = F4;   score[170][1] = T;
   score[171][0] = N;   score[171][1] = T;
   score[172][0] = F4;   score[172][1] = S;
   score[173][0] = N;   score[173][1] = S;
   score[174][0] = F4;   score[174][1] = S;
   score[175][0] = N;    score[175][1] = S;
   score[176][0] = F4;   score[176][1] = S;
   score[177][0] = N;    score[177][1] = S;
   score[178][0] = D4;   score[178][1] = S;
   score[179][0] = N;    score[179][1] = S;
   score[180][0] = D4;   score[180][1] = Q; // 9
   
   score[181][0] = F4;    score[181][1] = S;
   score[182][0] = N;     score[182][1] = S;
   score[183][0] = F4;    score[183][1] = T;
   score[184][0] = N;     score[184][1] = T;
   score[185][0] = F4;    score[185][1] = T;
   score[186][0] = N;     score[186][1] = T + S;
   score[187][0] = G4;    score[187][1] = S;
   score[188][0] = N;     score[188][1] = S;
   score[189][0] = GS4;   score[189][1] = S+T;
   score[190][0] = N;     score[190][1] = T;
   score[191][0] = G4;   score[191][1] = T;
   score[192][0] = GS4;  score[192][1] = T;
   score[193][0] = G4;   score[193][1] = T;
   score[194][0] = N;    score[194][1] = T;
   score[195][0] = D4;   score[195][1] = T;
   score[196][0] = N;    score[196][1] = T;
   score[197][0] = F4;   score[197][1] = T;
   score[198][0] = N;    score[198][1] = T;
   score[199][0] = G4;   score[199][1] = E;
	score[200][0] = N;    score[200][1] = S; // 10

   score[201][0] = F4;    score[201][1] = S;
   score[202][0] = N;     score[202][1] = S;
   score[203][0] = F4;    score[203][1] = T;
   score[204][0] = N;     score[204][1] = T;
   score[205][0] = F4;    score[205][1] = T;
   score[206][0] = N;     score[206][1] = T+S;
   score[207][0] = G4;    score[207][1] = S;
   score[208][0] = N;     score[208][1] = S;
   score[209][0] = GS4;   score[209][1] = S;
   score[210][0] = N;     score[210][1] = S;
   score[211][0] = A4;   score[211][1] = S;
   score[212][0] = N;    score[212][1] = S;
   score[213][0] = C5;   score[213][1] = S;
   score[214][0] = N;    score[214][1] = S;
   score[215][0] = A4;   score[215][1] = E;
   score[216][0] = N;    score[216][1] = S; // 11

   score[217][0] = D5;    score[217][1] = S;
   score[218][0] = N;     score[218][1] = S;
   score[219][0] = D5;    score[219][1] = S;
   score[220][0] = N;     score[220][1] = S;
   score[221][0] = D5;    score[221][1] = T;
   score[222][0] = N;     score[222][1] = T;
   score[223][0] = A4;    score[223][1] = T;
   score[224][0] = N;     score[224][1] = T;
   score[225][0] = D5;    score[225][1] = T;
   score[226][0] = N;     score[226][1] = T;
   score[227][0] = C5;    score[227][1] = T+Q+E;
   score[228][0] = N;     score[228][1] = E; // 12

   score[229][0] = A4;    score[229][1] = S;
   score[230][0] = N;     score[230][1] = S;
   score[231][0] = A4;    score[231][1] = T;
   score[232][0] = N;     score[232][1] = T;
   score[233][0] = A4;   score[233][1] = S;
   score[234][0] = N;    score[234][1] = S;
   score[235][0] = A4;   score[235][1] = S;
   score[236][0] = N;    score[236][1] = S;
   score[237][0] = A4;   score[237][1] = S;
   score[238][0] = N;    score[238][1] = S;
   score[239][0] = G4;   score[239][1] = S;
   score[240][0] = N;    score[240][1] = S;
   score[241][0] = G4;   score[241][1] = Q; // 13

   score[242][0] = A4;    score[242][1] = S;
   score[243][0] = N;     score[243][1] = S;
   score[244][0] = A4;    score[244][1] = S;
   score[245][0] = N;     score[245][1] = S;
   score[246][0] = A4;    score[246][1] = T;
   score[247][0] = N;     score[247][1] = T;
   score[248][0] = A4;    score[248][1] = T;
   score[249][0] = N;     score[249][1] = T+S;
   score[250][0] = G4;    score[250][1] = T;
   score[251][0] = N;     score[251][1] = T+S;
   score[252][0] = A4;    score[252][1] = T;
   score[253][0] = N;     score[253][1] = T+S;
   score[254][0] = D5;    score[254][1] = T;
   score[255][0] = N;     score[255][1] = T+S;
   score[256][0] = A4;    score[256][1] = T;
   score[257][0] = N;     score[257][1] = T;
   score[258][0] = G4;    score[258][1] = S;
   score[259][0] = N;     score[259][1] = S; // 14
	
	score[260][0] = D5;    score[260][1] = E;
   score[261][0] = A4;    score[261][1] = E;
   score[262][0] = G4;    score[262][1] = E;
   score[263][0] = F4;    score[263][1] = E;
   score[264][0] = C5;    score[264][1] = E;
   score[265][0] = G4;    score[265][1] = E;
   score[266][0] = F4;    score[266][1] = E;
   score[267][0] = E4;    score[267][1] = E; // 15

   score[268][0] = BP3;   score[268][1] = S;
   score[269][0] = N;     score[269][1] = S;
   score[270][0] = D4;    score[270][1] = T;
   score[271][0] = N;     score[271][1] = T;
   score[272][0] = E4;    score[272][1] = S;
   score[273][0] = N;     score[273][1] = S;
   score[274][0] = F4;    score[274][1] = S;
   score[275][0] = N;     score[275][1] = S;
   score[276][0] = C5;    score[276][1] = S+H; // 16
	
	score[277][0] = N;     score[277][1] = H;
   score[278][0] = F4;    score[278][1] = T;
   score[279][0] = N;     score[279][1] = T;
   score[280][0] = D4;    score[280][1] = T;
   score[281][0] = N;     score[281][1] = T;
   score[282][0] = F4;    score[282][1] = T;
   score[283][0] = N;     score[283][1] = T;
   score[284][0] = G4;    score[284][1] = T;
   score[285][0] = N;     score[285][1] = T;
   score[286][0] = GS4;    score[286][1] = T;
   score[287][0] = N;     score[287][1] = T;
   score[288][0] = G4;    score[288][1] = T;
   score[289][0] = N;     score[289][1] = T;
   score[290][0] = F4;    score[290][1] = T;
   score[291][0] = N;     score[291][1] = T;
   score[292][0] = D4;    score[292][1] = T;
   score[293][0] = N;     score[293][1] = T; // 17

   score[294][0] = GS4;   score[294][1] = T;
   score[295][0] = G4;    score[295][1] = T;
   score[296][0] = D4;    score[296][1] = T;
   score[297][0] = N;     score[297][1] = T;
   score[298][0] = F4;    score[298][1] = S;
   score[299][0] = N;     score[299][1] = S;
   score[300][0] = G4;    score[300][1] = H;
   score[301][0] = N;     score[301][1] = S;
   score[302][0] = A4;    score[302][1] = S;
   score[303][0] = N;     score[303][1] = S;
   score[304][0] = A4;   score[304][1] = T;
   score[305][0] = N;    score[305][1] = T; // 18

   score[306][0] = C5;    score[306][1] = S;
   score[307][0] = N;     score[307][1] = S;
   score[308][0] = A4;    score[308][1] = T;
   score[309][0] = N;     score[309][1] = T;
   score[310][0] = GS4;   score[310][1] = T;
   score[311][0] = N;     score[311][1] = T;
   score[312][0] = G4;    score[312][1] = T;
   score[313][0] = N;     score[313][1] = T;
   score[314][0] = F4;    score[314][1] = T;
   score[315][0] = N;     score[315][1] = T;
   score[316][0] = D4;    score[316][1] = T;
   score[317][0] = N;     score[317][1] = T;
   score[318][0] = E4;    score[318][1] = T;
   score[319][0] = N;     score[319][1] = T;
   score[320][0] = F4;    score[320][1] = S;
   score[321][0] = N;     score[321][1] = S;
   score[322][0] = G4;    score[322][1] = S;
   score[323][0] = N;     score[323][1] = S;
   score[324][0] = A4;    score[324][1] = S;
   score[325][0] = N;     score[325][1] = S;
   score[326][0] = C5;    score[326][1] = S;
   score[327][0] = N;     score[327][1] = S; // 19

   score[328][0] = CS5;    score[328][1] = S;
   score[329][0] = N;     score[329][1] = S;
   score[330][0] = GS4;    score[330][1] = S;
   score[331][0] = N;     score[331][1] = S;
   score[332][0] = GS4;    score[332][1] = T;
   score[333][0] = N;     score[333][1] = T;
   score[334][0] = G4;    score[334][1] = T;
   score[335][0] = N;     score[335][1] = T;
   score[336][0] = F4;    score[336][1] = T;
   score[337][0] = N;     score[337][1] = T;
   score[338][0] = G4;    score[338][1] = H;
   score[339][0] = N;     score[339][1] = S; // 20

   score[340][0] = F3;    score[340][1] = S;
   score[341][0] = N;     score[341][1] = S;
   score[342][0] = G3;    score[342][1] = S;
   score[343][0] = N;     score[343][1] = S;
   score[344][0] = A3;    score[344][1] = S;
   score[345][0] = N;     score[345][1] = S;
   score[346][0] = F4;    score[346][1] = S;
   score[347][0] = N;     score[347][1] = S;
   score[348][0] = E4;    score[348][1] = E+S;
   score[349][0] = N;     score[349][1] = S;
   score[350][0] = D4;    score[350][1] = E+S;
   score[351][0] = N;     score[351][1] = S; // 21

   score[352][0] = E4;   score[352][1] = E+S;
   score[353][0] = N;     score[353][1] = S;
   score[354][0] = F4;   score[354][1] = E+S;
   score[355][0] = N;     score[355][1] = S;
   score[356][0] = G4;   score[356][1] = E+S;
   score[357][0] = N;     score[357][1] = S;
   score[358][0] = E4;   score[358][1] = E+S;
   score[359][0] = N;     score[359][1] = S; // 22

   score[360][0] = A4;    score[360][1] = Q+E+S;
   score[361][0] = N;     score[361][1] = S;
   score[362][0] = A4;    score[362][1] = T;
   score[363][0] = N;     score[363][1] = T;
   score[364][0] = GS4;    score[364][1] = T;
   score[365][0] = N;     score[365][1] = T;
   score[366][0] = G4;    score[366][1] = T;
   score[367][0] = N;     score[367][1] = T;
   score[368][0] = FS4;    score[368][1] = T;
   score[369][0] = N;     score[369][1] = T;
   score[370][0] = F4;    score[370][1] = T;
   score[371][0] = N;     score[371][1] = T;
   score[372][0] = E4;    score[372][1] = T;
   score[373][0] = N;     score[373][1] = T;
   score[374][0] = EP4;    score[374][1] = T;
   score[375][0] = N;     score[375][1] = T;
   score[376][0] = D4;    score[376][1] = T;
   score[377][0] = N;     score[377][1] = T; // 23
	
	score[378][0] = CS4;    score[378][1] = Q+E+S;
   score[379][0] = N;     score[379][1] = S;
   score[380][0] = EP4;    score[380][1] = Q+E+S;
   score[381][0] = N;     score[381][1] = S; // 24

   score[382][0] = BP1;    score[382][1] = H+E+S;
   score[383][0] = N;     score[383][1] = S;
   score[384][0] = F2;    score[384][1] = E+S;
   score[385][0] = N;     score[385][1] = S; // 25

   score[386][0] = E2;    score[386][1] = Q+E+S;
   score[387][0] = N;     score[387][1] = S;
   score[388][0] = D2;    score[388][1] = Q+E+S;
   score[389][0] = N;     score[389][1] = S; // 26

   score[390][0] = F2;    score[390][1] = W+H+Q+E+S;
   score[391][0] = N;     score[391][1] = S; // 27, 28

   score[392][0] = BP1;    score[392][1] = H+E+S;
   score[393][0] = N;     score[393][1] = S;
   score[394][0] = F2;    score[394][1] = E+S;
   score[395][0] = N;     score[395][1] = S; // 29

   score[396][0] = E2;    score[396][1] = Q+E+S;
   score[397][0] = N;     score[397][1] = S;
   score[398][0] = D2;    score[398][1] = Q+E+S;
   score[399][0] = N;     score[399][1] = S; // 30

   score[400][0] = D2;   score[400][1] = S+T;
   score[401][0] = N;    score[401][1] = T;
   score[402][0] = F3;   score[402][1] = S;
   score[403][0] = N;    score[403][1] = S;
   score[404][0] = E3;   score[404][1] = S;
   score[405][0] = N;    score[405][1] = S+S;
   score[406][0] = C3;   score[406][1] = S+T;
   score[407][0] = N;    score[407][1] = T;
   score[408][0] = E3;   score[408][1] = S;
   score[409][0] = N;    score[409][1] = S;
   score[410][0] = D3;   score[410][1] = S+T;
   score[411][0] = N;    score[411][1] = T;
   score[412][0] = G2;   score[412][1] = T;
   score[413][0] = N;    score[413][1] = T;
   score[414][0] = A2;   score[414][1] = T;
   score[415][0] = N;    score[415][1] = T;
   score[416][0] = C3;   score[416][1] = T;
   score[417][0] = N;    score[417][1] = T; // 31
   
   score[418][0] = N;    score[418][1] = E;
   score[419][0] = F3;   score[419][1] = S;
   score[420][0] = N;    score[420][1] = S;
   score[421][0] = E3;   score[421][1] = S;
   score[422][0] = N;    score[422][1] = S+S;
   score[423][0] = C3;   score[423][1] = S+T;
   score[424][0] = N;    score[424][1] = T;
   score[425][0] = E3;   score[425][1] = S;
   score[426][0] = N;    score[426][1] = S;
   score[427][0] = D3;   score[427][1] = S+T;
   score[428][0] = N;    score[428][1] = T;
   score[429][0] = G2;   score[429][1] = T;
   score[430][0] = N;    score[430][1] = T;
   score[431][0] = A2;   score[431][1] = T;
   score[432][0] = N;    score[432][1] = T;
   score[433][0] = C3;   score[433][1] = T;
   score[434][0] = N;    score[434][1] = T; // 32
   
   score[435][0] = D2;   score[435][1] = T;
	score[436][0] = N;    score[436][1] = T;
	score[437][0] = D2;   score[437][1] = T;
	score[438][0] = N;    score[438][1] = T;
	score[439][0] = D3;   score[439][1] = S;
	score[440][0] = N;    score[440][1] = S;
	score[441][0] = A2;   score[441][1] = S;
	score[442][0] = N;    score[442][1] = S;
	score[443][0] = N;    score[443][1] = S;
	score[444][0] = GS2;  score[444][1] = T;
	score[445][0] = N;   score[445][1] = T;
	score[446][0] = N;   score[446][1] = S;
	score[447][0] = G2;  score[447][1] = S;
	score[448][0] = N;   score[448][1] = S;
	score[449][0] = F2;  score[449][1] = S + S;
	score[450][0] = D2;  score[450][1] = T;
	score[451][0] = N;   score[451][1] = T;
	score[452][0] = F2;  score[452][1] = T;
	score[453][0] = N;   score[453][1] = T;
	score[454][0] = G2;  score[454][1] = T;
	score[455][0] = N;   score[455][1] = T; // 33
	
	score[456][0] = C2;   score[456][1] = T;
	score[457][0] = N;    score[457][1] = T;
	score[458][0] = C2;   score[458][1] = T;
	score[459][0] = N;    score[459][1] = T;
	score[460][0] = D3;   score[460][1] = S;
	score[461][0] = N;    score[461][1] = S;
	score[462][0] = A2;   score[462][1] = S;
	score[463][0] = N;    score[463][1] = S;
	score[464][0] = N;    score[464][1] = S;
	score[465][0] = GS2;  score[465][1] = T;
	score[466][0] = N;   score[466][1] = T;
	score[467][0] = N;   score[467][1] = S;
	score[468][0] = G2;  score[468][1] = S;
	score[469][0] = N;   score[469][1] = S;
	score[470][0] = F2;  score[470][1] = S + S;
	score[471][0] = D2;  score[471][1] = T;
	score[472][0] = N;   score[472][1] = T;
	score[473][0] = F2;  score[473][1] = T;
	score[474][0] = N;   score[474][1] = T;
	score[475][0] = G2;  score[475][1] = T;
	score[476][0] = N;   score[476][1] = T; // 34

   score[477][0] = D2;   score[477][1] = T;
	score[478][0] = N;    score[478][1] = T;
	score[479][0] = D2;   score[479][1] = T;
	score[480][0] = N;    score[480][1] = T;
	score[481][0] = D3;   score[481][1] = S;
	score[482][0] = N;    score[482][1] = S;
	score[483][0] = A2;   score[483][1] = S;
	score[484][0] = N;    score[484][1] = S;
	score[485][0] = N;    score[485][1] = S;
	score[486][0] = GS2;  score[486][1] = T;
	score[487][0] = N;   score[487][1] = T;
	score[488][0] = N;   score[488][1] = S;
	score[489][0] = G2;  score[489][1] = S;
	score[490][0] = N;   score[490][1] = S;
	score[491][0] = F2;  score[491][1] = S + S;
	score[492][0] = D2;  score[492][1] = T;
	score[493][0] = N;   score[493][1] = T;
	score[494][0] = F2;  score[494][1] = T;
	score[495][0] = N;   score[495][1] = T;
	score[496][0] = G2;  score[496][1] = T;
	score[497][0] = N;   score[497][1] = T; // 35

   score[498][0] = D2;   score[498][1] = T;
	score[499][0] = N;    score[499][1] = T;
	score[500][0] = D2;   score[500][1] = T;
	score[501][0] = N;    score[501][1] = T;
	score[502][0] = D3;   score[502][1] = S;
	score[503][0] = N;    score[503][1] = S;
	score[504][0] = A2;   score[504][1] = S;
	score[505][0] = N;    score[505][1] = S;
	score[506][0] = N;    score[506][1] = S;
	score[507][0] = GS2;  score[507][1] = T;
	score[508][0] = N;   score[508][1] = T;
	score[509][0] = N;   score[509][1] = S;
	score[510][0] = G2;  score[510][1] = S;
	score[511][0] = N;   score[511][1] = S;
	score[512][0] = F2;  score[512][1] = S + S;
	score[513][0] = D2;  score[513][1] = T;
	score[514][0] = N;   score[514][1] = T;
	score[515][0] = F2;  score[515][1] = T;
	score[516][0] = N;   score[516][1] = T;
	score[517][0] = G2;  score[517][1] = T;
	score[518][0] = N;   score[518][1] = T; // 36
end


always @(posedge CLK)
begin
	if (~check && alarm_active && (currentMIN == alarmMIN) && (currentSEC == alarmSEC)) 
	begin 
		check = 1;
		CLK_CNT = 0;
		CNT_SOUND = 0;
		SCORE_END = 0;
		IDX = 0;
	end
	
	if (~alarm_active) 
	begin
		check = 0;
		SCORE_END = 1;
	end
	
	if (alarm_active && ~SCORE_END)
	begin
		CLK_CNT = CLK_CNT + 1;
		
		if (score[IDX][0] != N)
		begin
			if (CNT_SOUND >= score[IDX][0])
			begin
				CNT_SOUND = 0;
				BUFF = ~BUFF;
			end
			else CNT_SOUND = CNT_SOUND + 1;
		end
		else BUFF = 0;
		
		if (CLK_CNT >= score[IDX][1])
		begin
			CLK_CNT = 0;
			IDX = IDX + 1;
		end
		
		if (IDX > SIZE) 
		begin
			check = 0;
			SCORE_END = 1;
		end
	end
end

assign PIEZO = BUFF;

endmodule