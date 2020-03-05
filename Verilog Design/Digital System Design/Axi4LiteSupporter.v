`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2017 01:45:01 PM
// Design Name: 
// Module Name: Axi4LiteSupporter
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


module Axi4LiteSupporter # 
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        output reg  [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
        output reg  [C_S_AXI_DATA_WIDTH-1:0] wrData,
        output reg  wr,
        output reg  [C_S_AXI_ADDR_WIDTH-1:0] rdAddr,
        input       [C_S_AXI_DATA_WIDTH-1:0] rdData,
        output reg  rd,
        // Axi4Lite Bus
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output reg  S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output reg  S_AXI_WREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output reg  S_AXI_ARREADY,
        output reg  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output reg  [1:0] S_AXI_RRESP,
        output reg  S_AXI_RVALID,
        input       S_AXI_RREADY,
        output reg  [1:0] S_AXI_BRESP,
        output reg  S_AXI_BVALID,
        input       S_AXI_BREADY
    );
    //fsm
parameter IDLE = 0, RD1 = 1;
reg[3:0] currentState, nextState;
//read flops
reg[C_S_AXI_ADDR_WIDTH-1:0] rdAddrD, rdAddrQ;

always @ * begin
    //defaults
    nextState = currentState; 
    rdAddrD = rdAddrQ;
    //simple bus
    wrAddr = 0;
    wrData = 0;
    wr = 0;
    rdAddr = 0;
    rd = 0;
    // Axi4Lite Bus   
    S_AXI_AWREADY = 0;
    S_AXI_WREADY = 0;
    S_AXI_ARREADY = 0;
    S_AXI_RDATA = 0;
    S_AXI_RRESP = 0;
    S_AXI_RVALID = 0;
    S_AXI_BRESP = 0;
    S_AXI_BVALID = 0;
    
    case(currentState)
        IDLE: begin
            if(S_AXI_ARVALID) begin
                rdAddrD = S_AXI_ARADDR;
                nextState = RD1;
            end
        end
        RD1: begin
            S_AXI_ARREADY = 1;
            S_AXI_RVALID = 1;
            rd = 1;
            S_AXI_RDATA = rdData;
            rdAddr = rdAddrQ;
            if(S_AXI_RREADY) begin
                nextState = IDLE;
            end
        end
        default: begin
            nextState = IDLE;
        end
    endcase
end

always @ (posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        currentState <= IDLE ;
        rdAddrQ <= 0 ;
    end else begin
        currentState <= nextState;
        rdAddrQ <= rdAddrD;
    end
end 


   
endmodule
