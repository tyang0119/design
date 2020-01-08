`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2017 02:56:06 PM
// Design Name: 
// Module Name: Axi4liteRegs_tb
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


module Axi4liteRegs_tb();

// Axi4Lite Manager instantiation    
parameter C_S_AXI_ADDR_WIDTH = 4, C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33 ;

// Axi4Lite signals
reg  S_AXI_ACLK ;
reg  S_AXI_ARESETN ;
wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR ;
wire  S_AXI_AWVALID ;
wire S_AXI_AWREADY ;
wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA ;
wire  [3:0] S_AXI_WSTRB ;
wire  S_AXI_WVALID ;
wire S_AXI_WREADY ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR ;
wire  S_AXI_ARVALID ;
wire S_AXI_ARREADY ;
wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA ;
wire [1:0] S_AXI_RRESP ;
wire S_AXI_RVALID ;
wire  S_AXI_RREADY ;
wire [1:0] S_AXI_BRESP ;
wire S_AXI_BVALID ;
wire  S_AXI_BREADY ;
// Simple Bus signals
reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
reg                                 wr ;
wire                                wrDone ;
reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData ;
reg                                 rd ;
wire                                rdDone ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    rdDataQ ;

Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
        (
            // Simple Bus
            .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr),                            // input    
            .wrDone(wrDone),                    // output
            .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd),                            // input
            .rdDone(rdDone),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY),      // input
            .M_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID),        // output
            .M_AXI_WREADY(S_AXI_WREADY),        // input
            .M_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY),      // input
            .M_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID),        // input
            .M_AXI_RREADY(S_AXI_RREADY),        // output
            .M_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID),        // input
            .M_AXI_BREADY(S_AXI_BREADY)         // output
        );
        
//Axi4LiteRegs instantiation
Axi4LiteRegs #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteRegs1 (
            // Axi4Lite Bus
            .S_AXI_ACLK(S_AXI_ACLK),            // input
            .S_AXI_ARESETN(S_AXI_ARESETN),      // input
            .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
            .S_AXI_AWVALID(S_AXI_AWVALID),      // input
            .S_AXI_AWREADY(S_AXI_AWREADY),      // output
            .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
            .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
            .S_AXI_WVALID(S_AXI_WVALID),        // input
            .S_AXI_WREADY(S_AXI_WREADY),        // output        
            .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
            .S_AXI_ARVALID(S_AXI_ARVALID),      // input
            .S_AXI_ARREADY(S_AXI_ARREADY),      // output
            .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
            .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
            .S_AXI_RVALID(S_AXI_RVALID),        // output    
            .S_AXI_RREADY(S_AXI_RREADY),        // input
            .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
            .S_AXI_BVALID(S_AXI_BVALID),        // output
            .S_AXI_BREADY(S_AXI_BREADY)         // input
            ) ;


//// Axi4Lite Supporter instantiation        
//Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
//            // Simple Bus
//            .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
//            .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
//            .wr(wr),                            // output
//            .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
//            .rdData(rdData),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
//            .rd(rd),                            // output   
//            // Axi4Lite Bus
//            .S_AXI_ACLK(S_AXI_ACLK),            // input
//            .S_AXI_ARESETN(S_AXI_ARESETN),      // input
//            .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
//            .S_AXI_AWVALID(S_AXI_AWVALID),      // input
//            .S_AXI_AWREADY(S_AXI_AWREADY),      // output
//            .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
//            .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
//            .S_AXI_WVALID(S_AXI_WVALID),        // input
//            .S_AXI_WREADY(S_AXI_WREADY),        // output        
//            .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
//            .S_AXI_ARVALID(S_AXI_ARVALID),      // input
//            .S_AXI_ARREADY(S_AXI_ARREADY),      // output
//            .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
//            .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
//            .S_AXI_RVALID(S_AXI_RVALID),        // output    
//            .S_AXI_RREADY(S_AXI_RREADY),        // input
//            .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
//            .S_AXI_BVALID(S_AXI_BVALID),        // output
//            .S_AXI_BREADY(S_AXI_BREADY)         // input
//            ) ;
 
parameter CLK_PERIOD_2 = CLK_PERIOD/2;
//generate clock
always begin
    #(CLK_PERIOD_2) S_AXI_ACLK = ~S_AXI_ACLK;
end   

initial begin
    S_AXI_ACLK = 0;
    S_AXI_ARESETN = 0;
    wrAddr = 0;
    wrData = 0;
    wr = 0;
    rdAddr = 0;
    rd = 0;
    rdDataQ = 0;
    #(CLK_PERIOD_2 + 5) S_AXI_ARESETN = 1;
    #(CLK_PERIOD*10) ;
    rdAddr = 1*4 ;
    rd = 1;
    #(CLK_PERIOD) ;
    rdAddr = 0;
    rd = 0;
    #(CLK_PERIOD*10) ;
    $stop ;

end

endmodule
