`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:37:12 01/18/2020 
// Design Name: 
// Module Name:    ad9914 
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
//WARNNING:When use ad9914 sync_clk as clock source,do not reset AD9914 by set MASTER_RESET HIGH!!!

module ad9914_ctrl
#(
	parameter [7 : 0] MASTER_RESET_DELAY_NUM = 10
)
(
	input clk,
	input rst,

	input update,
	input update_config,
	input sweep,
	input sweep_edge,//1-positive sweep,0-negitive sweep
	input [31 : 0] lower_limit,
	input [31 : 0] upper_limit,
	input [31 : 0] positive_step,
	input [31 : 0] negitive_step, 
	input [15 : 0] positive_rate,
	input [15 : 0] negitive_rate,

	output busy,
	output finish,

	input dover,
	output dhold,
	output io_update,
	output master_reset,
	output dctrl,
	output [2 : 0] profile_select,
	output [3 : 0] function_select,

	output p_pwd,
	output p_rd,
	output p_wr,
	output [7 : 0] p_addr,
	input [7 : 0] p_data_in,
	output [7 : 0] p_data_out,
	output p_data_tri_select
);

	//ad9914_reg_wr
	wire p_load;
	wire [7:0] reg_base_addr;
	wire [31:0] reg_wvar;
	wire [31:0] reg_rvar;
	wire [3:0] reg_byte_num;
	wire p_res;
	wire p_busy;
	wire p_finish;

	reg p_load_reg;
	reg [7:0] reg_base_addr_reg;
	reg [31:0] reg_wvar_reg;
	reg [3:0] reg_byte_num_reg;

	assign p_load = p_load_reg;
	assign reg_base_addr = reg_base_addr_reg;
	assign reg_wvar = reg_wvar_reg;
	assign reg_byte_num = reg_byte_num_reg;
	ad9914_reg_wr ad9914_reg_wr_inst
    (
		.clk(clk),
        .rst(rst),

        .load(p_load),
        .reg_base_addr(reg_base_addr),
        .reg_wvar(reg_wvar),
        .reg_rvar(reg_rvar),
        .reg_byte_num(reg_byte_num),
        .res(p_res),
        .busy(p_busy),
        .finish(p_finish),

        .io_update(io_update),
		
        //parallel port
        .p_pwd(p_pwd),//1-16bit,0-8bit
        .p_wr(p_wr),
        .p_rd(p_rd),
		.p_addr(p_addr),
		.p_wdata(p_data_out),
        .p_rdata(p_data_in),
        .data_tri_select(p_data_tri_select)
    );

	assign function_select = 4'b0000;
	assign profile_select = 3'b000;
	assign dhold = 0;
	
	reg dctrl_reg = 0;
	assign dctrl = dctrl_reg;

	reg master_reset_reg = 0;
	assign master_reset = master_reset_reg;
	
	reg busy_reg = 0;
	reg finish_reg = 1;
	assign busy = busy_reg;
	assign finish = finish_reg;

	//reg [31 : 0] sfr [3 : 0] = {32'h00_05_31_20,32'h00_00_19_1c,32'h00_04_29_00,32'h00_01_03_00};
	reg [31:0] sfr0 = 32'h00_01_03_00;
	reg [31:0] sfr1 = 32'h00_04_29_00;
	reg [31:0] sfr2 = 32'h00_00_19_1c;
	reg [31:0] sfr3 = 32'h00_05_31_20;

	reg [31 : 0] lower_limit_reg = 32'd1105322465;//1000MHz+/-125MHz,step=10KHz
	reg [31 : 0] upper_limit_reg = 32'd1421128884;
	reg [31 : 0] positive_step_reg = 32'd12632;
	reg [31 : 0] negitive_step_reg = 32'd12632; 
	reg [31 : 0] rate_reg = 32'h0001_0001_0001_0001;//count with sysclk/24
	reg sweep_edge_reg = 1'b1;

	reg [7 : 0] fsm_state_cur = 0;
	reg [31 : 0] delay_count = 0;
	
	always @ (posedge clk) begin
		if(!rst) begin
			busy_reg <= 0;
			finish_reg <= 1;
			
			p_load_reg <= 0;
			reg_base_addr_reg <= 0;
			reg_wvar_reg <= 0;
			reg_byte_num_reg <= 0;	

			dctrl_reg <= 0;

			fsm_state_cur <= 0;
		end
		else case(fsm_state_cur)
			//lock parameter and reset
			0 : begin
				dctrl_reg <= 0;
				fsm_state_cur <= 1;
			end
			1 : begin
				if(update) begin
					lower_limit_reg <= lower_limit;
					upper_limit_reg <= upper_limit;
					rate_reg <= {negitive_rate,positive_rate};
					busy_reg <= 1;
					finish_reg <= 0;
					fsm_state_cur <= 2;
				end
				else if(update_config) begin
					positive_step_reg <= positive_step;
					negitive_step_reg <= negitive_step;
					sweep_edge_reg <= sweep_edge;
					busy_reg <= 1;
					finish_reg <= 0;
					fsm_state_cur <= 19;
				end
				else if(sweep) begin
					busy_reg <= 1;
					finish_reg <= 0;
					fsm_state_cur <= 24;
				end
			end

			//write sfr0
			2 : begin 
				if(p_finish) begin
					reg_wvar_reg <= sfr0;
					reg_base_addr_reg <= 8'h00;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 3;
				end	
			end
			3 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 4;	
				end
			end

			//write sfr1
			4 : begin 
				if(p_finish) begin
					reg_wvar_reg <= sfr1;
					reg_base_addr_reg <= 8'h01;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 5;
				end	
			end
			5 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 6;	
				end
			end

			//write sfr2
			6 : begin 
				if(p_finish) begin
					reg_wvar_reg <= sfr2;
					reg_base_addr_reg <= 8'h02;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 7;
				end	
			end
			7 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 8;	
				end
			end

			//write sfr3
			8 : begin 
				if(p_finish) begin
					reg_wvar_reg <= sfr3;
					reg_base_addr_reg <= 8'h03;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 9;
				end	
			end
			9 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 10;	
				end
			end
			
			//lower_limit
			10 : begin 
				if(p_finish) begin
					reg_wvar_reg <= lower_limit_reg;
					reg_base_addr_reg <= 8'h04;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 11;
				end
			end
			11 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 12;
				end
			end
			
			//upper_limit
			12 : begin 
				if(p_finish) begin
					reg_wvar_reg <= upper_limit_reg;
					reg_base_addr_reg <= 8'h05;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 13;
				end
			end
			13 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 14;
				end
			end

			//sweep rate
			14 : begin 
				if(p_finish) begin
					reg_wvar_reg <= rate_reg;
					reg_base_addr_reg <= 8'h08;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 15;
				end
			end
			15 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 16;
				end
			end
			
			//ps:Amplitude Scale Factor 0
			16 : begin 
				if(p_finish) begin
					reg_wvar_reg <= 32'h0f_ff_00_00;
					reg_base_addr_reg <= 8'h0c;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 17;
				end
			end
			17 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 18;
				end
			end
			18 : begin
				if(p_finish && (!p_res)) begin
					busy_reg <= 0;
					finish_reg <= 1;
					fsm_state_cur <= 1;
				end
			end

			//sweep step
			19 : begin
				if(p_finish) begin
					reg_wvar_reg <= sfr1 & 32'hff_f7_ff_ff;
					reg_base_addr_reg <= 8'h01;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 20;
				end
			end
			20 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 21;
				end
			end
			21 : begin 
				if(p_finish) begin
					reg_wvar_reg <= (sweep_edge_reg ? positive_step_reg : negitive_step_reg);
					reg_base_addr_reg <= (sweep_edge_reg ? 8'h06 : 8'h07);
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 22;
				end
			end
			22 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 23;
				end
			end
			23 : begin
				if(p_finish && (!p_res)) begin
					busy_reg <= 0;
					finish_reg <= 1;
					fsm_state_cur <= 1;
				end
			end

			//enable sweep
			24 : begin
				if(p_finish) begin
					dctrl_reg <= (sweep_edge_reg ? 1 : 0);
					reg_wvar_reg <= sfr1 | 32'h00_08_00_00;
					reg_base_addr_reg <= 8'h01;
					reg_byte_num_reg <= 4;
					p_load_reg <= 1;
					fsm_state_cur <= 25;
				end
			end
			25 : begin
				if(p_busy) begin
					p_load_reg <= 0;
					fsm_state_cur <= 26;
				end
			end
			26 : begin
				if(p_finish && (!p_res)) begin
					busy_reg <= 0;
					finish_reg <= 1;
					//dctrl_reg <= (sweep_edge_reg ? 0 : 1);
					delay_count <= 0;
					fsm_state_cur <= 1;
				end
			end
		endcase
	end

	// wire [35:0] CONTROL0;
	// wire [99:0] TRIG0;
	// assign TRIG0[0] = update;
	// assign TRIG0[8:1] = fsm_state_cur;
	// assign TRIG0[9] = resweep_reg;
	// assign TRIG0[10] = osk;
	// assign TRIG0[11] = trig;
	// assign TRIG0[12] = dctrl;
	// assign TRIG0[13] = dover;
	// assign TRIG0[14] = resweep_osk_trig;
	// assign TRIG0[25] = p_load;
	// assign TRIG0[26] = p_wr;
	// assign TRIG0[27] = p_rd;
	// assign TRIG0[28] = p_finish;
	// assign TRIG0[36:29] = reg_index;
    // assign TRIG0[37] = io_update;
    // assign TRIG0[45:38] = p_data_in;
    // assign TRIG0[53:46] = reg_base_addr;
    // assign TRIG0[85:54] = reg_rvar;
    // assign TRIG0[86] = p_res;
	

	// myila myila_inst (
	// 	.CONTROL(CONTROL0), // INOUT BUS [35:0]
	// 	.CLK(clk), // IN
	// 	.TRIG0(TRIG0) // IN BUS [99:0]
	// );

	// myicon myicon_inst (
    // 	.CONTROL0(CONTROL0) // INOUT BUS [35:0]
	// );

endmodule