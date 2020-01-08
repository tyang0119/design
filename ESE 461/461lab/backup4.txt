`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 09:38:41 PM
// Design Name: 
// Module Name: problem4
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


module problem4(d,clk,q,q_bar);

input d;
input clk;
output q,q_bar;
wire d,clk;
reg q, q_bar;

always@ (posedge clk)
begin
	q<=d;
	q_bar<=!d;
end
endmodule
