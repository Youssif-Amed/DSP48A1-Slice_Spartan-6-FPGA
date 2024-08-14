module Post_adder_substracter (in0,in1,cin,add_sub,out,cout);
 input  [47:0]in0,in1;
 input  add_sub,cin;
 output reg [47:0]out;
 output reg cout;

 always @(*) begin
    /* if add_sub control is LOW, addition occurs */
    if(~add_sub)
        {cout,out} = in0 +(in1+cin);
    /* if add_sub control is LOW, Substraction occurs */
    else
        {cout,out} = in0 -(in1+cin);
 end
endmodule 

/*
//------module instantiation------
Post_adder_substracter Module_name(.in0(),     // [47:0]in0
                                   .in1(),     // [47:0]in1
                                   .cin(),     // carry in input
                                   .add_sub(), // 0-> ADDITION  1-> SUBSTRACTION
                                   .out(),     // [17:0]out = in0 "+/-" (in1+cin)
                                   .cout()     // carry out output
                                  );
*/

