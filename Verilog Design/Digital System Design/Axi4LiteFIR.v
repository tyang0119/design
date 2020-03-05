`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2017 02:49:26 PM
// Design Name: 
// Module Name: Axi4LiteFIR
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


module Axi4LiteFIR#
        (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32, ADDR_WIDTH = 6, DATA_WIDTH = 16)
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
        output      [15:0] band1,
        output      [15:0] band2,
        output      [15:0] band3,
        output      [15:0] band4,
        output      [15:0] band5,
        output      [15:0] band6,
        output      [15:0] band7,
        output      [15:0] band8,
        output      [15:0] band9,
        output      [15:0] band10,
        output      [15:0] band11,
        output      [15:0] band12,
        output      [15:0] band13
        //output      reg0_0,
        //output      reg0_1
    
    );

//Axi4Lite wires


// Simple Bus signals
wire    [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
wire                                wr ;
wire    [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    rdData ;
wire                                rd ;

//bus to the ram
reg                        wr_F[0:12];
wire signed    [DATA_WIDTH-1:0]    data_out_F[0:12];
reg wr_IL,wr_IR;
reg signed    [DATA_WIDTH-1:0]    data_in_I;
wire signed    [DATA_WIDTH-1:0]    data_out_IL;
wire signed    [DATA_WIDTH-1:0]    data_out_IR;



reg [2:0] currentState, nextState;
reg [9:0] input_addrLD, input_addrLQ, input_addrRD, input_addrRQ, filter_addrD, filter_addrQ, ctrD, ctrQ;
reg [9:0] buffer_addrLQ, buffer_addrRQ, buffer_addrLD, buffer_addrRD;
reg [9:0] ram_addrL, ram_addrR;
reg [9:0] num_tapD, num_tapQ;
reg channelD, channelQ; // 0 is left, 1 is right

reg signed [C_S_AXI_DATA_WIDTH-1:0] sumD [0:25];
reg signed [C_S_AXI_DATA_WIDTH-1:0] sumQ [0:25];
reg signed [C_S_AXI_DATA_WIDTH-1:0] sumBuf [0:25];
//reg reg0_0, reg0_1;

reg signed [DATA_WIDTH-1:0] rdBufferD,rdBufferQ;

reg signed [15:0] mid [0:12];
reg signed [31:0] midB [0:12];

reg signed [15:0] attD [0:12];
reg signed [15:0] attQ [0:12];

reg signed [15:0] multD [0:12];
reg signed [15:0] multQ [0:12];

wire signed [31:0] round;
assign round = 32'h00004000;

assign band1=multQ[0];
assign band2=multQ[1];
assign band3=multQ[2];
assign band4=multQ[3];
assign band5=multQ[4];
assign band6=multQ[5];
assign band7=multQ[6];
assign band8=multQ[7];
assign band9=multQ[8];
assign band10=multQ[9];
assign band11=multQ[10];
assign band12=multQ[11];
assign band13=multQ[12];

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

    parameter size=1024;
    parameter AddrLength=10;

genvar j;
generate
    for (j=0;j<13;j=j+1) begin:RAMFilter
        SRAM #(.size(size),.AddrLength(AddrLength)) RAMFilter(
        .clk (S_AXI_ACLK),
        .we (wr_F[j]),
        .a (filter_addrQ),
        .di (wrData),
        .do (data_out_F[j])
        );
    end
endgenerate

SRAM #(.size(size),.AddrLength(AddrLength)) RAMLeft(
    .clk (S_AXI_ACLK),
    .we (wr_IL),
    .a (ram_addrL),
    .di (data_in_I),
    .do (data_out_IL)
);

SRAM #(.size(size),.AddrLength(AddrLength)) RAMRight(
    .clk (S_AXI_ACLK),
    .we (wr_IR),
    .a (ram_addrR),
    .di (data_in_I),
    .do (data_out_IR)
);

////FILTER ram instantiation
//SRAM #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH),.NUM_ELEMENT(NUM_ELEMENT)) ram1 (
//.clk (S_AXI_ACLK),
//.we (wr_F),
//.a (filter_addrQ),
//.di (wrData),
//.do (data_out_F)
//);

//SRAM #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH),.NUM_ELEMENT(NUM_ELEMENT)) ram2 (
//.clk (S_AXI_ACLK),
//.wr_I(wr_I),
//.addr_I(input_addrQ),
//.data_in_I(data_in_I),
//.data_out_I(data_out_I)
//);

//fsm
parameter IDLE=0, WR_FILTER=1, WR_INPUT=2, CALC=3, SUM=4;
integer i;

always @ * begin

    //defaults  
    nextState = currentState;
    for (i=0; i<26; i=i+1) begin
        sumD[i] = sumQ[i];
        sumBuf[i] = sumQ[i]+round;
    end
    wr_IL=0;
    wr_IR=0;
    data_in_I = wrData;
    ctrD = ctrQ;
    input_addrLD = input_addrLQ;
    input_addrRD = input_addrRQ;
    filter_addrD = filter_addrQ;
    num_tapD = num_tapQ;
    channelD = channelQ;
    rdBufferD = rdBufferQ;
    buffer_addrRD = buffer_addrRQ;
    buffer_addrLD = buffer_addrLQ;
    ram_addrL = 0;
    ram_addrR = 0;
    rdData = 0;
    for (i=0; i<13; i=i+1) begin
        wr_F[i] = 0;
        attD[i] = attQ[i];
        multD[i] = multQ[i];
        mid[i] = 0;
        midB[i] = attQ[i]*mid[i]+round;
    end
    
//    if(wr)begin
//        case (wrAddr)
//            4:begin
//                attD[0]=wrData;
//            end
//            8:begin
//                attD[1]=wrData;
//            end
//            12:begin
//                attD[2]=wrData;
//            end
//            16:begin
//                attD[3]=wrData;
//            end
//            20:begin
//                attD[4]=wrData;
//            end
//            24:begin
//                attD[5]=wrData;
//            end
//            28:begin
//                attD[6]=wrData;
//            end
//            32:begin
//                attD[7]=wrData;
//            end
//            36:begin
//                attD[8]=wrData;
//            end
//            40:begin
//                attD[9]=wrData;
//            end
//            44:begin
//                attD[10]=wrData;
//            end
//            48:begin
//                attD[11]=wrData;
//            end
//            52:begin
//                attD[12]=wrData;
//            end
//            default:begin
//            end
//        endcase
//    end
          
    //reg0_0 = reg0Q[0]; for measuring MACs
    //reg0_1 = reg0Q[1];
    
    case (currentState)
        IDLE: begin
            if (wr) begin
                num_tapD = wrData;
                nextState = WR_FILTER;
            end
        end
        //another counter to count 13 filter rams
        WR_FILTER: begin
            ram_addrL = input_addrLQ;
            ram_addrR = input_addrRQ;
            if(ctrQ>=13)begin
                nextState = WR_INPUT;
                filter_addrD = num_tapQ-1;
                input_addrLD = 0;
                input_addrRD = 0;
            end else if (filter_addrD >= num_tapQ) begin
                ctrD = ctrQ + 1;
                input_addrLD = 0;
                input_addrRD = 0;
                filter_addrD = 0;
            end else if (wr && wrAddr==0) begin
                wr_F[ctrQ] = 1;
                wr_IL = 1;
                wr_IR = 1;
                data_in_I = 0;
                filter_addrD = filter_addrQ+1;
                input_addrLD = input_addrLQ+1;
                input_addrRD = input_addrRQ+1;
            end
        end
        
        WR_INPUT: begin
            ram_addrL = input_addrLQ;
            ram_addrR = input_addrRQ;
            if (wr && wrAddr==0) begin
                if (channelQ) begin
                    wr_IL=1;
                    input_addrLD = input_addrLQ+1;
                    if (input_addrLQ+1 >= num_tapQ) begin
                        input_addrLD = 0;
                    end
                end else begin
                    wr_IR=1;
                    input_addrRD = input_addrRQ+1;
                    if (input_addrRQ+1 >= num_tapQ) begin
                        input_addrRD = 0;
                    end
                end
//                if (input_addrQ+1 >= num_tapQ) begin
//                    input_addrD = 0;
//                end else begin
//                    if (channelQ) begin
//                        input_addrD = input_addrQ+1;
//                    end
//                end
                for (i=0; i<26; i=i+1) begin 
                    sumD[i] = 0;
                end
                buffer_addrLD = input_addrLQ;
                buffer_addrRD = input_addrRQ;
                nextState = CALC;
            end else begin
//                rdData[15:0]=rdBufferQ;
                rdData[31]=1;
            end
        end
        
        CALC: begin
            ram_addrL = buffer_addrLQ;
            ram_addrR = buffer_addrRQ;
            if (filter_addrQ > num_tapQ) begin
                filter_addrD = num_tapQ-1;
                channelD = !channelQ;
                for (i=0; i<13; i=i+1) begin
                    if(channelQ) begin
                        multD[i] = sumQ[i][30:15];
                    end else begin
                        multD[i] = sumQ[i+13][30:15];
                    end
//                    midB[i] = attQ[i]*mid[i]+round;
//                    multD[i] = midB[i][30:15];
                end
                nextState = WR_INPUT;
            end else begin
                for (i=0;i<13;i=i+1)begin
                    if(channelQ)begin
                        sumD[i]=sumQ[i]+data_out_F[i]*data_out_IL;
                    end else begin
                        sumD[i+13]=sumQ[i+13]+data_out_F[i]*data_out_IR;
                    end
                end
                filter_addrD = filter_addrQ-1;
                if(channelQ)begin
                    if (buffer_addrLQ-1 > num_tapQ) begin
                        buffer_addrLD = num_tapQ-1;
                    end else begin
                        buffer_addrLD = buffer_addrLQ-1;
                    end
                end else begin
                    if (buffer_addrRQ-1 > num_tapQ) begin
                        buffer_addrRD = num_tapQ-1;
                    end else begin
                        buffer_addrRD = buffer_addrRQ-1;
                    end
                end
            end
        end
        
//        SUM:begin
//            rdBufferD=multQ[0]+multQ[1]+multQ[2]+multQ[3]+multQ[4]+multQ[5]+multQ[6]+multQ[7]+multQ[8]+multQ[9]+multQ[10]+multQ[11]+multQ[12];
//            nextState=WR_INPUT;
//        end
        default: begin
            nextState = IDLE;
        end
    endcase
    
    
    
//    if(input_addrQ+1>num_tapQ) begin
//        input_addrD = 0;
//    end
end

always @ (posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            for (i=0; i<26; i=i+1) begin sumQ[i] <= 0; end
            for (i=0; i<13; i=i+1) begin
                attQ[i] <= 16'h7fff;
                multQ[i] <= 0;
            end
            ctrQ <= 0;
            channelQ <= 0;
            num_tapQ <= 0;
            input_addrLQ <= 0;
            input_addrRQ <= 0;
            filter_addrQ <= 0;
            rdBufferQ <= 0;
            buffer_addrLQ <= 0;
            buffer_addrRQ <= 0;
            currentState <= IDLE;
        end else begin
            for (i=0; i<26; i=i+1) begin sumQ[i] <= sumD[i]; end
            for (i=0; i<13; i=i+1) begin
                attQ[i] <= attD[i];
                multQ[i] <= multD[i];
            end
            rdBufferQ <= rdBufferD;
            ctrQ <= ctrD;
            channelQ <= channelD;
            num_tapQ <= num_tapD;
            input_addrLQ <= input_addrLD;
            input_addrRQ <= input_addrRD;
            buffer_addrLQ <= buffer_addrLD;
            buffer_addrRQ <= buffer_addrRD;
            filter_addrQ <= filter_addrD;
            currentState <= nextState;
        end
    end     
endmodule
