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
    inout [7 : 0] p_data_2,

    //ad9914_3
    output osk_3,
    input dover_3,
    output dhold_3,
    output io_update_3,
    output master_reset_3,
    output dctrl_3,
    output [2 : 0] profile_select_3,
    output [3 : 0] function_select_3,

    output p_pwd_3,
    output p_rd_3,
    output p_wr_3,
    output [7 : 0] p_addr_3,
    inout [7 : 0] p_data_3,

    //ad9914_4
    output osk_4,
    input dover_4,
    output dhold_4,
    output io_update_4,
    output master_reset_4,
    output dctrl_4,
    output [2 : 0] profile_select_4,
    output [3 : 0] function_select_4,

    output p_pwd_4,
    output p_rd_4,
    output p_wr_4,
    output [7 : 0] p_addr_4,
    inout [7 : 0] p_data_4

);

    ////////////////////////global resset//////////////////////////
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

    wire [3:0] ad9914_update;
    wire [3:0] ad9914_busy;
    reg [3:0] ad9914_update_reg = 4'b0000;
    assign ad9914_update = ad9914_update_reg;

    wire [31:0] ad9914_ftw_l_1 = 32'd555383702;//450MHz
    wire [31:0] ad9914_ftw_u_1 = 32'd555383703;//450MHz

    wire [31:0] ad9914_ftw_l_2 = 32'd1110767404;//900MHz
    wire [31:0] ad9914_ftw_u_2 = 32'd1110767405;//900MHz

    wire [31:0] ad9914_ftw_l_3 = 32'd1234186004;//1000MHz
    wire [31:0] ad9914_ftw_u_3 = 32'd1234186005;//1000MHz

    wire [31:0] ad9914_ftw_l_4 = 32'd839246483;//680MHz
    wire [31:0] ad9914_ftw_u_4 = 32'd839246484;//680MHz

    ///////////////////ad9914 1//////////////////////////
    wire ad9914_p_data_tri_select_1;
    wire [7:0] ad9914_p_data_in_1;
    wire [7:0] ad9914_p_data_out_1;

    ad9914_ctrl #(
        .MASTER_RESET_DELAY_NUM(8)
    )
    ad9914_ctrl_inst_1 (
        .clk(clk),
        .rst(rst),

        .update(ad9914_update[0]),
        .lower_limit(ad9914_ftw_l_1),
        .upper_limit(ad9914_ftw_u_1),
        .positive_step(0),
        .positive_rate(145),
        .resweep_period(0),

        .busy(ad9914_busy[0]),
        .finish(),

        .trig(),
        .pre_trig(),
        .resweep(),

        .osk(osk_1),
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
                .DRIVE(12), // Specify the output drive strength
                .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
                .IOSTANDARD("DEFAULT"), // Specify the I/O standard
                .SLEW("SLOW") // Specify the output slew rate
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

    ///////////////////ad9914 2//////////////////////////
    wire ad9914_p_data_tri_select_2;
    wire [7:0] ad9914_p_data_in_2;
    wire [7:0] ad9914_p_data_out_2;

    ad9914_ctrl #(
        .MASTER_RESET_DELAY_NUM(8)
    )
    ad9914_ctrl_inst_2 (
        .clk(clk),
        .rst(rst),

        .update(ad9914_update[1]),
        .lower_limit(ad9914_ftw_l_2),
        .upper_limit(ad9914_ftw_u_2),
        .positive_step(0),
        .positive_rate(145),
        .resweep_period(0),

        .busy(ad9914_busy[1]),
        .finish(),

        .trig(),
        .pre_trig(),
        .resweep(),

        .osk(osk_2),
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
                .DRIVE(12), // Specify the output drive strength
                .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
                .IOSTANDARD("DEFAULT"), // Specify the I/O standard
                .SLEW("SLOW") // Specify the output slew rate
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

    ///////////////////ad9914 3//////////////////////////
    wire ad9914_p_data_tri_select_3;
    wire [7:0] ad9914_p_data_in_3;
    wire [7:0] ad9914_p_data_out_3;

    ad9914_ctrl #(
        .MASTER_RESET_DELAY_NUM(8)
    )
    ad9914_ctrl_inst_3 (
        .clk(clk),
        .rst(rst),

        .update(ad9914_update[2]),
        .lower_limit(ad9914_ftw_l_3),
        .upper_limit(ad9914_ftw_u_3),
        .positive_step(0),
        .positive_rate(145),
        .resweep_period(0),

        .busy(ad9914_busy[2]),
        .finish(),

        .trig(),
        .pre_trig(),
        .resweep(),

        .osk(osk_3),
        .dover(dover_3),
        .dhold(dhold_3),
        .io_update(io_update_3),
        .master_reset(master_reset_3),
        .dctrl(dctrl_3),
        .profile_select(profile_select_3),
        .function_select(function_select_3),

        .p_pwd(p_pwd_3),
        .p_rd(p_rd_3),
        .p_wr(p_wr_3),
        .p_addr(p_addr_3),
        .p_data_in(ad9914_p_data_in_3),
        .p_data_out(ad9914_p_data_out_3),
        .p_data_tri_select(ad9914_p_data_tri_select_3)
    );

    generate
        for(i=0;i<8;i=i+1) begin : ad9914_ctrl_inst_3_p_data_tri
            IOBUF
            #(
                .DRIVE(12), // Specify the output drive strength
                .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
                .IOSTANDARD("DEFAULT"), // Specify the I/O standard
                .SLEW("SLOW") // Specify the output slew rate
            )
            IOBUF_inst
            (
                .I(ad9914_p_data_out_3[i]),
                .O(ad9914_p_data_in_3[i]),
                .T(ad9914_p_data_tri_select_3),
                .IO(p_data_3[i])
            );
        end
    endgenerate


    ///////////////////ad9914 4//////////////////////////
    wire ad9914_p_data_tri_select_4;
    wire [7:0] ad9914_p_data_in_4;
    wire [7:0] ad9914_p_data_out_4;

    ad9914_ctrl #(
        .MASTER_RESET_DELAY_NUM(8)
    )
    ad9914_ctrl_inst_4 (
        .clk(clk),
        .rst(rst),

        .update(ad9914_update[3]),
        .lower_limit(ad9914_ftw_l_4),
        .upper_limit(ad9914_ftw_u_4),
        .positive_step(0),
        .positive_rate(145),
        .resweep_period(0),

        .busy(ad9914_busy[3]),
        .finish(),

        .trig(),
        .pre_trig(),
        .resweep(),

        .osk(osk_4),
        .dover(dover_4),
        .dhold(dhold_4),
        .io_update(io_update_4),
        .master_reset(master_reset_4),
        .dctrl(dctrl_4),
        .profile_select(profile_select_4),
        .function_select(function_select_4),

        .p_pwd(p_pwd_4),
        .p_rd(p_rd_4),
        .p_wr(p_wr_4),
        .p_addr(p_addr_4),
        .p_data_in(ad9914_p_data_in_4),
        .p_data_out(ad9914_p_data_out_4),
        .p_data_tri_select(ad9914_p_data_tri_select_4)
    );

    generate
        for(i=0;i<8;i=i+1) begin : ad9914_ctrl_inst_4_p_data_tri
            IOBUF
            #(
                .DRIVE(12), // Specify the output drive strength
                .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
                .IOSTANDARD("DEFAULT"), // Specify the I/O standard
                .SLEW("SLOW") // Specify the output slew rate
            )
            IOBUF_inst
            (
                .I(ad9914_p_data_out_4[i]),
                .O(ad9914_p_data_in_4[i]),
                .T(ad9914_p_data_tri_select_4),
                .IO(p_data_4[i])
            );
        end
    endgenerate

    //////////////////////////work flow//////////////////////////////////
    reg [7:0] fsm_state = 8'd0;
    integer j;
    always @ (posedge clk) begin
        if(!rst) begin
            ad9914_update_reg <= 4'b0000;
            fsm_state <= 8'd0;
        end 
        else begin
            case(fsm_state)
                0 : begin
                    ad9914_update_reg <= 4'b1111;
                    fsm_state <= 8'd1;
                end
                1 : begin
                    for(j=0;j<4;j++)
                        ad9914_update_reg[j] <= (ad9914_update_reg[j] ? ad9914_update_reg[j] ^ ad9914_busy[j] : 0);
                    fsm_state <= 8'd1;
                end
            endcase
        end
    end

endmodule