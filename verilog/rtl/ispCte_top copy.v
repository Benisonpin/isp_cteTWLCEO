/*************************************************************************
    > File Name: ispCte_top.v
    > Author: Benison Pin
    > Mail: benison.pin@ctegroup.com.tw
    > Created Time: Thur 19 OCT. 2023 09:00:04 GMT
 ************************************************************************/
`timescale 1 ns / 1 ps

module ispCte_top
#(
	parameter BITS = 8,
	parameter WIDTH = 1280,
	parameter HEIGHT = 960,
	parameter BAYER = 2, //0:RGGB 1:GRBG 2:GBRG 3:BGGR

)
(
	input pclk,
	input rst_n,
	
	input in_href,
	input in_vsync,
	input [BITS-1:0] in_raw,
	
	output out_href,
	output out_vsync,
	output [BITS-1:0] out_y,
	
	input dpc_en, blc_en, bnr_en, dgain_en, demosic_en, wb_en, ccm_en, csc_en, gamma_en, nr2d_en, ee_en, stat_ae_en, stat_awb_en,


	input [15:0] stat_ae_rect_x, stat_ae_rect_y, stat_ae_rect_w, stat_ae_rect_h,
	output stat_ae_done,
	output [STAT_OUT_BITS-1:0] stat_ae_pix_cnt, stat_ae_sum,

	input stat_ae_hist_clk,
	input stat_ae_hist_out,
	input [STAT_HIST_BITS+1:0] stat_ae_hist_addr, //R,Gr,Gb,B
	output [STAT_OUT_BITS-1:0] stat_ae_hist_data,

	input [BITS-1:0] stat_awb_min, stat_awb_max,
	output stat_awb_done,
	output [STAT_OUT_BITS-1:0] stat_awb_pix_cnt, stat_awb_sum_r, stat_awb_sum_g, stat_awb_sum_b,

	input stat_awb_hist_clk,
	input stat_awb_hist_out,
	input [STAT_HIST_BITS+1:0] stat_awb_hist_addr, //R,G,B
);

`define USE_DPC 1
`define USE_BLC 1
`define USE_BNR 1
`define USE_DGAIN 1


	//输入打拍(减少输入逻辑延迟)
	wire in_href_o, in_vsync_o;
	wire [BITS-1:0] in_raw_o;
	vid_mux #(BITS) mux_in(pclk, rst_n, 1'b0, in_href, in_vsync, in_raw, 1'b0, 1'b0, {BITS{1'b0}}, in_href_o, in_vsync_o, in_raw_o);

// add the judgement after reset and clk enable, oct-22-2023 add
		assign rst_n = wb_rst_i
		assign pclk = wb_clk_i
		always @ (posedge pclk or negedge rst_n) begin
				if (!rst_n) begin
					href_reg <= 0;
					vsync_reg <= 0;
					data_reg <= 0;
				// read flash data
				// check I2c status
				isp_I2C_top i2c_status
				(
					.wb_clk_i(wb_clk_i),
					.wb_rst_i(wb_rst_i),
					.wbs_stb_i(wbs_stb_i),
					.wbs_cyc_i(wbs_cyc_i),
					.wbs_we_i(wbs_we_i),
					.wbs_sel_i(wbs_sel_i),
					.wbs_dat_i(wbs_dat_i),
					.wbs_adr_i(wbs_adr_i),
					.wbs_ack_o(wbs_ack_o),
					.wbs_dat_o(wbs_dat_o),
				)
			
				if (wbs_ack_o) begin
					mipi_csi_16_nx mipi_enable
					(.reset_in(rst_n),
					 .mipi_clk_p_in(clk_p),
					 .mipi_clk_n_in(clk_n),
					 .mipi_data_p_in(data_p),
					 .mipi_data_n_in(data_n),
					 .mipi_data_raw_hw(mipi_data_raw_hw),
					 .pclk_o(pclk_o),
					 .data_o(data_o),
					 .fsync_o(fsync_o),
					 .lsync_o(lsyn_o),
					 .cam_ctrl_in(cam_ctrl_in),
					 .cam_pwr_en_o(cam_pwr_en_o),
					 .cam_reset_o(cam_reset_o),
					 .cam_xmaster_o(cam_xmaster_o),
					 )
				assign wbs_dat_i = 	 mipi_data_raw_hw
				// module isp_top
				isp_top isp_start
				(
				.BITS("8"),
				.WIDTH("1280"),
				.HEIGHT ("960"),
				.BAYER ("3"), //0:RGGB 1:GRBG 2:GBRG 3:BGGR
				.GAMMA_TABLE_BITS ("8"),
				.NR2D_WEIGHT_BITS ("5"),
				.STAT_OUT_BITS ("32"),
				.STAT_HIST_BITS (BITS) //直方图横坐标位数(默认像素位深)
				)
				(
				.pclk(pclk),
				.rst_n(rst_n),
	
				.in_href(in_href),
				.in_vsync(in_vsync),
	 			.in_raw(in_raw[BITS-1:0]) ,
	
				.out_href(out_href),
				.out_vsync(out_vsync),
				.out_y(out_y[BITS-1:0]),
				.out_u(out_u[BITS-1:0]),
				.out_v(out_v[BITS-1:0]) ,
	
				.dpc_en(dpc_en),
				.blc_en(blc_en), 
				.bnr_en(bnr_en), 
				.dgain_en(dgain_en),
				.demosic_en(demosic_en), 
				.wb_en(wb_en), 
				.ccm_en(ccm_en), 
				.csc_en(csc_en)
				.gamma_en(gamma_en),
				.nr2d_en(nr2d_en),
				.ee_en(ee_en),
				.stat_ae_en(stat_ae_en), 
				.stat_awb_en(stat_awb_en),

				.dpc_threshold(dpc_threshold[BITS-1:0]),
		 		.blc_r(blc_r[BITS-1:0]),
		 		.blc_gr(blc_gr[BITS-1:0]), 
		 		.blc_gb(blc_gb[BITS-1:0]), 
				.blc_b(blc_b[BITS-1:0]),
		  		.nr_level(nr_level[3:0]),
				.dgain_gain(dgain_gain[7:0]),
		  		.dgain_offset(dgain_offset[BITS-1:0]),
		  		.wb_rgain(wb_rgain[7:0]),
		  		.wb_ggain(wb_ggain[7:0]),
		  		.wb_bgain(wb_bgain[7:0]),
		 		.ccm_rr(ccm_rr[7:0]) ,
		 		.ccm_rg(ccm_rg[7:0]) ,
		 		.ccm_rb(ccm_rb[7:0]) ,
		 		.ccm_gr(ccm_gr[7:0]) ,
				.ccm_gg(ccm_gg[7:0]) ,
				.ccm_gb(ccm_gb[7:0]) ,
		  		.ccm_br(ccm_br[7:0]), 
				.ccm_bg(ccm_bg[7:0]),
				.ccm_bb(ccm_bb[7:0]),
		        .gamma_table_clk(gamma_table_clk),
			    .gamma_table_wen(gamma_table_wen),
		        .gamma_table_ren(gamma_table_ren),
		  		.gamma_table_addr(gamma_table_addr[GAMMA_TABLE_BITS-1:0]),
			   	.gamma_table_wdata(gamma_table_wdata[GAMMA_TABLE_BITS-1:0]),
			  	.gamma_table_rdata(gamma_table_rdata[GAMMA_TABLE_BITS-1:0]),

				.nr2d_space_kernel(nr2d_space_kernel)[7*7*NR2D_WEIGHT_BITS-1:0] , //空域卷积核(7x7)
	 			.nr2d_color_curve_x(nr2d_color_curve_x[9*BITS-1:0])          ,//值域卷积核拟合曲线横坐标(9个坐标点)
	 			.nr2d_color_curve_y(nr2d_color_curve_y[9*NR2D_WEIGHT_BITS-1:0])   ,//值域卷积核拟合曲线纵坐标(9个坐标点)

				.stat_ae_rect_x(stat_ae_rect_x[15:0]) , 
				.stat_ae_rect_y (stat_ae_rect_y[15:0]), 
				.stat_ae_rect_w(stat_ae_rect_w[15:0]) ,
				.stat_ae_rect_h(stat_ae_rect_h[15:0])  ,
	 			.stat_ae_done(stat_ae_done),
				.stat_ae_pix_cnt(stat_ae_pix_cnt[STAT_OUT_BITS-1:0] ), 
	 			.stat_ae_sum(stat_ae_sum[STAT_OUT_BITS-1:0]) , 

	 			.stat_ae_hist_clk(stat_ae_hist_clk),
	 			.stat_ae_hist_out(stat_ae_hist_out),
	 			.stat_ae_hist_addr(stat_ae_hist_addr[STAT_HIST_BITS+1:0]) , //R,Gr,Gb,B
	 			.stat_ae_hist_data(stat_ae_hist_data[STAT_OUT_BITS-1:0]) ,

	 			.stat_awb_min(stat_awb_min[BITS-1:0]) , 
				.stat_awb_max(stat_awb_max[BITS-1:0]) , 
	 			.stat_awb_done(stat_awb_done),
	 			.stat_awb_pix_cnt(stat_awb_pix_cnt[STAT_OUT_BITS-1:0]) ,
	 			.stat_awb_sum_r(stat_awb_sum_r[STAT_OUT_BITS-1:0]) 
	 			.stat_awb_sum_g(stat_awb_sum_g[STAT_OUT_BITS-1:0]) 
	 			.stat_awb_sum_b(stat_awb_sum_b[STAT_OUT_BITS-1:0]) 
	 			.stat_awb_hist_clk(stat_awb_hist_clk),
	 			.stat_awb_hist_out(stat_awb_hist_out),
	 			.stat_awb_hist_addr[STAT_HIST_BITS+1:0] , //R,G,B
				.stat_awb_hist_data[STAT_OUT_BITS-1:0] 
)
			// save to SDRAM {ccm_r_o,ccm_g_o,ccm_b_o}, SAVE R,G,B DATA TO SDRAM MEM
		//assign reg rgb_en = 1'b0
		//assign reg data_wr = 1'b0
			// rgb data whrite to fifo buffer
		fifo_mem fifo_rgb_wr
    	(
    	.data_out(video_active),
    	.fifo_full(fifo_full), 
    	.fifo_empty(fifo_empty), 
    	.fifo_threshold(fifo_threshold), 
    	.fifo_overflow(fifo_threshold), 
    	.fifo_underflow(fifo_underflow),
    	.clk(pclk), 
    	.rst_n(rst_n), 
    	.wr(wr), 
    	.rd(rd), 
    	.data_in(rgb888),
		);  
			
				// module DAC_cabin_out_data
			ntsc_composite_top_de2 DAC_cabin_out
			(

				
			)
				end
				else begin
			href_reg <= in_href;
			vsync_reg <= in_vsync;
			data_reg <= in_data;
		end
	end
	


`ifdef USE_DPC
	wire dpc_href, dpc_vsync;
	wire [BITS-1:0] dpc_raw;
	isp_dpc #(BITS, WIDTH, HEIGHT, BAYER) dpc_i0(pclk, rst_n&dpc_en, dpc_threshold, in_href_o, in_vsync_o, in_raw_o, dpc_href, dpc_vsync, dpc_raw);
	vid_mux #(BITS) mux_dpc_i0(pclk, rst_n, dpc_en, in_href_o, in_vsync_o, in_raw_o, dpc_href, dpc_vsync, dpc_raw, dpc_href_o, dpc_vsync_o, dpc_raw_o);
