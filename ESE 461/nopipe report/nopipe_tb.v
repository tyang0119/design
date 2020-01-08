`timescale 1ns / 1ps

module nopipe_tb();

    reg  [15:0] a;
    reg  [15:0] b;
    reg  clk;
    reg  reset;
    reg [3:0] wrAddr;
    reg [5:0] i;
    reg [5:0] j;
    reg [15:0] A1[9:0];
    reg [15:0] B1[9:0];

    wire [15:0] product;
    parameter clk_period = 20;
	//A = [ 1.25, 2.5, 2.5, 2, 3, 2, 1.25, 3.5, 4.5, 2]
	//B = [ 1.5, 1.5, 5, 2, 5, 3, 3.5, 5, 4, 3]


    nopipe nopipe(
        .clk(clk),
        .reset(reset),
        .A(a),
        .B(b),
        .wrAddr(wrAddr),
        .result(product)
        );

    initial
    begin
        $dumpfile("nopipe.vcd");
        $dumpvars(0, nopipe_tb);
A1[0]=16'h0140;
A1[1]=16'h0280;
A1[2]=16'h0280;
A1[3]=16'h0200;
A1[4]=16'h0300;
A1[5]=16'h0200;
A1[6]=16'h0140;
A1[7]=16'h0380;
A1[8]=16'h0480;
A1[9]=16'h0200;

B1[0]=16'h0180;
B1[1]=16'h0180;
B1[2]=16'h0500;
B1[3]=16'h0200;
B1[4]=16'h0500;
B1[5]=16'h0300;
B1[6]=16'h0380;
B1[7]=16'h0500;
B1[8]=16'h0400;
B1[9]=16'h0300;



        reset = 1;
        clk = 0;
        a = 0;
        b = 0;
        wrAddr = 0;

        // 1
        #(clk_period*3)
        reset = 0;
        wrAddr = 2;
        #(clk_period)
        for(i=0;i<10;i=i+1)begin
            wrAddr = 1;
            a = A1[i];
            b = B1[i];
            #(clk_period)
            wrAddr = 0;
            #(clk_period*5);
        end
		
        $finish;
    end

    always 
        #10 clk = !clk;

endmodule