`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// 
//////////////////////////////////////////////////////////////////////////////////


module pipe (clk, reset, A,B, result, wrAddr);
	
	input clk;
	input reset;
	input wire [3:0] wrAddr;
  
	input [15:0] A;
	input [15:0] B;
	output reg [15:0] result;
	
	wire [15:0] result2;
	
	reg weA;
    reg [8:0] aAD;
    reg [8:0] aAQ;
    wire signed [15:0] doA;
  
	ramA_2 ramA(
	.clk(clk),
	.we(weA),
	.a(aAQ),
	.di(A),
	.do(doA)
	);
	
 	reg weB;
    reg [8:0] aBD;
    reg [8:0] aBQ;
    wire signed [15:0] doB; 
    
    reg rd,md;

	ramB_2 ramB(
	.clk(clk),
	.we(weB),
	.a(aBQ),
	.di(B),
	.do(doB)
	);  
    reg [15:0] ramAD, ramAQ;
    reg [15:0] ramBD, ramBQ; 
    reg [15:0] multD, multQ;
    	
	mult mult(
	.clk(clk),
	.reset(reset),
	.A(ramAQ),
	.B(ramBQ),
	.PRODUCT(result2)
	);

	//Registers   
 
    reg [15:0] partialD, partialQ;
	reg [15:0] counterD, counterQ;
	reg [15:0] counter2D, counter2Q;
	reg [15:0] smult [9:0];

     
	//state machine
    
    reg [1:0] state, nextState;
    parameter Read=0, Mult=1,Fresult=2,store=3,wM=4;
    reg done;
    
    always @ * begin
		partialD = partialQ;
		ramAD = ramAQ;
		ramBD = ramBQ;
		multD = multQ;
		counter2D = 0;
		counterD = counterQ;
		weA=0;
		weB=0;
		done=1;	
		nextState=state;
		aAD = aAQ;
		aBD = aBQ;
		rd = 0;
		md = 0;
    
        case (state)   
            Read : begin
	              if(wrAddr == 2) begin
                    aAD = 0;
                    aBD = 0;
                    partialD = 0;
                    counterD = 0;
                    multD = 0;
                    nextState = Read;
                  end
                  if(wrAddr == 1) begin
                        weA = 1;    
                        weB = 1;
                        nextState = store;  
                  end
                  
            end
            
            store:begin
                weA = 1;
                weB = 1;
                ramAD = doA;
                if(aAQ < 11)begin
                    aAD =aAQ + 1;
                end else begin
                    aAD = 0;
                end 
                ramBD = doB;
                if(aBQ < 11)begin
                    aBD =aBQ + 1;
                end else begin
                    aBD = 0;
                end            
                nextState = Mult;      
            end
            
            
            Mult : begin               
                multD = result2; 
                if(counterD > 1) begin
                    partialD = partialQ + multQ;
                end
                counterD = counterQ + 1;
                nextState = Fresult;
			end
			
			Fresult: begin	    		   
				result = partialQ;				
			    nextState = Read;
			end

            default : begin
                nextState = Read;
            end
        endcase
    end
  
	
	//Sequential logic
	always @ (posedge clk) begin
        if (reset) begin
			partialQ <=0;
			counterQ <=0;
			counter2Q <=0;
			multQ<=0;
			aAQ <=0;
			aBQ <= 0;
            state <= Read;
            ramAQ <= 0;
            ramBQ <= 0;
        end
        else begin
            multQ <= multD;
            ramAQ <= ramAD;
            ramBQ <= ramBD;
			aAQ <= aAD;
			aBQ <= aBD;
			counter2Q <= counter2D;
			partialQ<=partialD;
			counterQ<=counterD;
            state <= nextState;
        end
    end
    
endmodule
