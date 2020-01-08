`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// 
//////////////////////////////////////////////////////////////////////////////////


module nopipe (clk, reset, A,B, result, wrAddr);
	
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
  
	ramA rA(
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

	ramB rB(
	.clk(clk),
	.we(weB),
	.a(aBQ),
	.di(B),
	.do(doB)
	);  
	
	mult mult(
	.clk(clk),
	.reset(reset),
	.A(doA),
	.B(doB),
	.PRODUCT(result2)
	);

	//Registers   
 
    reg [15:0] partialD, partialQ;
	reg [15:0] counterD, counterQ;
	reg [15:0] counter2D, counter2Q;

     
	//state machine
    
    reg [1:0] state, nextState;
    parameter Read=0, Mult=1,Fresult=2;
    reg done;
    
    always @ * begin
		partialD = partialQ;
		counter2D = 0;
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
                //Reset registers
	              if(wrAddr == 2) begin
                    aAD = 0;
                    aBD = 0;
                    partialD = 0;
                    counterD = 0;
                    nextState = Read;
                  end
                  if(wrAddr == 1) begin
                        weA = 1;    
                        weB = 1;
                        if(aAQ <9 && aBQ <9)begin
                            aAD =aAQ +1;
                            aBD =aBQ +1;
                        end else begin
                            nextState = Mult;   
                            aAD = 0;
                            aBD = 0;
                        end     
                  end
            end
            Mult : begin
                    counter2D = counter2Q + 1;
                    if(counter2Q == 78)begin
                        counter2D = 0;
                        counterD = counterQ + 1;
                        if(counterQ <10) begin
                           partialD = partialQ + result2;
                           aAD =aAQ +1;
                           aBD =aBQ +1;
                        end else begin
                           nextState = Fresult;
                           counterD = 0;
                        end
                    end else begin
                        nextState = Mult;
                    end
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
			aAQ <=0;
			aBQ <= 0;
            state <= Read;
        end
        else begin
			aAQ <= aAD;
			aBQ <= aBD;
			counter2Q <= counter2D;
			partialQ<=partialD;
			counterQ<=counterD;
            state <= nextState;
        end
    end
    
endmodule
