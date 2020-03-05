module Axi4LiteSPI # 
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
    input       SDO,
    output reg  SDI,
    output reg  SCK,
    output reg  CONV
    //output reg  PIN1,
    //output reg  PIN2
    );
    parameter SETUP=0,CONVERT=1,RW=2,DISABLE=3;
    wire[C_S_AXI_ADDR_WIDTH-1:0] wrAddr,rdAddr;
    wire wr,rd;
    wire[C_S_AXI_DATA_WIDTH-1:0] wrData;
    reg[C_S_AXI_DATA_WIDTH-1:0] rdData,SDIDataD,SDIDataQ,SDODataD,SDODataQ;
    reg[14:0] SampleRateD,SampleRateQ;
    reg[4:0] ndbD,ndbQ;
    reg[14:0] ConvLengthD,ConvLengthQ;
    reg[14:0] MCountD,MCountQ;
    reg[2:0] SCKCountD,SCKCountQ;
    reg[4:0] DBCountD,DBCountQ;
    reg[1:0] currentState,nextState;
    reg MCountRst,MCountEN,SCKCountRst,SCKCountEN,DBCountRst,DBCountEN,freshDataD,freshDataQ,DFlagD,DFlagQ;
//    reg ;
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
        
always @ (posedge S_AXI_ACLK) begin
    if(!S_AXI_ARESETN)begin
        currentState<=SETUP;
        SampleRateQ<=0;
        ndbQ<=0;
        ConvLengthQ<=0;
        MCountQ<=0;
        SCKCountQ<=0;
        DBCountQ<=0;
        SDIDataQ<=0;
        SDODataQ<=0;
        freshDataQ<=0;
        DFlagQ<=0;
    end else begin
        currentState<=nextState;
        SampleRateQ<=SampleRateD;
        ndbQ<=ndbD;
        ConvLengthQ<=ConvLengthD;
        SDIDataQ<=SDIDataD;
        SDODataQ<=SDODataD;
        freshDataQ<=freshDataD;
        DFlagQ<=DFlagD;
        
        if(MCountRst)begin
            MCountQ<=0;
        end else if (MCountEN)begin
            MCountQ<=MCountD;
        end
        
        if(SCKCountRst)begin
            SCKCountQ<=0;
        end else if(SCKCountEN)begin
            SCKCountQ<=SCKCountD;
        end
        
        if(DBCountRst)begin
            DBCountQ<=ndbQ;
        end else if (DBCountEN)begin
            DBCountQ<=DBCountD;
        end
    end
end

always @ * begin
    nextState=currentState;
    SampleRateD=SampleRateQ;
    ndbD=ndbQ;
    
    //Calculate the number of clock cycles that the device needs to stay
    //in the Convert state to meet sample rate
    ConvLengthD=SampleRateQ-(6*ndbQ+3);
    
    MCountD=MCountQ+1;
    SCKCountD=SCKCountQ+1;
    DBCountD=DBCountQ-1;
    MCountRst=0;
    MCountEN=0;
    SCKCountRst=0;
    SCKCountEN=0;
    DBCountRst=0;
    DBCountEN=0;
    SCK=0;
    CONV=0;
    SDIDataD=SDIDataQ;
    SDODataD=SDODataQ;
    freshDataD=freshDataQ;
    DFlagD=DFlagQ;
    
    //Reset the Main counter when it reaches the designated number
    if(MCountQ==SampleRateQ-1)begin
        MCountRst=1;
    end
    
    case(currentState)
        SETUP: begin
            //Setup data is written to the device, with the bottom 5 bits
            //as the number of data bits and the middle 15 bits as the 
            //number of clock cycles for each sample to represent
            //the sampling rate
            if(wr)begin
                ndbD=wrData[4:0];
                SampleRateD=wrData[19:5];
                CONV=1;
                nextState=CONVERT;
            end
        end
        CONVERT: begin
            //Enbale the Main Counter and go to Read/Write state when it
            //reaches a calculated number
            MCountEN=1;
            CONV=1;
            if(MCountQ==ConvLengthQ)begin
                CONV=0;
                nextState=RW;
                SCKCountEN=1;
            end
        end        
        RW: begin
            //Enable the counters to start operation in the Read/Write state
            MCountEN=1;
            SCKCountEN=1;
            //After the operations are complete, set the valid bit and
            //go back to Convert state for the next cycle
            if(MCountRst)begin
                CONV=1;
                SCKCountRst=1;
                if(DFlagQ)begin
                    nextState=DISABLE;
                end
                else begin
                    nextState=CONVERT;
                    freshDataD=1;
                end
            end
        end
        DISABLE: begin
            //Resume operation if written to address 0 again
            CONV=1;
            if(wr && wrAddr==0)begin
                SDIDataD=wrData;
                DFlagD=0;
                SCKCountRst=1;
                nextState=CONVERT;
            end
        end
    endcase
    
    //Since the number of data bits won't go over 24, the top two bits
    //are used as validity indicators
    //Bit 30 indicates that the data has not been read yet
    //Bit 31 indicates that the data is stable
    rdData[29:0]=SDODataQ[29:0];
    rdData[30]=freshDataQ;
    rdData[31]=CONV;
    
    //Reset the valid bit after one read; A read on state transition
    //is ignored 
    if(rd&!MCountRst)begin
        freshDataD=0;
    end
    
    //Device disabled if written to any address other than 0;
    //Clocks new data into the SDI Data Register if address is 0
    if(wr)begin
        if(wrAddr==0)begin
            SDIDataD=wrData;
        end else begin
            DFlagD=1;
        end
    end else begin
        SDIDataD=SDIDataQ;
    end
    
    //Capture a bit from SDO on the fourth clock cycle of a SCK cycle
    if(SCKCountQ==4)begin
        SDODataD[DBCountQ-1]=SDO;
    end
    
    //SCK is high for the last three cycles and low for the first three
    if(SCKCountQ>=3)begin
        SCK=1;
    end
    
    //Reset the Data Bit Counter/Pointer at the end of a read/write cycle
    if(DBCountQ==1 && SCKCountQ==5)begin
        DBCountRst=1;
    end
     if(DBCountQ==0)begin
        DBCountRst=1;
    end
    
    //Reset the SCK Counter to zero every six clock cycles and
    //decrease Data Bit Counter by one
    if(SCKCountQ==5)begin
        SCKCountRst=1;
        DBCountEN=1;
    end
    
    //Put the data bit from the SDI Data Register
    //corresponding to the Data Bit Counter onto the bus
    if(DBCountQ!=0)begin
        SDI=SDIDataQ[DBCountQ-1];
    end else begin
        SDI=0;
    end
    
end

endmodule