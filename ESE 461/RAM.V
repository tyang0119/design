`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2018 01:29:14 PM
// Design Name: 
// Module Name: ram_1
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


               

module v_rams_04 (clk, we, a, di, do);
    input clk;
    input we;
    input [5:0] a;
    input [15:0] di;
    output [15:0] do;
    reg [15:0] ram [279:0];;
    integer i = 0;

    initial begin
    for(i=0; i<61 ; i=i+1)begin
       ram[i]<=16'b0;
    end
    end
    
    always @(posedge clk) begin    
        if (we)
            ram[a] <= di;
        end

    assign do = ram[a];
    
endmodule