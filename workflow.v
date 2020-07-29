`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:02:46 07/26/2020 
// Design Name: 
// Module Name:    workflow 
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
module workflow
(
    input clk,
    input rst,

    //debug 
    input update_enable,

    //input tr,
    input [1:0] tr_edge,
    //input prf,
    input [1:0] prf_edge,
    //input pre_prf,
    input [1:0] pre_prf_edge,
    input [1:0] post_prf_edge,

    output reg ad9914_update_1,
    output reg ad9914_update_config_1,
    output reg ad9914_sweep_1,
    input ad9914_busy_1,
    output reg [31:0] ad9914_sweep_step_1,

    output reg ad9914_update_2,
    output reg ad9914_sweep_2,
    input ad9914_busy_2
);

    //在上电复位后，配置扫频DDS的SFR\FTW\STEP等寄存器，之后不再变化
    reg ad9914_ready_1 = 1'b0;
    reg [7:0] update_fsm_state = 8'd0;
    always @ (posedge clk) begin
        if(!rst) begin
            ad9914_ready_1 <= 1'b0;
            update_fsm_state <= 8'd0;
            ad9914_update_1 <= 1'b0;
        end 
        else begin
            case(update_fsm_state)
                0 : begin
                   if(ad9914_ready_1 == 1'b0 && update_enable) begin
                        ad9914_update_1 <= 1'b1;
                        update_fsm_state <= 8'd1;
                   end
                end
                1 : begin
                    if(ad9914_busy_1) begin
                        ad9914_update_1 <= 1'b0;
                        update_fsm_state <= 8'd2;
                    end
                end
                2 : begin
                    if(!ad9914_busy_1) begin
                        ad9914_ready_1 <= 1'b1;
                        update_fsm_state <= 8'd0;
                    end
                end
            endcase
        end
    end

    // 在超前prf信号的上升沿启动扫频，启动过程需要xxns
    reg [7:0] sweep_fsm_state = 8'd0;
    always @ (posedge clk) begin
        if(!rst || !ad9914_ready_1) begin
            ad9914_sweep_1 <= 1'b0;
            sweep_fsm_state <= 8'd0;
        end 
        else begin
            case(sweep_fsm_state)
                0 : begin
                    if(pre_prf_edge == 2'b01 && !ad9914_busy_1) begin
                        ad9914_sweep_1 <= 1'b1;
                        sweep_fsm_state <= 8'd1;
                    end
                end
                1 : begin
                    if(ad9914_busy_1) begin
                        ad9914_sweep_1 <= 1'b0;
                        sweep_fsm_state <= 8'd0;
                    end
                end
            endcase
        end
    end

    //在prf的下降沿配置下一个prf脉宽内的扫频速率
    reg [3:0] prf_edge_phase_num= 4'hf;
    always @ (posedge clk) begin
        if(!rst) begin
            prf_edge_phase_num <= 4'hf;
        end 
        else if(tr_edge == 2'b01) begin
            prf_edge_phase_num <= 4'd0;
        end
        else if(post_prf_edge/* prf_edge */ == 2'b01) begin
                prf_edge_phase_num <= prf_edge_phase_num + 4'd1;
        end
    end

    reg [7:0] config_fsm_state = 8'd0;
    always @ (posedge clk) begin
        if(!rst || !ad9914_ready_1) begin
            ad9914_update_config_1 <= 1'b0;
            ad9914_sweep_step_1 <= 32'h00221b26;
            config_fsm_state <= 8'd0;
        end 
        else begin
            case(config_fsm_state)
                0 : begin
                    if(post_prf_edge/* prf_edge */ == 2'b10)
                        config_fsm_state <= 8'd1;
                end
                1 : begin
                    case (prf_edge_phase_num) 
                        4 : begin
                            ad9914_sweep_step_1 <= 32'h00221b26;
                            config_fsm_state <= 8'd2;
                        end
                        1 : begin
                            ad9914_sweep_step_1 <= 32'h0006d23a;
                            config_fsm_state <= 8'd2;
                        end
                        2 : begin
                            ad9914_sweep_step_1 <= 32'h00221b26;
                            config_fsm_state <= 8'd2;
                        end
                        3 : begin
                            ad9914_sweep_step_1 <= 32'h0006d23a;
                            config_fsm_state <= 8'd2;
                        end
                        default:begin
                            config_fsm_state <= 8'd0;
                        end
                    endcase
                end
                2 : begin
                    if(!ad9914_busy_1) begin
                        ad9914_update_config_1 <= 1'b1;
                        config_fsm_state <= 8'd3;
                    end
                    else config_fsm_state <= 8'd0;
                end
                3 : begin
                    if(ad9914_busy_1) begin
                        ad9914_update_config_1 <= 1'b0;
                        config_fsm_state <= 8'd0;
                    end
                end
            endcase
        end
    end


endmodule