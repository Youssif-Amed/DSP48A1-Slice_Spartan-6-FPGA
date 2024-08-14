module DSP48A1 #(
    /* A0REG,A1REG,B0REG,B1REG can take values of 0 or 1.
     * It defines the number of pipeline stages.A0,B0 are first stage
     * A1,B1 are second stages of pipeline */
    parameter A0REG       = 0, /* defaults to 0 (no register) */
    parameter A1REG       = 1, /* defaults to 1 (register) */
    parameter B0REG       = 0, /* defaults to 0 (no register) */
    parameter B1REG       = 1, /* defaults to 1 (register) */
    parameter CREG        = 1, /* default registered */
    parameter DREG        = 1, /* default registered */
    parameter MREG        = 1, /* default registered */
    parameter PREG        = 1, /* default registered */
    parameter OPMODEREG   = 1, /* default registered */
    parameter CARRYINREG  = 1, /* default registered */
    parameter CARRYOUTREG = 1, /* default registered */
    parameter OPMODREG    = 1, /* default registered */
    /* The CARRYINSEL parameter is used in the carry cascade input, either the CARRYIN input will be considered 
     * or the value of opcode[5]. It can be set to the string CARRYIN or OPMODE5. Default: OPMODE5.
     * Force the output of the mux to 0 if none of these string values exist.
     */
    parameter CARRYINSEL = "OPMODE5",
    /* The B_INPUT parameter defines if the input to the B port is routed from the B input (B_INPUT = DIRECT) 
     * or the cascaded input (BCIN) from the previous DSP48A1 (B_INPUT = CASCADE). Default: DIRECT. 
     * Force the output of the mux to 0 if none of these string values exist.
     */
    parameter B_INPUT = "DIRECT",
    /* The RSTTYPE parameter selects if all resets for the DSP48A1 should have a synchronous or asynchronous 
     * capability. It can be set to ASYNC or SYNC. Default : SYNC
     */ 
    parameter RSTTYPE = "SYNC"
) (
    /*------------------------------------DATA PORTS-------------------------------------*/
    input  [17:0]A,     /* input to multiplier, and optionally to postadd/sub depending on the value of OPMODE[1:0] */
    input  [17:0]B,     /* input to pre-add/sub, to multiplier depending on OPMODE[4], or post-add/sub depending on OPMODE[1:0] */
    input  [47:0]C,     /* input to post-adder/substructer */
    input  [17:0]D,     /* input to pre-add/sub. D[11:0] are concatenated with A and B and optionally sent to post-add/sub depending on the value of OPMODE[1:0]. */
    input  CARRYIN,     /* input to post-adder/substracter */
    output [35:0]M,     /* buffered multiplier output,routable to the FPGA logic. it is either the MREG out or the direct out of multiplier */
    output [47:0]P,     /* Primary output from the post-adder/substracter. it is either the PREG out or the direct out of post-adder/substracter */
    output CARRYOUT,    /* Cascade carry out signal from post-adder/subtracter it is either the PREG out or the direct out of post-adder/substracter 
                         * This output is to be connected only to CARRYIN of adjacent DSP48A1 if multiple DSP blocks are used
                         */
    output CARRYOUTF,   /* Carry out signal from post-adder/subtracter for use in the FPGA logic. It is a copy of the CARRYOUT signal that can be routed to the user */
    /*---------------------------------CONTROL INPUT PORTS--------------------------------*/
    input  clk,         /* DSP clock */
    input  [7:0]OPMODE, /* control input to select the arithmetic operations of the DSP48A1 */
    /*------------------------------CLOCK ENABLE INPUT PORTS------------------------------*/
    input  CEA,         /* Clock enable for the A port registers: (A0REG & A1REG) */
    input  CEB,         /* Clock enable for the B port registers: (B0REG & B1REG) */
    input  CEC,         /* Clock enable for the C port registers: (CREG) */
    input  CECARRYIN,   /* Clock enable for the carry-in register (CYI) and the carry-out register (CYO) */
    input  CED,         /* Clock enable for the D port register: (DREG) */
    input  CEM,         /* Clock enable for the Multiplier register: (MREG) */
    input  CEOPMODE,    /* Clock enable for the OPMODE register: (OPMODEREG) */
    input  CEP,         /* Clock enable for the P output port registers: (PREG=1) */
    /*----------------------------------RESET INPUT PORTS---------------------------------*/
    input  RSTA,         /* Reset for the A port registers: (A0REG & A1REG) */
    input  RSTB,         /* Reset for the B port registers: (B0REG & B1REG) */
    input  RSTC,         /* Reset for the C port registers: (CREG) */
    input  RSTCARRYIN,   /* Reset for the carry-in register (CYI) and the carry-out register (CYO) */
    input  RSTD,         /* Reset for the D port register: (DREG) */
    input  RSTM,         /* Reset for the Multiplier register: (MREG) */
    input  RSTOPMODE,    /* Reset for the OPMODE register: (OPMODEREG) */
    input  RSTP,         /* Reset for the P output port registers: (PREG=1) */
    /*-----------------------------------Cascade PORTS------------------------------------*/
    output  [17:0]BCOUT,   /* Cascade output for Port B.The tools translate the BCOUT cascade to the dedicated BCIN input 
                           * and set the B_INPUT attribute for implementation. If not used, this port should be left unconnected 
                           * So, BCOUT is the same dedicated cascade(BCIN) 
                           */
    input  [47:0]PCIN,    /* Cascade input for Port P */
    output  [47:0]PCOUT    /* Cascade output for Port P */
);

 wire [7:0]OPMODE_1;         /* output of pipeline stage of OPMODE input */
 //------OPMODEREG Stage instantiation------
 peline_stage_mod #(.WIDTH(8),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )OPMODEREG_stage (.in(OPMODE),        // [Width-1:0]input
                               .clk(clk),     // clock input
                               .clk_en(CEOPMODE),  // clock enable
                               .rst(RSTOPMODE),    // reset signal
                               .sel(OPMODEREG),    // selction of the mux
                               .out(OPMODE_1)      // output of the mux
                              );

 wire [17:0]D_1;         /* output of pipeline stage of D input */
 //------DREG Stage instantiation------
 peline_stage_mod #(.WIDTH(18),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )DREG_stage (.in(D),        // [Width-1:0]input
                               .clk(clk),     // clock input
                               .clk_en(CED),  // clock enable
                               .rst(RSTD),    // reset signal
                               .sel(DREG),    // selction of the mux
                               .out(D_1)      // output of the mux
                              );

 wire [17:0]B_0;        /* output of the mux after checking there is a dedicated cascade BCIN or not */                                
 // check B_INPUT parameter to detect if there is BCIN or not */
 assign B_0=(B_INPUT=="DIRECT")?  B :
            (B_INPUT=="CASCADE")? BCOUT : 18'b0;
 wire [17:0]B_1;         /* output of first pipeline stage of B input */
 //------B0REG Stage instantiation------
 peline_stage_mod #(.WIDTH(18),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )B0REG_stage (.in(B_0),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEB),  // clock enable
                                .rst(RSTB),    // reset signal
                                .sel(B0REG),    // selction of the mux
                                .out(B_1)      // output of the mux
                               );
 
 wire [17:0]A_1;         /* output of first pipeline stage of A input */
 //------A0REG Stage instantiation------
 peline_stage_mod #(.WIDTH(18),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )A0REG_stage (.in(A),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEA),  // clock enable
                                .rst(RSTA),    // reset signal
                                .sel(A0REG),   // selction of the mux
                                .out(A_1)      // output of the mux
                               );

 wire [47:0]C_1;         /* output of pipeline stage of C input */
 //------CREG Stage instantiation------
 peline_stage_mod #(.WIDTH(48),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )CREG_stage (.in(C),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEC),  // clock enable
                                .rst(RSTC),    // reset signal
                                .sel(CREG),   // selction of the mux
                                .out(C_1)      // output of the mux
                               );

 wire [17:0]pre_add_sub_out; /* output of pre-adder/substracter */
 //------pre-adder/substracter instantiation------
 Pre_adder_substracter Pre_add_sub(.in0(D_1),     // [17:0]in0
                                   .in1(B_1),     // [17:0]in1
                                   .add_sub(OPMODE_1[6]), // 0-> ADDITION  1-> SUBSTRACTION(in0-in1)
                                   .out(pre_add_sub_out)      // [17:0]out = in0 (+/-) in1
                                  );

 wire [17:0]pre_add_sub_out_1; /* output of mux after checking bypass B */
 //------Bypass_Mux instantiation------
 Mux1_2 #(.WIDTH(18) // width of the inputs and output
         )bypass_Mux(.in0(B_1), // [Width-1:0]input0
                      .in1(pre_add_sub_out), // [Width-1:0]input1
                      .sel(OPMODE_1[4]), // 0 ->out=in0    1 ->out=in1
                      .out(pre_add_sub_out_1)  // [width-1:0]output
                      );

 wire [17:0]B_2;         /* output of second pipeline stage of B input */
 //------B1REG Stage instantiation------
 peline_stage_mod #(.WIDTH(18),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )B1REG_stage (.in(pre_add_sub_out_1),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEB),  // clock enable
                                .rst(RSTB),    // reset signal
                                .sel(B1REG),   // selction of the mux
                                .out(B_2)      // output of the mux
                               );
 assign BCOUT = B_2;    /* Cascade output for Port B */

 wire [17:0]A_2;         /* output of second pipeline stage of A input */
 //------A1REG Stage instantiation------
 peline_stage_mod #(.WIDTH(18),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )A1REG_stage (.in(A_1),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEA),  // clock enable
                                .rst(RSTA),    // reset signal
                                .sel(A1REG),   // selction of the mux
                                .out(A_2)      // output of the mux
                               );
 
 wire [35:0]Multiplier_out;   /* output of multiplying A and B */
 assign Multiplier_out = B_2 * A_2 ;

 wire [35:0]Multiplier_out_1; /* output of the pipeline stage of multiplier output Port */
 //------MREG Stage instantiation------
 peline_stage_mod #(.WIDTH(36),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )MREG_stage (.in(Multiplier_out),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEM),  // clock enable
                                .rst(RSTM),    // reset signal
                                .sel(MREG),   // selction of the mux
                                .out(Multiplier_out_1)      // output of the mux
                               );
 assign M = Multiplier_out_1;  /* M output Port */


 wire [47:0]X_out;      /* MUX X output */
 //------MUX_X instantiation------
 Mux1_4 MUX_X    (.in0({48{0}}),   // [47:0]input0
                  .in1({12'b0,Multiplier_out_1}),   // [47:0]input1
                  .in2(P),   // [47:0]input2
                  .in3({D_1[11:0],A_2,B_2}),   // [47:0]input3
                  .sel(OPMODE_1[1:0]),   // 00->out=in0,01->out=in1,10->out=in2,11->out=in3
                  .out(X_out)    // [47:0]output
                 );

 wire [47:0]Z_out;      /* MUX Z output */
 //------MUX_Z instantiation------
 Mux1_4 MUX_Z    (.in0({48{0}}),   // [47:0]input0
                  .in1(PCIN),   // [47:0]input1
                  .in2(P),   // [47:0]input2
                  .in3(C_1),   // [47:0]input3
                  .sel(OPMODE_1[3:2]),   // 00->out=in0,01->out=in1,10->out=in2,11->out=in3
                  .out(Z_out)    // [47:0]output
                 ); 

 wire CARRYIN_0;        /* output of the cin mux after checking Carry in will be OPMODE[5] or CARRYIN */                                
 // check CARRYINSEL parameter to detect if there is BCIN or not */
 assign CARRYIN_0 =(CARRYINSEL=="OPMODE5")?  OPMODE_1[5] :
                   (CARRYINSEL=="CARRYIN")? CARRYIN : 0;
 wire CARRYIN_1; /* output of the pipeline stage of CARRYIN input Port */
 //------CARRYINREG Stage instantiation------
 peline_stage_mod #(.WIDTH(1),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )CYI_stage (.in(CARRYIN_0),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CECARRYIN),  // clock enable
                                .rst(RSTCARRYIN),    // reset signal
                                .sel(CARRYINREG),   // selction of the mux
                                .out(CARRYIN_1)      // output of the mux
                               );

 wire [47:0]post_add_sub_out;   /* output of post-adder/substracter */
 wire post_add_sub_cout;   /* carry output of post-adder/substracter */
 //------Post-adder/substracter instantiation------
 Post_adder_substracter Post_add_substract(.in0(Z_out),     // [47:0]in0
                                           .in1(X_out),     // [47:0]in1
                                           .cin(CARRYIN_1),     // carry in input
                                           .add_sub(OPMODE_1[7]), // 0-> ADDITION  1-> SUBSTRACTION
                                           .out(post_add_sub_out),     // [17:0]out = in0 "+/-" (in1+cin)
                                           .cout(post_add_sub_cout)     // carry out output
                                          );

 //------CARRYOUTREG Stage instantiation------
 peline_stage_mod #(.WIDTH(1),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )CYO_stage (.in(post_add_sub_cout),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CECARRYIN),  // clock enable
                                .rst(RSTCARRYIN),    // reset signal
                                .sel(CARRYOUTREG),   // selction of the mux
                                .out(CARRYOUT)      // output of the mux
                               );
 assign CARRYOUTF = CARRYOUT;       /* CARRYOUTF is the same CARRYOUT. CARRYOUTF sent to cascaded DSP */ 

 //------PREG Stage instantiation------
 peline_stage_mod #(.WIDTH(48),     // parameter defines the width of input and output
                   .RSTTYPE(RSTTYPE) // parameter defines the type of rst, takes SYNC or ASYNC
                  )PREG_stage (.in(post_add_sub_out),        // [Width-1:0]input
                                .clk(clk),     // clock input
                                .clk_en(CEP),  // clock enable
                                .rst(RSTP),    // reset signal
                                .sel(PREG),   // selction of the mux
                                .out(P)      // output of the mux
                               );
 assign PCOUT = P;       /* PCOUT is the same P */ 

    
endmodule