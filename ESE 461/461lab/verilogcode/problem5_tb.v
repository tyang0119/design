`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 10:08:22 PM
// Design Name: 
// Module Name: problem5_tb
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


module problem5_tb(
);

reg reset;
reg reg_0;
reg reg_1;
reg clock;

problem5 problem5(
.clock(clock),
.reset(reset),
.reg_0(reg_0),
.reg_1(reg_1)
);

always
begin
    clock<=1;
    #5;
    clock<=0;
    #5;
end

initial begin
reset=0;
reg_0=0;
reg_1=0;

#10 reg_0=1;
#10 reg_0=1;
#10 reg_0=0;
#10 reg_0=1;
#10 reset=1;

#10 reset=0;reg_0=0;reg_1=1;
#10 reg_1=1;
#10 reg_1=0;
#10 reg_1=1;
#10 reset=1;
#10 reset=0;reg_1=0;
#10;
$stop;
end
endmodule
