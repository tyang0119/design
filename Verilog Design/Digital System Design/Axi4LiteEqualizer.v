`timescale 1ns / 1ps

module Axi4LiteEqualizer # 
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
    input       S_AXI_BREADY,
    output      SCKADC,
    output      SDIADC,
    output      CONVADC,
    input       SDOADC,
    output      SCKDAC,
    output      SDIDAC,
    output      CONVDAC,
    input       SDODAC
    );
    
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr [0:2];
    reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData [0:2];
    reg                                 wr [0:2];
    wire                                wrDone [0:2];
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr [0:2];
    wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData [0:2];
    reg                                 rd [0:2];
    wire                                rdDone [0:2];
    wire SCK [0:1];
    wire SDI [0:1];
    wire SDO [0:1];
    wire CONV [0:1];
    reg signed [15:0] attD [0:12];
    reg signed [15:0] attQ [0:12];
    assign SCKADC=SCK[0];
    assign SCKDAC=SCK[1];
    assign SDIADC=SDI[0];
    assign SDIDAC=SDI[1];
    assign SDO[0]=SDOADC;
    assign SDO[1]=SDODAC;
    assign CONVADC=CONV[0];
    assign CONVDAC=CONV[1];
    wire [C_S_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR [0:2];
    wire M_AXI_AWVALID [0:2];
    wire M_AXI_AWREADY [0:2];
    wire [C_S_AXI_DATA_WIDTH-1:0] M_AXI_WDATA [0:2];
    wire [3:0] M_AXI_WSTRB [0:2];
    wire M_AXI_WVALID [0:2];
    wire M_AXI_WREADY [0:2];
    wire [C_S_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR [0:2];
    wire M_AXI_ARVALID [0:2];
    wire M_AXI_ARREADY [0:2];
    wire [C_S_AXI_DATA_WIDTH-1:0] M_AXI_RDATA [0:2];
    wire [1:0] M_AXI_RRESP [0:2];
    wire M_AXI_RVALID [0:2];
    wire M_AXI_RREADY [0:2];
    wire [1:0] M_AXI_BRESP [0:2];
    wire M_AXI_BVALID [0:2];
    wire M_AXI_BREADY [0:2];
    wire  [C_S_AXI_ADDR_WIDTH-1:0] wrAddrin;
    wire  [C_S_AXI_DATA_WIDTH-1:0] wrDatain;
    wire  wrin;
    wire  [C_S_AXI_ADDR_WIDTH-1:0] rdAddrin;
    reg  [C_S_AXI_DATA_WIDTH-1:0] rdDatain;
    wire  rdin;
//    reg [31:0] AttD;
//    reg [31:0] AttQ;
    reg [1:0] paramCountD,paramCountQ;
    reg [2:0] currentState,nextState;
    reg [3:0] bandCountD,bandCountQ;
    reg [9:0] tapCountD,tapCountQ;
    reg [15:0] FIRDataD,FIRDataQ;
    reg [3:0] waitCounterD,waitCounterQ;
    reg channelD,channelQ;
    integer i;
    wire signed [15:0] filtered [0:12];
    reg signed [15:0] sum;
    wire signed [31:0] round;
    reg signed [31:0] mid[0:12];
    reg signed [15:0] midB[0:12];
    assign round = 32'h00004000;
    
    Axi4LiteFIR #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) FIR1
        (
            .S_AXI_ACLK(S_AXI_ACLK),            // input
            .S_AXI_ARESETN(S_AXI_ARESETN),      // input
            .S_AXI_AWADDR(M_AXI_AWADDR[2]),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
            .S_AXI_AWVALID(M_AXI_AWVALID[2]),      // input
            .S_AXI_AWREADY(M_AXI_AWREADY[2]),      // output
            .S_AXI_WDATA(M_AXI_WDATA[2]),          // input    [C_S_AXI_DATA_WIDTH-1:0]
            .S_AXI_WSTRB(M_AXI_WSTRB[2]),          // input    [3:0]
            .S_AXI_WVALID(M_AXI_WVALID[2]),        // input
            .S_AXI_WREADY(M_AXI_WREADY[2]),        // output        
            .S_AXI_ARADDR(M_AXI_ARADDR[2]),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
            .S_AXI_ARVALID(M_AXI_ARVALID[2]),      // input
            .S_AXI_ARREADY(M_AXI_ARREADY[2]),      // output
            .S_AXI_RDATA(M_AXI_RDATA[2]),          // output   [C_S_AXI_DATA_WIDTH-1:0]
            .S_AXI_RRESP(M_AXI_RRESP[2]),          // output   [1:0]
            .S_AXI_RVALID(M_AXI_RVALID[2]),        // output    
            .S_AXI_RREADY(M_AXI_RREADY[2]),        // input
            .S_AXI_BRESP(M_AXI_BRESP[2]),          // output   [1:0]
            .S_AXI_BVALID(M_AXI_BVALID[2]),        // output
            .S_AXI_BREADY(M_AXI_BREADY[2]),         // input
            .band1(filtered[0]),
            .band2(filtered[1]),
            .band3(filtered[2]),
            .band4(filtered[3]),
            .band5(filtered[4]),
            .band6(filtered[5]),
            .band7(filtered[6]),
            .band8(filtered[7]),
            .band9(filtered[8]),
            .band10(filtered[9]),
            .band11(filtered[10]),
            .band12(filtered[11]),
            .band13(filtered[12])
        );
    
    genvar j;
    generate
    for (j=0;j<3;j=j+1) begin:Manager
        Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
            (
                // Simple Bus
                .wrAddr(wrAddr[j]),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
                .wrData(wrData[j]),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
                .wr(wr[j]),                            // input    
                .wrDone(wrDone[j]),                    // output
                .rdAddr(rdAddr[j]),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
                .rdData(rdData[j]),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
                .rd(rd[j]),                            // input
                .rdDone(rdDone[j]),                    // output
                // Axi4Lite Bus
                .M_AXI_ACLK(S_AXI_ACLK),            // input
                .M_AXI_ARESETN(S_AXI_ARESETN),      // input
                .M_AXI_AWADDR(M_AXI_AWADDR[j]),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
                .M_AXI_AWVALID(M_AXI_AWVALID[j]),      // output
                .M_AXI_AWREADY(M_AXI_AWREADY[j]),      // input
                .M_AXI_WDATA(M_AXI_WDATA[j]),          // output   [C_M_AXI_DATA_WIDTH-1:0]
                .M_AXI_WSTRB(M_AXI_WSTRB[j]),          // output   [3:0]
                .M_AXI_WVALID(M_AXI_WVALID[j]),        // output
                .M_AXI_WREADY(M_AXI_WREADY[j]),        // input
                .M_AXI_ARADDR(M_AXI_ARADDR[j]),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
                .M_AXI_ARVALID(M_AXI_ARVALID[j]),      // output
                .M_AXI_ARREADY(M_AXI_ARREADY[j]),      // input
                .M_AXI_RDATA(M_AXI_RDATA[j]),          // input    [C_M_AXI_DATA_WIDTH-1:0]
                .M_AXI_RRESP(M_AXI_RRESP[j]),          // input    [1:0]
                .M_AXI_RVALID(M_AXI_RVALID[j]),        // input
                .M_AXI_RREADY(M_AXI_RREADY[j]),        // output
                .M_AXI_BRESP(M_AXI_BRESP[j]),          // input    [1:0]
                .M_AXI_BVALID(M_AXI_BVALID[j]),        // input
                .M_AXI_BREADY(M_AXI_BREADY[j])         // output
            ); 
        end
        for (j=0;j<2;j=j+1) begin:SPIInterface
        Axi4LiteSPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSPI1
            (
                // Axi4Lite Bus
                .S_AXI_ACLK(S_AXI_ACLK),            // input
                .S_AXI_ARESETN(S_AXI_ARESETN),      // input
                .S_AXI_AWADDR(M_AXI_AWADDR[j]),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
                .S_AXI_AWVALID(M_AXI_AWVALID[j]),      // input
                .S_AXI_AWREADY(M_AXI_AWREADY[j]),      // output
                .S_AXI_WDATA(M_AXI_WDATA[j]),          // input    [C_S_AXI_DATA_WIDTH-1:0]
                .S_AXI_WSTRB(M_AXI_WSTRB[j]),          // input    [3:0]
                .S_AXI_WVALID(M_AXI_WVALID[j]),        // input
                .S_AXI_WREADY(M_AXI_WREADY[j]),        // output        
                .S_AXI_ARADDR(M_AXI_ARADDR[j]),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
                .S_AXI_ARVALID(M_AXI_ARVALID[j]),      // input
                .S_AXI_ARREADY(M_AXI_ARREADY[j]),      // output
                .S_AXI_RDATA(M_AXI_RDATA[j]),          // output   [C_S_AXI_DATA_WIDTH-1:0]
                .S_AXI_RRESP(M_AXI_RRESP[j]),          // output   [1:0]
                .S_AXI_RVALID(M_AXI_RVALID[j]),        // output    
                .S_AXI_RREADY(M_AXI_RREADY[j]),        // input
                .S_AXI_BRESP(M_AXI_BRESP[j]),          // output   [1:0]
                .S_AXI_BVALID(M_AXI_BVALID[j]),        // output
                .S_AXI_BREADY(M_AXI_BREADY[j]),        // input
                .SCK(SCK[j]),
                .SDI(SDI[j]),
                .SDO(SDO[j]),
                .CONV(CONV[j])
            );
    end
    endgenerate
    
    // Axi4Lite Supporter instantiation
    Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
        //Simple Bus
        .wrAddr(wrAddrin),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
        .wrData(wrDatain),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
        .wr(wrin),                            // output
        .rdAddr(rdAddrin),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
        .rdData(rdDatain),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .rd(rdin),                            // output   
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

    parameter SETUP_PARAM=0,SETUP_FILTER=1,SPI=2,FIR=3,WAIT=4;
    
    always @ * begin
        for(i=0;i<3;i=i+1)begin
            wr[i]=0;
            rd[i]=0;
            wrAddr[i]=0;
            wrData[i]=0;
            rdAddr[i]=0;
        end
        nextState=currentState;
        paramCountD=paramCountQ;
        bandCountD=bandCountQ;
        tapCountD=tapCountQ;
        channelD=channelQ;
//        AttD=AttQ;
        FIRDataD=FIRDataQ;
        waitCounterD=waitCounterQ;
        for(i=0;i<13;i=i+1)begin
            attD[i]=attQ[i];
            mid[i]=attQ[i]*filtered[i]+round;
            midB[i]=mid[i][30:15];
        end
        sum=midB[0]+midB[1]+midB[2]+midB[3]+midB[4]+midB[5]+midB[6]+midB[7]+midB[8]+midB[9]+midB[10]+midB[11]+midB[12];
        
        if(wrin)begin
            case (wrAddrin)
                4:begin
                    attD[0]=wrDatain;
                end
                8:begin
                    attD[1]=wrDatain;
                end
                12:begin
                    attD[2]=wrDatain;
                end
                16:begin
                    attD[3]=wrDatain;
                end
                20:begin
                    attD[4]=wrDatain;
                end
                24:begin
                    attD[5]=wrDatain;
                end
                28:begin
                    attD[6]=wrDatain;
                end
                32:begin
                    attD[7]=wrDatain;
                end
                36:begin
                    attD[8]=wrDatain;
                end
                40:begin
                    attD[9]=wrDatain;
                end
                44:begin
                    attD[10]=wrDatain;
                end
                48:begin
                    attD[11]=wrDatain;
                end
                52:begin
                    attD[12]=wrDatain;
                end
                default:begin
                end
            endcase
        end
        
        case (currentState)
            SETUP_PARAM:begin
                if (paramCountQ>=3) begin
                    //Disable not working as intended, need to disable after around 300 clock cycles
                    wr[0]=1;
                    wrAddr[0]=4;
                    wrData[0]=0;
                    wr[1]=1;
                    wrAddr[1]=4;
                    wrData[1]=0;
                    nextState=SETUP_FILTER;
                end
                if (wrin) begin
                    paramCountD=paramCountQ+1;
                    case (paramCountQ)
                        0:begin
                            wr[0]=1;
                            wrAddr[0]=0;
                            wrData[0]=wrDatain;
                        end
                        1:begin
                            wr[0]=1;
                            wrAddr[0]=0;
                            wrData[0]=32'h00008000;
                            wr[1]=1;
                            wrAddr[1]=0;
                            wrData[1]=wrDatain;
                        end
                        2:begin
                            wr[1]=1;
                            wrAddr[1]=0;
                            wrData[1]=32'h005f0000;
                            wr[2]=1;
                            wrAddr[2]=0;
                            wrData[2]=wrDatain;
                        end
                        default:begin
                        end
                    endcase
                end
            end
            SETUP_FILTER:begin
                if (bandCountQ>=13) begin
                    wr[0]=1;
                    wrAddr[0]=0;
                    wrData[0]=32'h00008000;
                    wr[1]=1;
                    wrAddr[1]=0;
                    wrData[1]=32'h005f0000;
                    nextState=SPI;
                end else if (wrin) begin
                    wr[2]=1;
                    wrAddr[2]=0;
                    wrData[2]=wrDatain;
                    if(tapCountQ>=278)begin
                        bandCountD=bandCountQ+1;
                        tapCountD=0;
                    end else begin
                        tapCountD=tapCountQ+1;
                    end
                end
            end
            SPI:begin
                rd[0]=1;
                if(rdData[0][31] && rdData[0][30])begin
                    nextState=FIR;
                    rd[0]=0;
                    wr[2]=1;
                    wrAddr[2]=0;
                    wrData[2][31:16]=0;
                    wrData[2][15:0]={~rdData[0][15],rdData[0][14:0]};
                end
            end
            FIR:begin
                rd[2]=1;
                if(rdData[2][31])begin
                    nextState=WAIT;
                    wr[0]=1;
                    wrAddr[0]=0;
                    wrData[0]=32'h00008000;
                    wrData[0][14]=channelQ;
                    FIRDataD={~sum[15],sum[14:0]};
                end
            end
            WAIT:begin
                if (waitCounterQ == 12) begin
                    nextState = SPI;
                    waitCounterD = 0;
                    wr[1]=1;
                    wrAddr[1]=0;
                    wrData[1]=32'h00300000;
                    wrData[1][15:0]=FIRDataQ[15:0];
                    wrData[1][16]=channelQ;
                    channelD=!channelQ;
                end else begin
                    waitCounterD = waitCounterQ + 1;
                end
            end
            default:begin
                nextState=SETUP_PARAM;
            end
        endcase
        
//        if (wrin && wrAddrin!=0) begin
//            if(rdData[0][31] || wrDone[2]) begin
//                AttD[15:0]=wrDatain[15:0];
//                AttD[21:16]=wrAddrin;
//            end else begin
//                wr[2]=1;
//                rd[2]=0;
//                wrAddr[2]=wrAddrin;
//                wrData[2][15:0]=wrDatain[15:0];
//            end
//        end
        
//        if (AttQ!=0)begin
//            if(!wrDone[2])begin
//                wr[2]=1;
//                wrAddr[2]=AttQ[21:16];
//                wrData[2][15:0]=AttQ[15:0];
//                AttD=0;
//            end
//        end
    end
    
    always @ (posedge S_AXI_ACLK) begin
        if(!S_AXI_ARESETN)begin
            for(i=0;i<13;i=i+1)begin
                attQ[i]<=16'h7fff;
            end
            currentState<=SETUP_PARAM;
            paramCountQ<=0;
            bandCountQ<=0;
            tapCountQ<=0;
            channelQ<=0;
//            AttQ<=0;
            FIRDataQ<=0;
            waitCounterQ<=0;
        end else begin
            for(i=0;i<13;i=i+1)begin
                attQ[i]<=attD[i];
            end
            currentState<=nextState;
            paramCountQ<=paramCountD;
            bandCountQ<=bandCountD;
            tapCountQ<=tapCountD;
            channelQ<=channelD;
//            AttQ<=AttD;
            FIRDataQ<=FIRDataD;
            waitCounterQ<=waitCounterD;
        end
    end


endmodule