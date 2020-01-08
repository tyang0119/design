`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2017 02:07:50 PM
// Design Name: 
// Module Name: Axi4LiteRegs
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


module Axi4LiteRegs #
        (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
        (
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output      S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output      S_AXI_WREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output      S_AXI_ARREADY,
        output      [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output      [1:0] S_AXI_RRESP,
        output      S_AXI_RVALID,
        input       S_AXI_RREADY,
        output      [1:0] S_AXI_BRESP,
        output      S_AXI_BVALID,
        input       S_AXI_BREADY
    
    );

//Axi4Lite wires


// Simple Bus signals
wire    [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
wire                                wr ;
//wire                                wrDone ;
wire    [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    rdData ;
wire                                rd ;
//wire                                rdDone ;

//register signals

reg[C_S_AXI_DATA_WIDTH-1:0] reg0D, reg0Q, reg1D, reg1Q;


// Axi4Lite Supporter instantiation
Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
    // Simple Bus
    .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wr),                            // output
    .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdData),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .rd(rd),                            // output   
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
    
always @ * begin
    //defaults  
    reg0D = reg0Q;
    reg1D = reg1Q;
    
    rdData = 0;
    if(rd) begin
        case(rdAddr)
            0: begin
                rdData = reg0Q;
            end
            4: begin
                rdData = reg1Q;
            end
            default: begin
                rdData = 99;
            end
        endcase
    end else if(wr) begin
        case(wrAddr)
            0: begin
                reg0D = wrData;
            end
            4: begin
                reg1D = wrData;
            end
            default: begin
                
            end
        endcase
    end
    
    
end
    
always @ (posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            reg0Q <= 0 ;
            reg1Q <= 0 ;
        end else begin
            reg0Q <= reg0D ;
            reg1Q <= reg1D ;
        end
    end     
    

endmodule
