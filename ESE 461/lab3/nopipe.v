`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// 
//////////////////////////////////////////////////////////////////////////////////


module nopipe (clk, reset, A,B, result);
	
	input clk;
	input reset;
  
	input [15:0] A;
	input [15:0] B;
	output reg [15:0] result;
	
	reg [15:0] result2;
	
	reg weA;
    reg [8:0] aAD, aAQ;
    wire signed [15:0] doA;
  
	ramA ramA(
	.clk(clk),
	.we(weA),
	.a(aAQ),
	.di(A),
	.do(doA)
	);
	
 	reg weB;
    reg [8:0] aBD, aBQ;
    wire signed [15:0] doB; 

	ramB ramB(
	.clk(clk),
	.we(weB),
	.a(aB),
	.di(B),
	.do(doB)
	);  
	
	multi multi(
	.clk(clk),
	.reset(reset),
	.A(doA),
	.B(doB),
	.PRODUCT(result2);
	);

	//Registers   
 
    reg [15:0] partialD, partialQ;
	reg [15:0] counterD, counterQ;

     
	//state machine
    
    reg state, nextState;
    parameter Read=0, Mult=1,Fresult=2;
    reg done;
    
    always @ * begin
		partialD = partialQ;
		weA=0;
		weB=0;
		done=1;
		nextState=state;
    
        case (state)
            Read : begin
                //Reset registers
				partialD = 0;
				counterD = 0;
				weA = 1;
				weB = 1;
                nextState = Mult;

            end
            Mult : begin
				if(counterQ <10) begin
					partialD = partialQ + result2;
					counterD = counterQ + 1;
				end
				else begin
					nextState = Fresult;
				end
			end
			Fresult: begin
				result = partialQ;
			end

            default : begin
                nextState = Read;
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
	
	
	//Sequential logic
	always @ (posedge clk) begin
        if (reset) begin
			partialQ <=0;
			counterQ <=0;
			aAQ <=0;
			aBQ <= 0;
            state <= Read;
        end
        else begin
			aAQ <= aAD;
			aBQ <= aBD;
			partialQ<=partialD;
			counterQ<=counterD;
            state <= nextState;
        end
    end
    
endmodule
