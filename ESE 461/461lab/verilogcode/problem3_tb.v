`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 08:59:08 PM
// Design Name: 
// Module Name: problem3_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module problem3_tb();
wire q,q_bar;
reg s;
reg r;

problem3 problem3(
.q(q),
.q_bar(q_bar),
.s(s),
.r(r)
);

initial begin
$monitor("s=%b,r=%b,q=%b,q_bar=%b",s,r,q,q_bar);
s=0;r=0;

#5 s=0;r=1;
#5 s=0;r=0;

#5 r =0; s=1;
#5 s =0; r=0;

#5 s=1;r=1;

end
endmodule
