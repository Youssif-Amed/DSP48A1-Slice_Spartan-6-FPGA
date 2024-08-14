module Pre_adder_substracter (in0,in1,add_sub,out);
 input  [17:0]in0,in1;
 input  add_sub;
 output reg[17:0]out;

 always @(*) begin
    /* if add_sub control is LOW, addition occurs */
    if(~add_sub)
        out = in0 + in1;
    /* if add_sub control is LOW, Substraction occurs */
    else
        out = in0 - in1;
 end
endmodule 

/*
//------module instantiation------
Pre_adder_substracter Module_name(.in0(),     // [17:0]in0
                                   .in1(),     // [17:0]in1
                                   .add_sub(), // 0-> ADDITION  1-> SUBSTRACTION(in0-in1)
                                   .out()      // [17:0]out = in0 (+/-) in1
                                  );
*/

