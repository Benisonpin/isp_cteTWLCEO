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
)	mipi_enable
	(
	input pclk,
	input rst_n,	
	input [BITS-1:0] in_raw,
	
	output [BITS-1:0] out_y,
	output [BITS-1:0] out_u,
	output [BITS-1:0] out_v,
);

	always @ (posedge pclk or negedge rst_n) begin
			if (!rst_n) begin

				// module isp_top
			isp_top 
				#(
				.BITS("8"),
				.WIDTH("1280"),
				.HEIGHT ("960"),
				.BAYER ("3"), //0:RGGB 1:GRBG 2:GBRG 3:BGGR
				.GAMMA_TABLE_BITS ("8"),
				.NR2D_WEIGHT_BITS ("5"),
				.STAT_OUT_BITS ("32"),
				.STAT_HIST_BITS (BITS) //直方图横坐标位数(默认像素位深)
				) 
				isp_start
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
	// save RGB data to fifo_memory
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
	//		ntsc_composite_top_de2 DAC_cabin_out
	//		(
			
	//		)

		end
	end
	
endmodule

