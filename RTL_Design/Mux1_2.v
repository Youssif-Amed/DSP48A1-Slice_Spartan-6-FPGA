module Mux1_2 (in0,in1,sel,out);
 /* default width of inputs and outputs */
 parameter WIDTH = 18; /* Default width */

 input  [WIDTH-1:0]in0,in1;
 input  sel;
 output [WIDTH-1:0]out;
 
 assign out=(sel)?in1 : in0;

endmodule

 /*
 //------module instantiation------
 Mux1_2 #(.WIDTH() // width of the inputs and output
         )module_name(.in0(), // [Width-1:0]input0
                      .in1(), // [Width-1:0]input1
                      .sel(), // 0 ->out=in0    1 ->out=in1
                      .out()  // [width-1:0]output
                      );
 */