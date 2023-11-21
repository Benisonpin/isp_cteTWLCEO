// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    //parameter BITS = 16  ,disable on CT-14-2023
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [38-1:0] io_in,
    output [38-1:0] io_out,
    output [38-1:0] io_oeb,
    inout [37:0] analog_io,

 
    // IO Pads (for ISP Project io)
    output  {mprj_io[37:37]} pwm_out,  //(PWM_1) 
    inout   {mprj_io[36:20]} sensor_io_out ,  //(CIS_data: D9 - D0) , //(CIS:PICLK,HSYNC,VSYNC,XCLK,RST),
    input   {mprj_io[26:25]} i2c_in_in ,  // {w_sda_i,w_scl_i};
    output  {mprj_io[26:25]} i2c_in_out ,  // {w_sda_o,w_scl_o};
    input   {mprj_io[19:19]} analog_AD_in , //AD1 convert analog input 
    output  {mprj_io[18:18]} NTSC_out, //(DAC_cabin)    
    input   {mprj_io[15:10]} MIPI_inout , //(MIPI_clk_P,MIPI_clk_N),(MIPI_D1_P,MIPI_D1_N),(MIPI_D0_P,MIPI_D0_N)
    inout   {mprj_io[5:4]} uart_rx_tx,  //(UART0 TX,RX),    
    inout   {mprj_io[3:0]} spi_rx_tx, //(SCK,CSB,SDI,SDO,)    
     
    input   user_clock2,
    // IRQ
    output [2:0] irq
);
    // assign clk & rst OCT-15.2023
    assign clk = user_clock2;
    assign rst = wb_rst_i;

    wire clk;
    wire rst;

    wire [BITS-1:0] rdata; 
    wire [BITS-1:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [BITS-1:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = {{(32-BITS){1'b0}}, rdata};
    assign wdata = wbs_dat_i[BITS-1:0];

    // IO
    assign io_out = MIPI_para;
    assign io_oeb = {(BITS){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused
 
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;
    assign la_data_out = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
   
    wire w_sda_i,w_scl_i,w_sda_o,w_scl_o,w_sda_t,w_scl_t;
    wire w_scl_dir, w_sda_dir;
     
   // i2c mapping
    assign io_out[26:25] = {w_sda_o,w_scl_o};
    assign io_oeb[26]    = w_sda_t ^ w_sda_dir; // the control from i2c will be inverted if w_sda_dir = 1
    assign io_oeb[25]    = w_scl_t ^ w_scl_dir;
    assign w_sda_i       = io_in[26];
    assign w_scl_i       = io_in[25];

    assign io_out[37] = 0;
    assign io_oeb[37] = 0;
   
  peripheral_I2C_top  I2C_protocal
  (
    .wb_clk_i    (wb_clk_i ),
    .wb_rst_i    (wb_rst_i ),
    .wbs_stb_i   (wbs_stb_i),
    .wbs_cyc_i   (wbs_cyc_i),
    .wbs_we_i    (wbs_we_i ),
    .wbs_sel_i   (wbs_sel_i),
    .wbs_dat_i   (wbs_dat_i),
    .wbs_adr_i   (wbs_adr_i),
    .wbs_ack_o   (wbs_ack_o),
    .wbs_dat_o   (wbs_dat_o),
  
    .sda_i       (w_sda_i),
    .scl_i       (w_scl_i),
    .sda_o       (w_sda_o),
    .scl_o       (w_scl_o),
    .sda_t       (w_sda_t),
    .scl_t       (w_scl_t),
    .spi_dir      (w_spi_dir),
    .scl_dir      (w_scl_dir),
    .sda_dir      (w_sda_dir),   
    );

    always @(posedge wb_clk_i) 
        begin
        if (wb_rst_i) 
            begin
//      1.01:  START Bit Detection
            always @(negedge sda_i or snegedge sda_o) 
                begin
                if (scl_o == 1 or scl_i == 1 ) 
                    begin
                    wbs_ack_o <= 1;
                    end
                if (sda_dir == 1) 
                    begin
                    assign wbs_dat_o = sda_i;
                    end
                else if (sda_dir == 0) 
                    begin
                    assign wbs_dat_o = sda_o;
                    end
    	        end
 //     1.02" START MIPI IP & LVDStop marco IP

            // Module LVDStop marco IP for mipi_clk
            LVDStop LVDS_MIPI_CLK0
                    (
                    .VDD(VDD),
                    .GND(GND),
                    .C1(C1),
                    .INP(MIPI_inout(15:15)),
                    .INN(MIPI_inout(14:14)),
                    .VABIASN(VBIASN),
                    .OUT(CLK_OUT),
                    )    
            // Module LVDStop marco IP for mipi_data_0
            LVDStop LVDS_MIPI_DATA_0
                    (
                    .VDD(VDD),
                    .GND(GND),
                    .C1(C1),
                    .INP(MIPI_inout(11:11)),
                    .INN(MIPI_inout(10:10)),
                    .VABIASN(VBIASN),
                    .OUT(MIPI_D0_OUT),
                    )  
                    
            //MIPI-0 Data in
            mipi_csi_rx_packet_decoder_8b2lane mipi0_enable
					(
                    .clk_i(CLK_OUT)
                    .data_valid_i(data_valid_i)
                    .data_i(MIPI_D0_OUT)
                    .data_0(data_0)
                    .output_valid_o(output_valid_o)
                    .packet_length_o(packet_length_o)
                    .packet_type_o(packet_type_o)      
                    .output_valid_reg(output_valid_lane_0)
                    )

            // isp module enable for lane0
            ispCte_top 
                #(.BITS(BITS)) isp_lane0
                    (   .pclk(pclk),
                        .rst_n(rst_n),
                        .([BITS-1:0]in_raw([BITS-1:0]output_valid_lane_0)),
                        .out_y(out_y_0),
                        .out_u(out_u_0),
                        .out_v(out_v_0)
                )
            	// module DAC_cabin_out_data
	//		ntsc_composite_top_de2 lane0_cabin_out



            // Module LVDStop marco IP for mipi_data_1
            LVDStop LVDS_MIPI_DATA_1
                    (
                    .VDD(VDD),
                    .GND(GND),
                    .C1(C1),
                    .INP(MIPI_inout(13:13)),
                    .INN(MIPI_inout(12:12)),
                    .VABIASN(VBIASN),
                    .OUT(MIPI_D1_OUT),
                    )                  
            //MIPI-1 Data in
            mipi_csi_rx_packet_decoder_8b2lane mipi1_enable
					(
                    .clk_i(CLK_OUT),
                    .data_valid_i(data_valid_i),
                    .data_i(MIPI_D1_OUT),
                    .data_0(data_0),
                    .output_valid_o(output_valid_o),
                    .packet_length_o(packet_length_o),
                    .packet_type_o(packet_type_o),      
                    .output_valid_reg(output_valid_lane_1),
                    )

            // isp module enable for lane1
            ispCte_top 
                #(.BITS(BITS)) isp_lane1
                    (   .pclk(pclk),
                        .rst_n(rst_n),
                        .([BITS-1:0]in_raw([BITS-1:0]output_valid_lane_1)),
                        .out_y(out_y_1),
                        .out_u(out_u_1),
                        .out_v(out_v_1)
                )
            	// module DAC_cabin_out_data
	//		ntsc_composite_top_de2 lane0_cabin_out


				assign wbs_dat_i = 	 mipi_data_raw_hw
				// module isp_top


            end
        end


endmodule  //user_proj_example

`default_nettype wire
