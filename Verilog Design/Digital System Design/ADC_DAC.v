`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2017 01:42:51 PM
// Design Name: 
// Module Name: ADC_DAC
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


module ADC_DAC #
(parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
(
        // Axi4Lite Bus
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output   S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output   S_AXI_WREADY,
        output   [1:0] S_AXI_BRESP,
        output   S_AXI_BVALID,
        input       S_AXI_BREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output   S_AXI_ARREADY,
        output   [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output   [1:0] S_AXI_RRESP,
        output   S_AXI_RVALID,
        input       S_AXI_RREADY,
        
        output reg CS_,
        output reg sdi,
        output reg sck,
        input sdo
    );
    
    wire     [C_S_AXI_ADDR_WIDTH-1:0]   wrAddr ;
    wire     [C_S_AXI_DATA_WIDTH-1:0]   wrData ;
    wire                                wr ;
 
    wire     [C_S_AXI_ADDR_WIDTH-1:0]   rdAddr ;
    reg    [C_S_AXI_DATA_WIDTH-1:0]     rdData ;
    wire                                rd ;


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
        .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID),        // output
        .S_AXI_BREADY(S_AXI_BREADY),        // input
        .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY),      // output
        .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID),        // output    
        .S_AXI_RREADY(S_AXI_RREADY)         // input
        ) ;

reg [15:0] CounterD, CounterQ;
reg [15:0] counterLD, counterLQ;
reg [15:0] cycleCounterD, cycleCounterQ ;
reg [4:0] lengthD, lengthQ;
reg [31:0] resultD, resultQ ;
reg [15:0] clkD, clkQ ;
reg [31:0] ChaD, ChaQ;
        
parameter SETUP = 0, IDLE = 1, CO = 2, SCKL = 3, SCKH = 4 ;
reg [3:0] nextState, currentState ;

always @ * begin
    rdData = resultQ;
    sck =0;
    sdi=0;
    CS_ =0;
    lengthD =lengthQ;
    ChaD =ChaQ;
    clkD =clkQ;
    CounterD = CounterQ;
    counterLD = counterLQ;
    resultD = resultQ ;    
    cycleCounterD = cycleCounterQ;
    nextState = currentState ;
    
    case (currentState)
        Setup: begin
            if(wr)begin
                case(wrAddr)
                    1:begin
                        clkD = wrData[15:0];
                        cycleCounterD  = wrData[15:0];
                    end
                    2:begin
                        lengthD=wrData;
                        nextState=IDLE;
                    end
                endcase
            end
            else begin
                nextState=Setup;
            end
        end
		
        IDLE: begin
            cycleCounterD=cycleCounterQ+1;
            CS_=1;
            if(wr && wrAddr == 3)begin
                  chaD=wrData;
				  resultD[31]=0;
            end
			if (wrAddr == 4) begin
                nextState = SETUP ;
            if(cycleCounterQ == clkQ-1)begin
                nextState = SCKL;
                cycleCounterD = 0;
           end
           else begin
                nextState=IDLE;
           end
        end		

        CO: begin  
            cycleCounterD = cycleCounterQ+1;
            CS_ = 0;
            sdi = ChaD[lengthD -counterLD-1];         
            resultD[31]=0;
            nextState = SCKL ;
            nextState = SCKL ;
            CounterD = 0;
            counterLD =0;
        end

        SCKL: begin 
            cycleCounterD = cycleCounterQ+1;        
            sdi = ChaD[lengthD - counterLD-1];            
            sck = 0 ;            
            CounterD = CounterQ + 1 ;
            if (CounterD >= 3) begin
                nextState = SCKH ;
                CounterD = 0 ;                
            end
        end

        SCKH: begin
            cycleCounterD = cycleCounterQ+1;
            sdi = ChaD[lengthD - counterLD-1];
            resultD[lengthD - counterLD-1 ] = sdo ;
            sck = 1 ;
            CounterD = CounterQ + 1 ;
            if (CounterD == 0) begin
                counterLD = counterLQ + 1 ;
            end
            if (CounterD == 3) begin
                 counterLD = counterLQ + 1 ;
                 nextState = SCKL ;
                 CounterD = 0 ;
                 if (counterLD >= lengthD) begin
                     resultD[31]=1;
                     nextState = IDLE ;
                     counterLD = 0 ;
                     CounterD = 0 ;
                 end
            end   
            else begin
                nextState = SCKH;
            end            
        end

    endcase
end

always @ (posedge S_AXI_ACLK) begin
    if ( !S_AXI_ARESETN ) begin
        currentState <= SETUP ;
        clkQ <=0;
        resultQ <= 0 ;
        cycleCounterQ <= 0;
        CounterQ<=0;
        counterLQ<=0;
        lengthQ <=0;
        ChaQ <=0;
    end else begin
        lengthQ <= lengthD;
        cycleCounterQ <= cycleCounterD ;
        ChaQ <=ChaD;
        currentState <= nextState ;
        clkQ <=clkD;
        resultQ <= resultD ;
        CounterQ<=CounterD;
        counterLQ<=counterLD;
    end
end

endmodule
