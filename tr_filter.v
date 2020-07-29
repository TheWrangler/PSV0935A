`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:19:18 07/27/2020 
// Design Name: 
// Module Name:    tr_filter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tr_filter
(
    input clk,
    input rst,
    input tr_in,
    
    output reg tr,
    output reg [1:0] tr_edge
);

    reg tr_track0 = 1'b1;
    reg tr_track1 = 1'b1;
    always @ (posedge clk) begin
        if(!rst) begin
            tr_track0 <= 1'b1;
            tr_track1 <= 1'b1;
            tr <= 1'b1;
        end 
        else begin
            tr_track0 <= tr_in;
            tr_track1 <= tr_track0;
            tr <= tr_track1;
        end
    end

    always @ (posedge clk) begin
        if(!rst) begin
            tr_edge <= 2'b11;
        end 
        else begin
            tr_edge <= { tr_edge[0],tr};
        end
    end

endmodule
