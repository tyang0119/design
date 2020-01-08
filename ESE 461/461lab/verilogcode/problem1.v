`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 07:57:31 PM
// Design Name: 
// Module Name: problem1_testbench
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


module problem1_testbench();

reg[3:0] a;
reg[3:0] i;
wire out_0,out_1,y;

xor U1(out_0,a[0],a[1]);//a[0]=a,a[1]=b,a[2]=c,a[3]=d
xor U2(out_1,a[2],a[3]);
xor U3(y,out_0,out_1);

initial begin
$monitor("a[0]=%b,a[1]=%b,a[2]=%b,a[3]=%b",a[0],a[1],a[2],a[3]);
for(i=0; i<=15;i=i+1)begin
    a=i;
    #1;
end
$stop;
end
endmodule