`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:55:52 07/26/2020 
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
module SweepParamCalc
#(
    parameter AD9914_REF_FREQ = 3480,//MHz，AD9914参考时钟
    parameter SWEEP_STEP_NUM = 100
)
(
    input [31:0] freq_l,//MHz，扫频下限
    input [31:0] freq_u,//MHz，扫频上线
    //input [31:0] freq_step,//KHz，步进频率
    input [31:0] sweep_span,//ns，脉冲周期

    output [31:0] ftw_l,//扫频下线FTW
    output [31:0] ftw_u,//扫频上线FTW
    output [31:0] positive_step,//扫频正周期步进
	output [15:0] positive_rate//扫频正周期速率
);

    //calc ftw
    wire [63:0] ftw_l_temp1;
    wire [63:0] ftw_l_temp2;
    assign ftw_l_temp1 = freq_l;
    assign ftw_l_temp2 = (ftw_l_temp1 << 32);
    assign ftw_l = ftw_l_temp2 / AD9914_REF_FREQ;

    wire [63:0] ftw_u_temp1;
    wire [63:0] ftw_u_temp2;
    assign ftw_u_temp1 = freq_u;
    assign ftw_u_temp2 = (ftw_u_temp1 << 32);
    assign ftw_u = ftw_u_temp2 / AD9914_REF_FREQ;

    //calc sweep step
    wire [63:0] step_temp1;
    wire [63:0] step_temp2;
    wire [63:0] step_temp3;
    wire [63:0] step_temp4;
    assign step_temp1 = freq_u - freq_l/* freq_step */;
    assign step_temp2 = step_temp1 * AD9914_REF_FREQ;
    assign step_temp3 = step_temp2 * 1000000000000;
    assign step_temp4 = step_temp3 >> 32;
    assign positive_step = step_temp4 / SWEEP_STEP_NUM;

    //calc sweep rate
    // wire [63:0] sweep_step_count_temp1;
    // wire [63:0] sweep_step_count_temp2;
    // wire [63:0] sweep_step_count;
    // wire [63:0] sweep_range;
    // assign sweep_range = freq_u - freq_l;
    // assign sweep_step_count_temp1 = sweep_range * 1000;
    // assign sweep_step_count_temp2 = sweep_step_count_temp1 / freq_step;
    // assign sweep_step_count = sweep_step_count_temp2 + 1;

    wire [63:0] rate_temp1;
    wire [63:0] rate_temp2;
    wire [63:0] delta_t;
    assign rate_temp1 = sweep_span;
    assign rate_temp2 =  rate_temp1 * AD9914_REF_FREQ;
    assign delta_t = rate_temp2 / SWEEP_STEP_NUM/* sweep_step_count */;
    assign positive_rate = delta_t / 24000;

    

endmodule