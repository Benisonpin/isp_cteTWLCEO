/*
//Copyright 2021 S SIVA PRASAD ssprasad12a@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

`timescale 1ns / 1ps
//`include "sky130_sram_2kbyte_1rw1r_32x512_8.v"

module peripheral_top(

	input         	wb_clk_i,
	input        	wb_rst_i,
	input         	wbs_stb_i,
	input        	wbs_cyc_i,
	input        	wbs_we_i,
	input [3:0]  	wbs_sel_i,
	input [31:0]  	wbs_dat_i,
	input [31:0] 	wbs_adr_i,

	output   	wbs_ack_o,
	output [31:0]	wbs_dat_o,

	
	// gpio
    	input  [19:0]	gpi,
    	output [19:0] 	gpo,
    	output [19:0] 	gpd,
        
        //pwm
    	output [1:0]  	pwm_o,
    	
	// i2c ports
	input  	sda_i,
	input  	scl_i,
    
	output 	sda_o,
	output	scl_o,
    
	output 	sda_t,
	output 	scl_t,
	
         
        // direction signal for ports
 
    	output   	scl_dir,
    	output    	sda_dir,
    
    	output  [1:0]  pwm_dir,
        
 
        
        // jtag ports
   output        	TMS, 
  	input       	TDI,
  	output      	TCK,
  	output        	TDO,
  	
  	output      	jtag_mux,      // 0 is gpio else its jtag
           
    );
 
 /*
 assign q_io0_o = 0;
 assign q_io1_o = 0;
 assign q_io2_o = 0;
 assign q_io3_o = 0;
 assign q_io0_t = 0;
 assign q_io1_t = 0;
 assign q_io2_t = 0;
 assign q_io3_t = 0;
 assign q_spi_clk_o =0;
 assign q_spi_ssel_o = 0;
 assign lrclk =0;
 assign bclk= 0;
 assign audo= 0;
 assign TMS=0;
 assign TDO=0;
 assign TCK=0;
 
 */
 
 
 
 
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


//pwm
wire [31:0]   pwm_apb_addr  ;
wire          pwm_apb_sel   ;
wire          pwm_apb_write ;
wire          pwm_apb_ena   ;
wire [31:0]   pwm_apb_wdata ;
wire [31:0]   pwm_apb_rdata ;
wire [3:0]    pwm_apb_pstb  ;
  
  
 
//gpio
wire [31:0]   gpio_apb_addr   ;
wire          gpio_apb_sel    ;
wire          gpio_apb_write  ;
wire          gpio_apb_ena    ;
wire [31:0]   gpio_apb_wdata  ;
wire [31:0]   gpio_apb_rdata  ;
wire [3:0]    gpio_apb_pstb   ;


// timer
wire   [31:0] timer_apb_addr  ;
wire          timer_apb_sel   ;
wire          timer_apb_write ;
wire          timer_apb_ena   ;
wire   [31:0] timer_apb_wdata ;
wire   [31:0] timer_apb_rdata ;
wire   [3:0]  timer_apb_pstb  ;


//direction control
wire [31:0]   dir_apb_addr  ;
wire          dir_apb_sel   ;
wire          dir_apb_write ;
wire          dir_apb_ena   ;
wire [31:0]   dir_apb_wdata ;
wire [31:0]   dir_apb_rdata ;
wire [3:0]    dir_apb_pstb  ;


wire   [31:0]  qspi_apb_addr  ;  
wire           qspi_apb_sel   ;  
wire           qspi_apb_write ;  
wire           qspi_apb_ena   ;  
wire   [31:0]  qspi_apb_wdata ;  
wire   [3:0]   qspi_apb_pstb  ;  
wire   [31:0]  qspi_apb_rdata ;







// jtag controller
wire   [31:0]  jtag_apb_addr  ;  
wire           jtag_apb_sel   ;  
wire           jtag_apb_write ;  
wire           jtag_apb_ena   ;  
wire   [31:0]  jtag_apb_wdata ;  
wire   [3:0]   jtag_apb_pstb  ;  
wire   [31:0]  jtag_apb_rdata ;








//memory control 
/*
wire [31:0]   memo_apb_addr  ;
wire          memo_apb_sel   ;
wire          memo_apb_write ;
wire          memo_apb_ena   ;
wire [31:0]   memo_apb_wdata ;
wire [31:0]   memo_apb_rdata ;
wire [3:0]    memo_apb_pstb  ;
*/


