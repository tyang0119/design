`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2018 09:54:55 PM
// Design Name: 
// Module Name: problem5
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


module problem5(
input clock,
input reset,
input reg_0,
input reg_1
);


reg[1:0] a;
reg[1:0] currentState, nextState;
parameter Idle=0, GNT0=1, GNT1=2;

always @ * begin
nextState=currentState;
if(reset)begin
      nextState=Idle;
end
else begin
    case(currentState)
        Idle: begin
            a=0;
            if(reg_0)begin
                nextState=GNT0;
            end
            if(reg_1)begin
                nextState=GNT1;
            end
        end
        
        GNT0:begin
            a=1;
                if(reg_0)begin
                    a=1;
                end 
                else begin
                    nextState=Idle;
                end
            end
  
        GNT1:begin
             a=2;
                if(reg_1)begin
                   a=2;
                end 
                else begin
                    nextState=Idle;
                end   
             end     
        default:begin
            nextState=Idle;
        end
    endcase
    end
end

always @ (posedge clock)
begin : FSM_SEQ
  if (reset == 1) begin
    currentState <= #10 Idle;
  end else begin
    currentState <= #10 nextState;
  end
end

endmodule
