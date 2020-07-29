`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:07:29 07/27/2020 
// Design Name: 
// Module Name:    protocol 
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
module protocol
#(
    parameter MAIN_CLK_FREQ = 120000000,// 时钟clk频率
    parameter UART_BAUD = 115200 //串口波特率
)
(
    input clk,
    input rst,

    //uart
    input uart_rx,
    output uart_tx,

    //数据帧输出
    input cmd_out_en,
    output reg [127:0] cmd,
    output reg cmd_ready,

    output reg crc_err
);

    wire cmd_dout_dready;
    wire [7:0] cmd_dout;
    wire cmd_dout_en;
    cmd_rx #(
        .MAIN_CLK_FREQ(120000000),
        .UART_BAUD(115200)
    )
    cmd_rx_inst (
        .clk(clk),
        .rst(!rst),

        //uart
        .uart_rx(uart_rx),

        //cmd out
        .data_ready(cmd_dready),
        .data_en(cmd_dout_en),
        .data(cmd_dout),

        .overwrite_flag()
    );


    wire [7:0] cmd_din;
    wire cmd_din_en;
    wire cmd_din_overwrite;
    cmd_tx #(
        .MAIN_CLK_FREQ(120000000),
        .UART_BAUD(115200)
    )
    cmd_tx_inst (
        .clk(clk),
        .rst(!rst),

        .uart_tx(uart_tx),

        .data_load(cmd_din_en),
        .data(cmd_din),

        .overwrite_flag(cmd_din_overwrite)
    );

    reg [4:0] sta_cur = 0;
    reg [7:0] acc_res = 0;
    reg [5:0] byte_index = 0;

    reg cmd_dout_en_reg = 1'b0;
    
    always @ (posedge clk) begin
        if(!rst) begin
            cmd_dout_en_reg <= 1'b0;
            acc_res <= 0;
            crc_err <= 0;
            cmd_ready <= 0;
            sta_cur <= 0;
        end
        else begin
            case (sta_cur)
                0 : begin
                    byte_index <= 0;
                    acc_res <= 0;
                    sta_cur <= 1;
                end
                1 : begin
                    if(cmd_dout_dready)
                        sta_cur <=2;
                end
                2 : begin
                    cmd_dout_en_reg <= 1;
                    sta_cur <= 3;
                end
                3 : begin
                    cmd_dout_en_reg <= 0;
                    sta_cur <= 4;
                end
                4 : begin
                    cmd[byte_index] <= cmd_dout;
                    byte_index <= byte_index + 1;
                    sta_cur <= 5;
                end
                5 : begin
                    if(byte_index != 6'd16) 
                        sta_cur <= 1;
                    else begin
                        byte_index <= 0;
                        if((cmd[0] == 8'haa) 
                            && (cmd[1] == 8'ha7) 
                            && (cmd[14] == 8'ha7) 
                            &&(cmd[15] == 8'haa)) begin
                            acc_res <= 0;
                            sta_cur <= 6;
                        end
                        else sta_cur <= 9;
                    end
                end
                //计算校验和
                6 : begin
                    acc_res <= acc_res + cmd[byte_index];
                    sta_cur <= 7;
                end
                7 : begin
                    byte_index <= byte_index + 1;
                    sta_cur <= 8;
                end
                8 : begin
                    if(byte_index != 6'h13)
                        sta_cur <= 6;
                    else begin
                        if(acc_res != cmd[13]) begin
                            crc_err <= 1;
                            byte_index <= 0;
                            sta_cur <= 9;
                        end
                        else begin
                            crc_err <= 0;
                            sta_cur <= 12;
                        end
                    end
                end
                //删除第一个字节
                9 : begin
                    cmd[byte_index] <= cmd[byte_index+1];
                    sta_cur <= 10;
                end
                10 : begin
                    byte_index <= byte_index + 1;
                    sta_cur <= 11;
                end
                11 : begin
                    if(byte_index != 8'h15) 
                        sta_cur <= 9;
                    else sta_cur <= 1;
                end
                //一帧接收完成
                12 : begin
                    cmd_ready <= 1;
                    sta_cur <= 13;
                end
                13 : begin
                    if(cmd_out_en) begin
                        cmd_ready <= 0;  
                        sta_cur <= 0;
                    end
                end
            endcase
        end
    end
    
endmodule