wire   [31:0]  peripheral_apb_addr  ;  
wire           peripheral_apb_sel   ;  
wire           peripheral_apb_write ;  
wire           peripheral_apb_ena   ;  
wire   [31:0]  peripheral_apb_wdata ;  
wire   [3:0]   peripheral_apb_pstb  ;  
wire   [31:0]  peripheral_apb_rdata ;





 
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

 
 
 pwm_ssp u_pwm_0 (
 
    .clock      (clock), 
    .rstn       (rst_n),
    .apb_addr   (pwm_apb_addr),
    .apb_sel    (pwm_apb_sel),
    .apb_write  (pwm_apb_write),
    .apb_ena    (pwm_apb_ena),
    .apb_wdata  (pwm_apb_wdata),
    .apb_rdata  (pwm_apb_rdata),
    .apb_pstb   (pwm_apb_pstb),
    .apb_rready (), 
    .pwm_o      (pwm_o)
 
 
 );
 
 
 
 // gpio
  gpio_ssp u_gpio_0 (
    .clock        (clock),
    .rst_n        (rst_n),
    .apb_addr     (gpio_apb_addr ),
    .apb_sel      (gpio_apb_sel  ),
    .apb_write    (gpio_apb_write),
    .apb_ena      (gpio_apb_ena  ),
    .apb_wdata    (gpio_apb_wdata),
    .apb_rdata    (gpio_apb_rdata),
    .apb_pstb     (gpio_apb_pstb ),
    .apb_rready   (),
    .gpio_intr    (),
                 
    .gpi          (gpi),
    .gpo          (gpo),
    .gpd          (gpd)
  
 
 );
 
 //timer
     
 timer_ssp u_timer (   
  .clock                (clock),
  .rst_n                (rst_n),
  .apb_addr             (timer_apb_addr ),
  .apb_sel              (timer_apb_sel  ),
  .apb_write            (timer_apb_write),
  .apb_ena              (timer_apb_ena  ),
  .apb_wdata            (timer_apb_wdata),
  .apb_rdata            (timer_apb_rdata),
  .apb_pstb             (timer_apb_pstb ),
  .apb_rready           ()
  
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
    
    
    .scl_dir (scl_dir),
    .sda_dir (sda_dir),
    
    .pwm_dir (pwm_dir),
    
    .rst_n_ctrl   (rst_n),
    .jtag_mux     (jtag_mux),
  
 );
 
 

  jtag_ssp u_jtag (
  
  .clock     	(clock),	
  .reset	(rst_n),
  .io_PCLK 	(clock),
  .io_PRESETn	(rst_n),
  .io_PADDR	(jtag_apb_addr[7:0]),
  .io_PPROT	(1'b0),
  .io_PSEL	(jtag_apb_sel),
  .io_PENABLE	(jtag_apb_ena),	
  .io_PWRITE	(jtag_apb_write),	
  .io_PWDATA	(jtag_apb_wdata),	
  .io_PSTRB	(1'b0),
  .io_PREADY	(jtag_apb_rready),	
  .io_PRDATA	(jtag_apb_rdata),	
  .io_PSLVERR	()	,
  .io_TMS  	(TMS),
  .io_TCK   	(TCK),
  .io_TDO   	(TDO),
  .io_TDI 	(TDI),
  .io_JTAC 	(),
  .io_DIVI 	()
  
  
  
  );
 
  
 
wishbone2apb  u_wishbone2apb (
.wb_clk_i      (wb_clk_i ),
.wb_rst_i      (wb_rst_i ),
.wbs_stb_i     (wbs_stb_i),
.wbs_cyc_i     (wbs_cyc_i),
.wbs_we_i      (wbs_we_i ),
.wbs_sel_i     (wbs_sel_i),
.wbs_dat_i     (wbs_dat_i),
.wbs_adr_i     (wbs_adr_i),
              
.wbs_ack_o     (wbs_ack_o), 
.wbs_dat_o     (wbs_dat_o),
              
.s_apb_addr    (peripheral_apb_addr  ),
.s_apb_sel     (peripheral_apb_sel   ),
.s_apb_write   (peripheral_apb_write ),
.s_apb_ena     (peripheral_apb_ena   ),
.s_apb_wdata   (peripheral_apb_wdata ),
.s_apb_pstb    (peripheral_apb_pstb  ),
              
.s_apb_rdata   (peripheral_apb_rdata),
.s_apb_rready  (1'b1)
);
 
 
 
 apb_crossbar u_apb_crossbar (
 .s_apb_addr   (peripheral_apb_addr  ),
 .s_apb_sel    (peripheral_apb_sel   ),
 .s_apb_write  (peripheral_apb_write ),
 .s_apb_ena    (peripheral_apb_ena   ),
 .s_apb_wdata  (peripheral_apb_wdata ),
 .s_apb_rdata  (peripheral_apb_rdata ),
 .s_apb_pstb   (peripheral_apb_pstb  ),
 .s_apb_rready (),
              

 .m0_apb_addr   (uart_apb_addr ),
 .m0_apb_sel    (uart_apb_sel  ),
 .m0_apb_write  (uart_apb_write),
 .m0_apb_ena    (uart_apb_ena  ),
 .m0_apb_wdata  (uart_apb_wdata),
 .m0_apb_rdata  (uart_apb_rdata),
 .m0_apb_pstb   (uart_apb_pstb ),
 .m0_apb_rready (1'b1),           
               
 .m1_apb_addr   (spi_apb_addr ),
 .m1_apb_sel    (spi_apb_sel  ),
 .m1_apb_write  (spi_apb_write),
 .m1_apb_ena    (spi_apb_ena  ),
 .m1_apb_wdata  (spi_apb_wdata),
 .m1_apb_rdata  (spi_apb_rdata),
 .m1_apb_pstb   (spi_apb_pstb ),
 .m1_apb_rready (1'b1),
               
 .m2_apb_addr   (i2c_apb_addr ),
 .m2_apb_sel    (i2c_apb_sel  ),
 .m2_apb_write  (i2c_apb_write),
 .m2_apb_ena    (i2c_apb_ena  ),
 .m2_apb_wdata  (i2c_apb_wdata),
 .m2_apb_rdata  (i2c_apb_rdata),
 .m2_apb_pstb   (i2c_apb_pstb ),
 .m2_apb_rready (1'b1),
               
               
 .m3_apb_addr   (pwm_apb_addr ),
 .m3_apb_sel    (pwm_apb_sel  ),
 .m3_apb_write  (pwm_apb_write),
 .m3_apb_ena    (pwm_apb_ena  ),
 .m3_apb_wdata  (pwm_apb_wdata),
 .m3_apb_rdata  (pwm_apb_rdata),
 .m3_apb_pstb   (pwm_apb_pstb ),
 .m3_apb_rready (1'b1),
               
                
 .m5_apb_addr   (gpio_apb_addr  ),
 .m5_apb_sel    (gpio_apb_sel   ),
 .m5_apb_write  (gpio_apb_write ),
 .m5_apb_ena    (gpio_apb_ena   ),
 .m5_apb_wdata  (gpio_apb_wdata ),
 .m5_apb_rdata  (gpio_apb_rdata ),
 .m5_apb_pstb   (gpio_apb_pstb  ),
 .m5_apb_rready (1'b1),
                          
               
 .m6_apb_addr   (timer_apb_addr ),
 .m6_apb_sel    (timer_apb_sel  ),
 .m6_apb_write  (timer_apb_write),
 .m6_apb_ena    (timer_apb_ena  ),
 .m6_apb_wdata  (timer_apb_wdata),
 .m6_apb_rdata  (timer_apb_rdata),
 .m6_apb_pstb   (timer_apb_pstb ),
 .m6_apb_rready (1'b1),
 
 //i2s_apb_rdata
                
 .m8_apb_addr   (dir_apb_addr ),
 .m8_apb_sel    (dir_apb_sel  ),
 .m8_apb_write  (dir_apb_write),
 .m8_apb_ena    (dir_apb_ena  ),
 .m8_apb_wdata  (dir_apb_wdata),
 .m8_apb_rdata  (dir_apb_rdata),
 .m8_apb_pstb   (dir_apb_pstb ),
 .m8_apb_rready (1'b1),
 
 
 .m9_apb_addr   (jtag_apb_addr ),
 .m9_apb_sel    (jtag_apb_sel  ),
 .m9_apb_write  (jtag_apb_write),
 .m9_apb_ena    (jtag_apb_ena  ),
 .m9_apb_wdata  (jtag_apb_wdata),
 .m9_apb_rdata  (jtag_apb_rdata),
 .m9_apb_pstb   (jtag_apb_pstb ),
 .m9_apb_rready (1'b1),
 //jtag_apb_rdata
 .m10_apb_addr   (qspi_apb_addr ),
 .m10_apb_sel    (qspi_apb_sel  ),
 .m10_apb_write  (qspi_apb_write),
 .m10_apb_ena    (qspi_apb_ena  ),
 .m10_apb_wdata  (qspi_apb_wdata),
 .m10_apb_rdata  (qspi_apb_rdata),
 .m10_apb_pstb   (qspi_apb_pstb ),
 .m10_apb_rready (1'b1)
 //qspi_apb_rdata
 
 
 
 );
 
 
 
 endmodule
