`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2018 02:06:08 PM
// Design Name: 
// Module Name: FIR_Filter
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


module FIR_Filter #(C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
    //Axi4Lite Bus
    input       S_AXI_ACLK,
    input       S_AXI_ARESETN,
    input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input       S_AXI_AWVALID,
    output      S_AXI_AWREADY,
    input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input       [3:0] S_AXI_WSTRB,
    input       S_AXI_WVALID,
    output      S_AXI_WREADY,
    output      [1:0] S_AXI_BRESP,
    output      S_AXI_BVALID,
    input       S_AXI_BREADY,
    input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input       S_AXI_ARVALID,
    output      S_AXI_ARREADY,
    output      [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output      [1:0] S_AXI_RRESP,
    output      S_AXI_RVALID,
    input       S_AXI_RREADY
    );
  
//Instantiations, wires, and regs
  
    //Simple bus
    wire wr,rd;
    wire [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,rdAddr;
    wire [C_S_AXI_DATA_WIDTH-1:0] wrData;
    reg [C_S_AXI_DATA_WIDTH-1:0] rdData;
    
    //Axi4LiteSupporter
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
    );
   
   //Signals for taps RAM
   reg weTaps;
   reg [8:0] aTapsD, aTapsQ;
   wire signed [15:0] doTaps;
   
    //Taps RAM
    blockRam tapsRam
    (
    .clk(S_AXI_ACLK),
    .we(weTaps),
    .a(aTapsQ),
    .di(wrData[15:0]),
    .do(doTaps)
    );
    
    //Signals for inputs RAM
    reg weInputs;
    reg [8:0] aInputsD, aInputsQ;
    wire signed [15:0] doInputs;
    
    //Inputs RAM (Circular Buffer)
    blockRam inputsRam
    (
    .clk(S_AXI_ACLK),
    .we(weInputs),
    .a(aInputsQ),
    .di(wrData[15:0]),
    .do(doInputs)
    );
    
//Registers   
 
    //Support mutable number of taps
    reg [15:0] numTapsD, numTapsQ;
    
    //Counter for convolution
    reg [15:0] convCounterD, convCounterQ;
    
    //Circular buffer index
    reg [15:0] circBuffIndD, circBuffIndQ;
    
    //Store the running sum
    reg signed [31:0] convSumD, convSumQ;
    
    //Store the result
    reg signed [31:0] resultD, resultQ;
    
//Main state machine
    
    reg state, nextState;
    parameter IDLE=0, CONV=1;
    
    reg convDone;
    
    //Sequential logic
    always @ (posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            numTapsQ <= 0;
            convCounterQ <= 0;
            circBuffIndQ <= 0;
            convSumQ <= 0;
            resultQ <= 0;
            aTapsQ <= 0;
            aInputsQ <= 0;
            state <= IDLE;
        end
        else begin
            numTapsQ <= numTapsD;
            convCounterQ <= convCounterD;
            circBuffIndQ <= circBuffIndD;
            convSumQ <= convSumD;
            resultQ <= resultD;
            aTapsQ <= aTapsD;
            aInputsQ <= aInputsD;     
            state <= nextState;
        end
    end
    
    always @ * begin
        //Registers
        numTapsD = numTapsQ;
        convCounterD = convCounterQ;
        circBuffIndD = circBuffIndQ;
        convSumD = convSumQ;
        resultD = resultQ;
        aTapsD = aTapsQ;
        aInputsD = aInputsQ;
                
        //Values
        weTaps = 0;
        weInputs = 0;
        convDone = 1;
        
        //State
        nextState = state;
    
        case (state)
            IDLE : begin
                //Reset registers
                convCounterD = 0;
                convSumD = 0;
                
                //Receiving data from MicroBlaze
                if (wr) begin
                    case (wrAddr)
                        0 : begin
                            numTapsD = wrData;
                            aTapsD = 0;
                            aInputsD = 0;
                        end
                        1 : begin
                            weTaps = 1;
                            if (aTapsQ == numTapsQ - 1) begin
                                aTapsD = 0;
                            end
                            else begin
                                aTapsD = aTapsQ + 1;
                            end
                        end
                        2 : begin
                            weInputs = 1;
                            nextState = CONV;
                            convDone = 0;
                        end
                    endcase
                end
            end
            CONV : begin
                //Currently doing convolution
                convDone = 0;
            
                //Increment counter
                convCounterD = convCounterQ + 1;
                
                //Decrement input index and wrap if necessary
                if (aInputsQ > 0) begin
                    aInputsD = aInputsQ - 1;
                end
                else begin
                    aInputsD = numTapsQ - 1; 
                end
                
                //Increment taps index and wrap if necessary
                if (aTapsQ == numTapsQ - 1) begin
                    aTapsD = 0;
                end
                else begin
                    aTapsD = aTapsQ + 1;
                end                
                
                //Multiply and accumulate
                convSumD = convSumQ + (doInputs * doTaps);
                
                if (convCounterQ == numTapsQ - 1) begin
                    nextState = IDLE;
                    
                    aInputsD = aInputsQ;
                    
                    //Round, bitshift, get rid of hanging first bit
                    resultD = (convSumD + 16'h4000);
                end
            end
            default : begin
                nextState = IDLE;
            end
        endcase
    end
  
//Reading back result
    always @ * begin
        if (rdAddr == 0) begin
            rdData = convDone;
        end
        else begin
            rdData = resultQ[30:15];
        end
    end  
    
endmodule