`else
	assign dpc_href_o = in_href_o;
	assign dpc_vsync_o = in_vsync_o;
	assign dpc_raw_o = in_raw_o;
`endif

	wire blc_href_o, blc_vsync_o;
	wire [BITS-1:0] blc_raw_o;
`ifdef USE_BLC
	wire blc_href, blc_vsync;
	wire [BITS-1:0] blc_raw;
	isp_blc #(BITS, WIDTH, HEIGHT, BAYER) blc_i0(pclk, rst_n&blc_en, blc_r, blc_gr, blc_gb, blc_b, dpc_href_o, dpc_vsync_o, dpc_raw_o, blc_href, blc_vsync, blc_raw);
	vid_mux #(BITS) mux_blc_i0(pclk, rst_n, blc_en, dpc_href_o, dpc_vsync_o, dpc_raw_o, blc_href, blc_vsync, blc_raw, blc_href_o, blc_vsync_o, blc_raw_o);
`else
	assign blc_href_o = dpc_href_o;
	assign blc_vsync_o = dpc_vsync_o;
	assign blc_raw_o = dpc_raw_o;
`endif

	wire bnr_href_o, bnr_vsync_o;
	wire [BITS-1:0] bnr_raw_o;
`ifdef USE_BNR
	wire bnr_href, bnr_vsync;
	wire [BITS-1:0] bnr_raw;
	isp_bnr #(BITS, WIDTH, HEIGHT, BAYER) bnr_i0(pclk, rst_n&bnr_en, nr_level, blc_href_o, blc_vsync_o, blc_raw_o, bnr_href, bnr_vsync, bnr_raw);
	vid_mux #(BITS) mux_bnr_i0(pclk, rst_n, bnr_en, blc_href_o, blc_vsync_o, blc_raw_o, bnr_href, bnr_vsync, bnr_raw, bnr_href_o, bnr_vsync_o, bnr_raw_o);
