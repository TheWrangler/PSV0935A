`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:14:05 07/27/2020 
// Design Name: 
// Module Name:    pre_tr_gen 
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
module pre_tr_gen
#(
    parameter TR_PERIOD_CLOCK_NUM = 15000, // 120*125us，TR信号周期
    parameter TR_POSITIVE_PERIOD_CLOCK_NUM = 120,// TR信号脉冲宽度
    parameter PRE_TR_CLOCK_NUM = 76 // 超前时间
)
(
    input clk,
    input rst,

    input tr,
    input [1:0] tr_edge,
    output reg pre_tr,
    output reg [1:0] pre_tr_edge
);

    localparam [15:0] delay_num = TR_PERIOD_CLOCK_NUM - PRE_TR_CLOCK_NUM;

    reg [7:0] fsm_state = 8'd0;
    reg [15:0] delay_count = 16'd0;
    always @ (posedge clk) begin
        if(!rst) begin
            fsm_state <= 8'd0;
            delay_count <= 16'd0;
            pre_tr <= 1'b0;
        end
        else begin
            case (fsm_state)
                0 : begin
                    if(tr_edge == 2'b01) begin
                        delay_count <= 16'd0;
                        fsm_state <= 8'd1;
                    end
                end
                1 : begin
                    delay_count <= delay_count + 16'd1;
                    if(delay_count > delay_num)
                        fsm_state <= 8'd2;
                end
                2 : begin
                    pre_tr <= 1'b1;
                    delay_count <= 16'd0;
                    fsm_state <= 8'd3;
                end
                3 : begin
                    delay_count <= delay_count + 16'd1;
                    if(delay_count > TR_POSITIVE_PERIOD_CLOCK_NUM)
                        fsm_state <= 8'd4;
                end
                4 : begin
                    pre_tr <= 1'b0;
                    fsm_state <= 8'd0;
                end
            endcase
        end
    end

    always @ (posedge clk) begin
        if(!rst) begin
            pre_tr_edge <= 2'b11;
        end 
        else begin
            pre_tr_edge <= { pre_tr_edge[0],pre_tr};
        end
    end

endmodule