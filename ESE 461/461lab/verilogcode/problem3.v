`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 08:55:43 PM
// Design Name: 
// Module Name: problem3
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


module problem3(s,r,q,q_bar);
output q, q_bar;
input s,r;

nor U1(q,r,q_bar);
nor U2(q_bar,s,q);
endmodule
