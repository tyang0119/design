`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 09:39:52 PM
// Design Name: 
// Module Name: problem4_tb
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


module problem4_tb();

reg clk;
reg d;
wire q;
wire q_bar;

problem4 problem4(
.d(d),
.clk(clk),
.q(q),
.q_bar(q_bar)
);

initial begin
d = 0;
clk = 0;
end

always #10 clk=~clk;

initial begin
#20 d = 1; 
#20 d = 0;

#20 d = 1; 
#20 d = 0;

#20 d = 1; 
#20 d = 0;

#40 $stop;
end
endmodule
