/*
//Copyright 2021 S SIVA PRASAD ssprasad12a@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

`timescale 1ns / 1ps
//`include "sky130_sram_2kbyte_1rw1r_32x512_8.v"

module peripheral_i2c_top(

	input         	wb_clk_i,
	input        	wb_rst_i,
	input         	wbs_stb_i,
	input        	wbs_cyc_i,
	input        	wbs_we_i,
	input [3:0]  	wbs_sel_i,
	input [31:0]  	wbs_dat_i,
	input [31:0] 	wbs_adr_i,
	output   	   wbs_ack_o,
	output [31:0]	wbs_dat_o,
    	
	// i2c ports
	input  	sda_i,
	input  	scl_i,
	output 	sda_o,
	output	scl_o,
	output 	sda_t,
	output 	scl_t,    
   output  [4:0] 	spi_dir,  // mosi , miso , sclk, ssel1, ssel0
   output   scl_dir,
   output   sda_dir,
    );
 
wire clock;
assign clock = wb_clk_i;

wire rst;
assign rst = wb_rst_i;
 
wire rst_n;

//i2c
wire [31:0]   i2c_apb_addr  ;
wire          i2c_apb_sel   ;
wire          i2c_apb_write ;
wire          i2c_apb_ena   ;
wire [31:0]   i2c_apb_wdata ;
wire [31:0]   i2c_apb_rdata ;
wire [3:0]    i2c_apb_pstb  ;


 
 assign i2c_apb_rdata = {i2crdata,i2crdata,i2crdata,i2crdata};
 wire [7:0] i2crdata;
 i2c_ssp u_iic_0 (
  .clock            (clock),
  .reset            (rst_n),
  .io_PCLK          (clock),
  .io_PRESETn       (rst_n),
  .io_PADDR         (i2c_apb_addr[7:0]),
  .io_PPROT         (1'b0),
  .io_PSEL          (i2c_apb_sel),
  .io_PENABLE       (i2c_apb_ena),
  .io_PWRITE        (i2c_apb_write),
  .io_PWDATA        (i2c_apb_wdata[7:0]),
  .io_PSTRB         (1'b0),
  .io_PREADY        (i2c_apb_rready),
  .io_PRDATA        (i2crdata),
  .io_PSLVERR       (),
  .io_irq           (),
  .io_sda_t         (sda_t),
  .io_sda_o         (sda_o),
  .io_sda_i         (sda_i),
  .io_scl_t         (scl_t),
  .io_scl_o         (scl_o),
  .io_scl_i         (scl_i),
  .io_doOpcodeio    (),
  .io_iiccount      (),
  .io_txbitc        (),
  .io_readl         (),
  .io_txcio         (),
  .io_rxcio         (),
  .io_startsentio   (),
  .io_stopsentio    (),
  .io_rstartsentio  (),
  .io_nackio        ()
 );


 // direction control
 
 dirctrl_ssp u_sysctrl_0 (
    .clock	(clock),
    .rst_n	(!wb_rst_i),
    .apb_addr	(dir_apb_addr),
    .apb_sel	(dir_apb_sel),
    .apb_write	(dir_apb_write),
    .apb_ena	(dir_apb_ena),
    .apb_wdata	(dir_apb_wdata),
    .apb_rdata	(dir_apb_rdata),
    .apb_pstb	(dir_apb_pstb),
    .apb_rready (),
    .uart_txd_dir (uart_txd_dir),
    .uart_rxd_dir (uart_rxd_dir),
    .spi_dir (spi_dir),
    
    .scl_dir (scl_dir),
    .sda_dir (sda_dir),
    
    .pwm_dir (pwm_dir),
    .led_dir (led_dir),
    .i2s_dir (i2s_dir),
    .rst_n_ctrl   (rst_n),
    .aud_clk_mux  (aud_clk_mux),
    .jtag_mux     (jtag_mux),
    .qspi_mux     (qspi_mux)
 );
 
 endmodule
