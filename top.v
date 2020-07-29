`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:42:54 07/17/2020 
// Design Name: 
// Module Name:    top 
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
module top
(
    input clk,

    input tr_in,

    //uart
    input uart_rx,
    output uart_tx,

    //ad9914_1
    output osk_1,
    input dover_1,
    output dhold_1,
    output io_update_1,
    output master_reset_1,
    output dctrl_1,
    output [2 : 0] profile_select_1,
    output [3 : 0] function_select_1,

    output p_pwd_1,
    output p_rd_1,
    output p_wr_1,
    output [7 : 0] p_addr_1,
    inout [7 : 0] p_data_1,

    //ad9914_2
    output osk_2,
    input dover_2,
    output dhold_2,
    output io_update_2,
    output master_reset_2,
    output dctrl_2,
    output [2 : 0] profile_select_2,
    output [3 : 0] function_select_2,

    output p_pwd_2,
    output p_rd_2,
    output p_wr_2,
    output [7 : 0] p_addr_2,
    inout [7 : 0] p_data_2
);

    localparam ad9914_ref_freq = 3480;//MHz

    ////////////////////////global resset//////////////////////////
    // 产生全局上电复位信号
    wire rst;
    pwr_rst #(
        .MAIN_CLOCK_PERIOD(8),
        .PWR_RST_DELAY(100000000),
        .PWR_RST_ACTIVE_LEVEL(0)
    ) 
    pwr_rst_inst (
        .clk(clk),
        .rst(rst)
    );

    ///////////////////ad9914 1 for sweep//////////////////////////
    // 扫频DDS
    wire ad9914_update_1;
    wire ad9914_update_config_1;
    wire ad9914_sweep_1;
    wire ad9914_busy_1;

    wire [31:0] ad9914_ftw_l_1;
    wire [31:0] ad9914_ftw_u_1;
    wire [31:0] ad9914_step_1;
    wire [15:0] ad9914_rate_1;

    wire ad9914_p_data_tri_select_1;
    wire [7:0] ad9914_p_data_in_1;
    wire [7:0] ad9914_p_data_out_1;

    ad9914_ctrl #(
        .MASTER_RESET_DELAY_NUM(8)
    )
    ad9914_ctrl_inst_1 (
        .clk(clk),
        .rst(rst),

        .update(ad9914_update_1),
        .update_config(ad9914_update_config_1),
        .sweep(ad9914_sweep_1),
        .sweep_edge(1),
        .lower_limit(ad9914_ftw_l_1),
        .upper_limit(ad9914_ftw_u_1),
        .positive_step(ad9914_step_1),
        .negitive_step(0),
        .positive_rate(1),
        .negitive_rate(1),

        .busy(ad9914_busy_1),
        .finish(),

        .dover(dover_1),
        .dhold(dhold_1),
        .io_update(io_update_1),
        .master_reset(master_reset_1),
        .dctrl(dctrl_1),
        .profile_select(profile_select_1),
        .function_select(function_select_1),

        .p_pwd(p_pwd_1),
        .p_rd(p_rd_1),
        .p_wr(p_wr_1),
        .p_addr(p_addr_1),
        .p_data_in(ad9914_p_data_in_1),
        .p_data_out(ad9914_p_data_out_1),
        .p_data_tri_select(ad9914_p_data_tri_select_1)
    );
    
	genvar i; 
    generate
        for(i=0;i<8;i=i+1) begin : ad9914_ctrl_inst_1_p_data_tri
            IOBUF
            #(
                .DRIVE(12),
                .IBUF_LOW_PWR("TRUE"),
                .IOSTANDARD("DEFAULT"),
                .SLEW("SLOW")
            )
            IOBUF_inst
            (
                .I(ad9914_p_data_out_1[i]),
                .O(ad9914_p_data_in_1[i]),
                .T(ad9914_p_data_tri_select_1),
                .IO(p_data_1[i])
            );
        end
    endgenerate

    ///////////////////ad9914 2 for freq hoop//////////////////////////
    // 跳频DDS
    wire ad9914_update_2;
    wire ad9914_sweep_2;
    wire ad9914_busy_2;

    wire [31:0] ad9914_ftw_l_2;
    wire [31:0] ad9914_ftw_u_2;
    wire [31:0] ad9914_step_2;
    wire [15:0] ad9914_rate_2;

    wire ad9914_p_data_tri_select_2;
    wire [7:0] ad9914_p_data_in_2;
    wire [7:0] ad9914_p_data_out_2;

    ad9914_ctrl #(
        .MASTER_RESET_DELAY_NUM(8)
    )
    ad9914_ctrl_inst_2 (
        .clk(clk),
        .rst(rst),

        .update(ad9914_update_2),
        .update_config(0),
        .sweep(ad9914_sweep_2),
        .sweep_edge(1),
        .lower_limit(ad9914_ftw_l_2),
        .upper_limit(ad9914_ftw_u_2),
        .positive_step(0),
        .negitive_step(0),
        .positive_rate(1),
        .negitive_rate(1),
        

        .busy(ad9914_busy_2),
        .finish(),

        .dover(dover_2),
        .dhold(dhold_2),
        .io_update(io_update_2),
        .master_reset(master_reset_2),
        .dctrl(dctrl_2),
        .profile_select(profile_select_2),
        .function_select(function_select_2),

        .p_pwd(p_pwd_2),
        .p_rd(p_rd_2),
        .p_wr(p_wr_2),
        .p_addr(p_addr_2),
        .p_data_in(ad9914_p_data_in_2),
        .p_data_out(ad9914_p_data_out_2),
        .p_data_tri_select(ad9914_p_data_tri_select_2)
    );

    generate
        for(i=0;i<8;i=i+1) begin : ad9914_ctrl_inst_2_p_data_tri
            IOBUF
            #(
                .DRIVE(12),
                .IBUF_LOW_PWR("TRUE"),
                .IOSTANDARD("DEFAULT"),
                .SLEW("SLOW")
            )
            IOBUF_inst
            (
                .I(ad9914_p_data_out_2[i]),
                .O(ad9914_p_data_in_2[i]),
                .T(ad9914_p_data_tri_select_2),
                .IO(p_data_2[i])
            );
        end
    endgenerate


    ///////////////Calc Sweep params for ad9914_1/////////////////////////
    // // 计算扫频AD9914的扫频参数 430~470MHz
    SweepParamCalc #(
        .AD9914_REF_FREQ(ad9914_ref_freq),//MHz
        .SWEEP_STEP_NUM(10)
    )
    SweepParamCalc_inst_1(
        .freq_l(32'd430),//MHz
        .freq_u(32'd470),//MHz
        //.freq_step(32'd100),//KHz
        .sweep_span(0),//ns
        .ftw_l(ad9914_ftw_l_1),
        .ftw_u(ad9914_ftw_u_1),
        .positive_step(),
        .positive_rate()
    );

    // ///////////////Calc Sweep params for ad9914_2/////////////////////////
    // // 计算跳频AD9914的跳频参数
    SweepParamCalc #(
        .AD9914_REF_FREQ(ad9914_ref_freq),//MHz
        .SWEEP_STEP_NUM(10)
    )
    SweepParamCalc_inst_2(
        .freq_l(32'd900),//MHz
        .freq_u(32'd900),//MHz
        //.freq_step(32'd100),//KHz
        .sweep_span(0),//ns
        .ftw_l(ad9914_ftw_l_2),
        .ftw_u(ad9914_ftw_u_2),
        .positive_step(),
        .positive_rate()
    );

    ///////////////////////////generate filtered tr//////////////////////
    // 对外部tr信号进行滤波
    wire tr;
    wire [1:0] tr_edge;
    tr_filter tr_filter_inst
    (
        .clk(clk),
        .rst(rst),
        .tr_in(tr_in),
        
        .tr(tr),
        .tr_edge(tr_edge)
    );

    ///////////////////////////generate pre tr///////////////////////////
    // // 对tr信号做超前处理，超前时间与AD9914配置速率所需时间相关
    wire pre_tr;
    wire [1:0] pre_tr_edge;
    pre_tr_gen #(
        .TR_PERIOD_CLOCK_NUM(15000),//120*125us
        .TR_POSITIVE_PERIOD_CLOCK_NUM(20),//20*1us
        .PRE_TR_CLOCK_NUM(46)
    )
    pre_tr_gen_inst (
        .clk(clk),
        .rst(rst),

        .tr(tr),
        .tr_edge(tr_edge),
        .pre_tr(pre_tr),
        .pre_tr_edge(pre_tr_edge)
    );


    ///////////////////////////generate prf//////////////////////////////
    // 产生prf时许，用于osk
    wire prf;
    wire [1:0] prf_edge;
    prf_gen #(
        .RF_DELAY_CLOCK_NUM( 120 ),
        .PRF_PHASE_DELAY_0_CLOCK_NUM(600),
        .PRF_PHASE_DELAY_1_CLOCK_NUM(840),
        .PRF_PHASE_DELAY_2_CLOCK_NUM(1560),
        .PRF_PHASE_0_CLOCK_NUM(12),
        .PRF_PHASE_1_CLOCK_NUM(60),
        .PRF_PHASE_2_CLOCK_NUM(240),
        .PRF_PHASE_3_CLOCK_NUM(600)
    )
    prf_gen_inst (
        .clk(clk),
        .rst(rst),
        .tr(tr),
        .tr_edge(tr_edge),
        .prf(prf),
        .prf_edge(prf_edge)
    );

    ///////////////////////////generate pre_prf//////////////////////////////
    //产生超前prf信号，用于在每个脉冲前启动扫频
    wire pre_prf;
    wire [1:0] pre_prf_edge;
    prf_gen #(
        .RF_DELAY_CLOCK_NUM( 120 ),
        .PRF_PHASE_DELAY_0_CLOCK_NUM(600),
        .PRF_PHASE_DELAY_1_CLOCK_NUM(840),
        .PRF_PHASE_DELAY_2_CLOCK_NUM(1560),
        .PRF_PHASE_0_CLOCK_NUM(12),
        .PRF_PHASE_1_CLOCK_NUM(60),
        .PRF_PHASE_2_CLOCK_NUM(240),
        .PRF_PHASE_3_CLOCK_NUM(600)
    )
    pre_prf_gen_inst (
        .clk(clk),
        .rst(rst),
        .tr(pre_tr),
        .tr_edge(pre_tr_edge),
        .prf(pre_prf),
        .prf_edge(pre_prf_edge)
    );

    ///////////////////////////generate pre_prf//////////////////////////////
    //产生滞后prf信号，用于在每个脉冲前配置扫频参数
    wire post_prf;
    wire [1:0] post_prf_edge;
    prf_gen #(
        .RF_DELAY_CLOCK_NUM( 240 ),
        .PRF_PHASE_DELAY_0_CLOCK_NUM(600),
        .PRF_PHASE_DELAY_1_CLOCK_NUM(840),
        .PRF_PHASE_DELAY_2_CLOCK_NUM(1560),
        .PRF_PHASE_0_CLOCK_NUM(12),
        .PRF_PHASE_1_CLOCK_NUM(60),
        .PRF_PHASE_2_CLOCK_NUM(240),
        .PRF_PHASE_3_CLOCK_NUM(600)
    )
    post_prf_gen_inst (
        .clk(clk),
        .rst(rst),
        .tr(tr),
        .tr_edge(tr_edge),
        .prf(post_prf),
        .prf_edge(post_prf_edge)
    );

    /////////////////////////////////////////////////////////////////////
    protocol #(
        .MAIN_CLK_FREQ(120000000),// 时钟clk频率
        .UART_BAUD(115200) //串口波特率
    )
    protocol_inst (
        .clk(clk),
        .rst(rst),

        //uart
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),

        //数据帧输出
        .cmd_out_en(),
        .cmd(),
        .cmd_ready(),

        .crc_err()
    );

    ////////////////////////////////////////////////////////////////////
    // 控制DDS
    wire debug_update_start;
    workflow workflow_inst
    (
        .clk(clk),
        .rst(rst),
        .update_enable(debug_update_start),

        .tr_edge(tr_edge),
        .prf_edge(prf_edge),
        .pre_prf_edge(pre_prf_edge),
        .post_prf_edge(post_prf_edge),

        .ad9914_update_1(ad9914_update_1),
        .ad9914_update_config_1(ad9914_update_config_1),
        .ad9914_sweep_1(ad9914_sweep_1),
        .ad9914_busy_1(ad9914_busy_1),
        .ad9914_sweep_step_1(ad9914_step_1),

        .ad9914_update_2(ad9914_update_2),
        .ad9914_sweep_2(ad9914_sweep_2),
        .ad9914_busy_2(ad9914_busy_2)
    );

    wire [35:0] CONTROL0;
    wire [35:0] CONTROL1;
	wire [109:0] TRIG0;
    wire [7:0] ASYNC_OUT;
    wire [7:0] ASYNC_IN;
	assign TRIG0[0] = tr_in;
	assign TRIG0[1] = prf;
	assign TRIG0[2] = ad9914_update_1;
    assign TRIG0[3] = ad9914_sweep_1;
	assign TRIG0[35:4] = ad9914_ftw_l_1;
    assign TRIG0[67:36] = ad9914_step_1;
    assign TRIG0[75:68] = p_addr_1;
    assign TRIG0[83:76] = ad9914_p_data_out_1;
    assign TRIG0[99:84] = ad9914_rate_1;
    assign TRIG0[100] = dctrl_1;
    assign TRIG0[101] = io_update_1;
    assign TRIG0[102] = ad9914_busy_1;
    assign TRIG0[103] = ad9914_update_config_1;
    assign TRIG0[104] = pre_prf;
    assign TRIG0[105] = pre_tr;
    assign TRIG0[106] = dover_1;
    assign TRIG0[107] = debug_update_start;
    assign TRIG0[108] = post_prf;

    assign debug_update_start = ASYNC_OUT[0];
	
	myila myila_inst (
		.CONTROL(CONTROL0),
		.CLK(clk),
		.TRIG0(TRIG0)
	);

	myicon myicon_inst (
    	.CONTROL0(CONTROL0),
        .CONTROL1(CONTROL1)
	);

    myvio myvio_inst (
        .CONTROL(CONTROL1),
        .ASYNC_IN(ASYNC_IN), 
        .ASYNC_OUT(ASYNC_OUT) 
    );

    assign osk_1 = prf;
    assign osk_2 = 1;

endmodule