module mult( clk, reset, A, B, PRODUCT);

  input clk;
  input reset;

  input [15 : 0] A;
  input [15 : 0] B;
  output reg[15 : 0] PRODUCT;
  
  // Your code begins here
  reg [31:0] storeD, storeQ;
  reg [15:0] storeBD, storeBQ;
  reg [31:0] productD, productQ;
  reg [3:0] nextState, state;
  reg [6:0] counterD, counterQ;
  parameter init = 0,  step1 = 1,step2 = 2;
  //combination code and fsm
  //A muliplicand, and B is mulitplier
   always @ * begin
   storeD = storeQ;
   productD = productQ;
   storeBD = storeBQ;
   counterD = counterQ;
   nextState = state;
   
        case(state)
            init: begin
                storeD = 0;
                storeBD = B;
                productD = 0;
                counterD = 0;
                nextState = step1; 
            end
            
        step1: begin
           if(counterD < 32)begin
                if(B[counterQ]==1)begin
                    storeD = A << counterQ;
                    productD = productQ + storeQ;
                    counterD = counterQ + 1;
                end
                else begin
                    counterD = counterQ + 1;
                end
           end
           else begin
                productD = productQ + storeQ;
                nextState = step2;
           end
        end
        
        step2 : begin
              PRODUCT[7:0] = productQ[15:8];
              PRODUCT[15:8] = productQ[23:16];
              nextState = init;
        end
        endcase
   end
   
   //sequential logic
   always @ (posedge clk) begin
        if ( reset ) begin
            storeQ <= 0;
            counterQ <= 0;
            productQ <= 0;
            storeBQ <= 0;
            state <= init;
            
        end else begin
            counterQ <= counterD;
            storeQ <= storeD;
            storeBQ <= storeBD;
            productQ <= productD;
            state <= nextState;
        end
   end
endmodule