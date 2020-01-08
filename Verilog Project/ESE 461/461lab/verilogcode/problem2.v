`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 08:41:56 PM
// Design Name: 
// Module Name: problem2
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


module problem2();
    
reg[2:0] a;
reg[2:0] i;
wire w_0,w_1,w_2,s,c_out;
    
xor U1(w_0,a[0],a[1]);//a[0]=a,a[1]=b,a[2]=c_in
xor U2(s,w_0,a[2]);
and U3(w_1,w_0,a[2]);
and U4(w_2,a[0],a[1]);
or U5(c_out,w_1,w_2);
    
initial begin
$monitor("a[0]=%b,a[1]=%b,a[2]=%b",a[0],a[1],a[2]);
for(i=0; i<=8;i=i+1)begin
    a=i;
    #1;
end
$stop;    
    
end
endmodule
