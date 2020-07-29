`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:03:09 07/27/2020 
// Design Name: 
// Module Name:    cmd_rx 
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
module cmd_rx
#(
    parameter MAIN_CLK_FREQ = 120000000,// 时钟clk频率
    parameter UART_BAUD = 115200 //串口波特率
)
(
    input clk,
    input rst,

    //uart
    input uart_rx,

    //cmd out
    output data_ready,
    output data_en,
    output [7:0] data,

    output overwrite_flag
);

    //串口数据接收
    wire uart_rx_ready;
    wire [7:0] uart_rx_byte;
    uart_rx #(
        .CLKS_PER_BIT(MAIN_CLK_FREQ / UART_BAUD)
    )
    uart_rx_inst (
        .i_Clock(clk),
        .i_Rx_Serial(uart_rx),
        .o_Rx_DV(uart_rx_ready),
        .o_Rx_Byte(uart_rx_byte)
    );

    wire fifo_full;
    wire fifo_empty;
    
    myfifo myfifo_rx_inst (
        .clk(clk),
        .rst(rst),
        .din(uart_rx_byte),
        .wr_en(uart_rx_ready),
        .rd_en(data_en),
        .dout(data),
        .full(fifo_full),
        .almost_full(overwrite_flag),
        .empty(fifo_empty)
    );

    assign data_ready = ~fifo_empty;


endmodule