`else
	assign bnr_href_o = blc_href_o;
	assign bnr_vsync_o = blc_vsync_o;
	assign bnr_raw_o = blc_raw_o;
`endif

	wire dgain_href_o, dgain_vsync_o;
	wire [BITS-1:0] dgain_raw_o;
`ifdef USE_DGAIN
	wire dgain_href, dgain_vsync;
	wire [BITS-1:0] dgain_raw;
	isp_dgain #(BITS, WIDTH, HEIGHT) dgain_i0(pclk, rst_n&dgain_en, dgain_gain, dgain_offset, bnr_href_o, bnr_vsync_o, bnr_raw_o, dgain_href, dgain_vsync, dgain_raw);
	vid_mux #(BITS) mux_dgain_i0(pclk, rst_n, dgain_en, bnr_href_o, bnr_vsync_o, bnr_raw_o, dgain_href, dgain_vsync, dgain_raw, dgain_href_o, dgain_vsync_o, dgain_raw_o);
`else
	assign dgain_href_o = bnr_href_o;
	assign dgain_vsync_o = bnr_vsync_o;
	assign dgain_raw_o = bnr_raw_o;
`endif


	assign out_href = ee_href_o;
	assign out_vsync = ee_vsync_o;
	assign out_y = ee_y_o;
	assign out_u = ee_u_o;
	assign out_v = ee_v_o;
endmodule

module data_delay
#(
	parameter BITS = 8,
	parameter DELAY = 5
)
(
	input clk,
	input rst_n,

	input  [BITS-1:0] in_data,
	output [BITS-1:0] out_data
);

	reg [BITS-1:0] data_buff [DELAY-1:0];
	always @ (posedge clk or negedge rst_n) begin : _blk_delay
		integer i;
		if (!rst_n) begin
			for (i = 0; i < DELAY; i = i + 1)
				data_buff[i] <= 0;
		end
		else begin
			data_buff[0] <= in_data;
			for (i = 1; i < DELAY; i = i + 1)
				data_buff[i] <= data_buff[i-1];
		end
	end

	assign out_data = data_buff[DELAY-1];
endmodule

module vid_mux
#(
	parameter BITS = 8
)
(
	input pclk,
	input rst_n,

	input sel,

	input in_href_0,
	input in_vsync_0,
	input [BITS-1:0] in_data_0,

	input in_href_1,
	input in_vsync_1,
	input [BITS-1:0] in_data_1,

	output out_href,
	output out_vsync,
	output [BITS-1:0] out_data
);

	wire in_href = sel ? in_href_1 : in_href_0;
	wire in_vsync = sel ? in_vsync_1 : in_vsync_0;
	wire [BITS-1:0] in_data = sel ? in_data_1 : in_data_0;

	reg href_reg, vsync_reg;
	reg [BITS-1:0] data_reg;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			href_reg <= 0;
			vsync_reg <= 0;
			data_reg <= 0;
		end
		else begin
			href_reg <= in_href;
			vsync_reg <= in_vsync;
			data_reg <= in_data;
		end
	end
	
	assign out_href = href_reg;
	assign out_vsync = vsync_reg;
	assign out_data = data_reg;
endmodule

