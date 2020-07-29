`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:02:24 07/21/2020 
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
module prf_gen
#(
    parameter RF_DELAY_CLOCK_NUM = 120,
    parameter PRF_PHASE_DELAY_0_CLOCK_NUM = 600,
    parameter PRF_PHASE_DELAY_1_CLOCK_NUM = 840,
    parameter PRF_PHASE_DELAY_2_CLOCK_NUM = 1560,
    parameter PRF_PHASE_0_CLOCK_NUM = 12,
    parameter PRF_PHASE_1_CLOCK_NUM = 60,
    parameter PRF_PHASE_2_CLOCK_NUM = 240,
    parameter PRF_PHASE_3_CLOCK_NUM = 600
)
(
    input clk,
    input rst,

    input tr,
    input [1:0] tr_edge,

    output reg prf,
    output reg [1:0] prf_edge
);

    reg [7:0] fsm_state = 8'd0;
    reg [15:0] delay_count = 16'd0;
    always @ (posedge clk) begin
        if(!rst) begin
            fsm_state <= 8'd0;
            delay_count <= 16'd0;
            prf <= 1'b0;
        end
        else begin
            case (fsm_state)
                0 : begin
                    prf <= 1'b0;
                    if(tr_edge == 2'b01) begin
                        delay_count <= 16'd0;
                        fsm_state <= 8'd1;
                    end
                end
                1 : begin
                    if(delay_count >= RF_DELAY_CLOCK_NUM)
                        fsm_state <= 8'd2;
                    else delay_count <= delay_count + 16'd1;
                end
                //phase 0
                2 : begin
                    prf <= 1'b1;
                    delay_count <= 16'd0;
                    fsm_state <= 8'd3;
                end
                3 : begin
                    delay_count <= delay_count + 16'd1;
                    if(delay_count >= PRF_PHASE_0_CLOCK_NUM)
                        prf <= 1'b0;
                    if(delay_count >= PRF_PHASE_DELAY_0_CLOCK_NUM)
                        fsm_state <= 8'd4;
                end
                //phase 1
                4 : begin
                    prf <= 1'b1;
                    delay_count <= 16'd0;
                    fsm_state <= 8'd5;
                end
                5 : begin
                    delay_count <= delay_count + 16'd1;
                    if(delay_count >= PRF_PHASE_1_CLOCK_NUM)
                        prf <= 1'b0;
                    if(delay_count >= PRF_PHASE_DELAY_1_CLOCK_NUM)
                        fsm_state <= 8'd6;
                end
                //phase 2
                6 : begin
                    prf <= 1'b1;
                    delay_count <= 16'd0;
                    fsm_state <= 8'd7;
                end
                7 : begin
                    delay_count <= delay_count + 16'd1;
                    if(delay_count >= PRF_PHASE_2_CLOCK_NUM)
                        prf <= 1'b0;
                    if(delay_count >= PRF_PHASE_DELAY_2_CLOCK_NUM)
                        fsm_state <= 8'd8;
                end
                //phase 3
                8 : begin
                    prf <= 1'b1;
                    delay_count <= 16'd0;
                    fsm_state <= 8'd9;
                end
                9 : begin
                    delay_count <= delay_count + 16'd1;
                    if(delay_count >= PRF_PHASE_3_CLOCK_NUM) begin
                        prf <= 1'b0;
                        fsm_state <= 8'd0;
                    end
                end
            endcase
        end
    end


    always @ (posedge clk) begin
        if(!rst) begin
            prf_edge <= 2'b11;
        end 
        else begin
            prf_edge <= { prf_edge[0],prf};
        end
    end


    

    // wire [35:0] CONTROL0;
	// wire [19:0] TRIG0;
	// assign TRIG0[0] = tr;
	// assign TRIG0[1] = prf;
	// assign TRIG0[3:2] = tr_edge;
	// assign TRIG0[11:4] = fsm_state;
	
	// myila myila_inst (
	// 	.CONTROL(CONTROL0), // INOUT BUS [35:0]
	// 	.CLK(clk), // IN
	// 	.TRIG0(TRIG0) // IN BUS [99:0]
	// );

	// myicon myicon_inst (
    // 	.CONTROL0(CONTROL0) // INOUT BUS [35:0]
	// );

endmodule