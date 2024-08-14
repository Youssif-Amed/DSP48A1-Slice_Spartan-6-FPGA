module DSP48A1_tb ();
 /* -------Parameters-------*/
  parameter A0REG = 0;
  parameter A1REG = 1;
  parameter B0REG = 0;
  parameter B1REG = 1;
  parameter CREG = 1;
  parameter DREG = 1;
  parameter MREG = 1;
  parameter PREG = 1;
  parameter OPMODEREG = 1;
  parameter CARRYINREG = 1;
  parameter CARRYOUTREG = 1;
  parameter CARRYINSEL = "OPMODE5";
  parameter B_INPUT = "DIRECT";
  parameter RSTTYPE = "SYNC";
 /*---------inputs---------*/
  reg [17:0] A,B,D;
  reg [47:0] C;
  reg CARRYIN,clk;
  reg [7:0] OPMODE;
  reg CEA,CEB,CEC,CED,CECARRYIN,CEM,CEOPMODE,CEP;
  reg RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
  reg [47:0] PCIN;
 /*---------outputs---------*/
  wire [35:0] M;
  wire [47:0] P,PCOUT;
  wire CARRYOUT,CARRYOUTF;
  wire [17:0] BCOUT;
 /*-----DUT INSTATIATIONS-----*/
 DSP48A1 #(
    .A0REG(A0REG),.A1REG(A1REG),.B0REG(B0REG),.B1REG(B1REG),
    .CREG(CREG),.DREG(DREG),.MREG(MREG),.PREG(PREG),
    .OPMODEREG(OPMODEREG),.CARRYINREG(CARRYINREG),
    .CARRYOUTREG(CARRYOUTREG),.CARRYINSEL(CARRYINSEL),
    .B_INPUT(B_INPUT),.RSTTYPE(RSTTYPE)
 ) DUT (.*);

 /*-----clock generation-----*/
 initial begin
    clk=0;
    forever begin
        #5;     clk=~clk;
    end
 end

 /*-----Test Stimulus-----*/
 initial begin
 $display("----START SIMULATION----");
 /*------intialize inputs------*/
 /*---------------------------------DATA PORTS----------------------------------*/
  A = 0;    B = 0;      C=0;      D = 0;
  CARRYIN = 0;       OPMODE=0;
 /*---------------------------CLOCK ENABLE INPUT PORTS--------------------------*/
  CEA = 0;     CEB = 0;     CEC = 0;
  CED = 0;     CEM = 0;     CEP = 0;
  CECARRYIN = 0;     CEOPMODE = 0;
 /*------------------------------RESET INPUT PORTS-----------------------------*/
  RSTA = 0;    RSTB = 0;    RSTC = 0;
  RSTD = 0;    RSTM = 0;    RSTP = 0;
  RSTOPMODE = 0;     RSTCARRYIN = 0;
 /*-------------------------------Cascade PORTS--------------------------------*/
  PCIN = 0;
 /*-----Delay-----*/
  #20;

 //set reset signals
  RSTA = 1;    RSTB = 1;    RSTC = 1;
  RSTD = 1;    RSTM = 1;    RSTP = 1;
  RSTOPMODE = 1;     RSTCARRYIN = 1;
  @(negedge clk);
 //clear reset signals
  RSTA = 0;    RSTB = 0;    RSTC = 0;
  RSTD = 0;    RSTM = 0;    RSTP = 0;
  RSTOPMODE = 0;     RSTCARRYIN = 0;
 //set clock enable signals
  CEA = 1;     CEB = 1;     CEC = 1;
  CED = 1;     CEM = 1;     CEP = 1;
  CECARRYIN = 1;     CEOPMODE = 1;

 //Test Multiplication
  A=$random;   B=$random;
  OPMODE=8'b0000_0000;   // M = A * B
  repeat(3) @(negedge clk);

 //Test Pre-Adder/Substracter
  A=18'h0001;
  D=$random;   B=$random;
  OPMODE=8'b0001_0000;  // M = 1*(B+D)
  repeat(3) @(negedge clk);

 //Test Post-Adder/Substracter
  C=$random;
  OPMODE=8'b0010_1100;  // P = 0 + C + OPMODE[5]
  repeat(2) @(negedge clk);

 //Test Post-Adder/Substracter after Multiplication
  A=$random;   B=$random;
  OPMODE=8'b0000_0000;   // M = A * B
  repeat(2) @(negedge clk);
  OPMODE=8'b0010_1101;   // P= M + C + OPMODE[5]
  repeat(3) @(negedge clk);
    
 $display("----END SIMULATION----");
 $stop;
 end
  


endmodule