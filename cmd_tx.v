`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:15:38 07/27/2020 
// Design Name: 
// Module Name:    cmd_tx 
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
module cmd_tx
#(
    parameter MAIN_CLK_FREQ = 120000000,// 时钟clk频率
    parameter UART_BAUD = 115200 //串口波特率
)
(
    input clk,
    input rst,

    //uart
    output uart_tx,

    //cmd out
    input data_load,
    output [7:0] data,

    output overwrite_flag
);

    //串口数据发送
    wire uart_tx_load;
    wire uart_tx_done;
    wire [7:0] uart_tx_byte;
    uart_tx #(
        .CLKS_PER_BIT(MAIN_CLK_FREQ / UART_BAUD)
    )
    uart_tx_inst (
        .i_Clock(clk),
        .i_Tx_DV(uart_tx_load),
        .i_Tx_Byte(uart_tx_byte), 
        .o_Tx_Active(),
        .o_Tx_Serial(uart_tx),
        .o_Tx_Done(uart_tx_done)
    );

    wire fifo_empty;
    wire fifo_afull;
    myfifo myfifo_tx_inst (
        .clk(clk),
        .rst(rst),
        .din(data),
        .wr_en(data_load),
        .rd_en(uart_tx_load),
        .dout(uart_tx_byte),
        .full(overwrite_flag),
        .almost_full(fifo_afull),
        .empty(fifo_empty)
    );


endmodule
