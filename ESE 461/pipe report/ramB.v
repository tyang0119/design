`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


               

module ramB_2 (clk, we, a, di, do);
    input clk;
    input we;
    input [5:0] a;
    input [15:0] di;
    output [15:0] do;
    reg [15:0] ram [9:0];
    integer i = 0;

    initial begin
    for(i=0; i<10 ; i=i+1)begin
       ram[i]<=16'b0;
    end
    end
    
    always @(posedge clk) begin    
        if (we) 
            ram[a] <= di;
        end


    assign do = ram[a];
    
endmodule