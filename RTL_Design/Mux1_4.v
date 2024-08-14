module Mux1_4 (in0,in1,in2,in3,sel,out);
 
 input  [47:0]in0,in1,in2,in3;
 input  [1:0]sel;
 output reg [47:0]out;

 always @(*) begin
    case (sel)
        2'b00:  out=in0;
        2'b01:  out=in1;
        2'b10:  out=in2;
        2'b11:  out=in3;
    endcase
 end
endmodule

 /*
 //------module instantiation------
 Mux1_4 MUX_name (.in0(),   // [47:0]input0
                  .in1(),   // [47:0]input1
                  .in2(),   // [47:0]input2
                  .in3(),   // [47:0]input3
                  .sel(),   // 00->out=in0,01->out=in1,10->out=in2,11->out=in3
                  .out()    // [47:0]output
                 );
 */