module SRAM #(parameter size=64,AddrLength=6) (clk, we, a, di, do);

    input clk;
    input we;
    input [AddrLength-1:0] a;
    input [15:0] di;
    output reg [15:0] do;
    reg [15:0] ram [size-1:0];
    
always @(posedge clk) begin
    if (we)
        ram[a] <= di;
end

always @ * begin
    do = ram[a];
end
    
endmodule