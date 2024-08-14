module peline_stage_mod (in,clk,clk_en,rst,sel,out);
 parameter WIDTH = 18 ;       /* Width of the input and the output */
 /* type of the reset is sync or async. It takes SYNC or ASYNC */
 parameter RSTTYPE = "SYNC";  /* default reset type is synchronous */

 input  [WIDTH-1:0]in;
 input  clk,clk_en,sel,rst;
 output [WIDTH-1:0]out;

 reg [WIDTH-1:0]in_r;
 /* generate block according to RSTTYPE prameter */
 generate
    if(RSTTYPE=="SYNC")begin
        always @(posedge clk) begin
            if(rst)
                in_r <= 0;
            else begin
                if(clk_en)
                    in_r <= in;
            end
        end
    end
    else if(RSTTYPE=="ASYNC")begin
        always @(posedge clk or posedge rst) begin
            if(rst)
                in_r <= 0;
            else begin
                if(clk_en)
                    in_r <= in;
            end
        end
    end
 endgenerate
 /* mux design using assignment statement */
 assign out =(sel)? in_r : in;
endmodule 

/*
//------module instantiation------
peline_stage_mod #(.WIDTH(),  // parameter defines the width of input and output
                   .RSTTYPE() // parameter defines the type of rst, takes SYNC or ASYNC
                  )module_name (.in(),   // [Width-1:0]input
                              .clk(),    // clock input
                              .clk_en(), // clock enable
                              .rst(),    // reset signal
                              .sel(),    // selction of the mux
                              .out()     // output of the mux
                              );
*/