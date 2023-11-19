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

`include "digital_top.v"
/*
 *-------------------------------------------------------------
 *
 * user_analog_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user analog project.
 *
 *-------------------------------------------------------------
 */

module user_analog_project_wrapper (
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

    /* GPIOs.  There are 27 GPIOs, on either side of the analog.
     * These have the following mapping to the GPIO padframe pins
     * and memory-mapped registers, since the numbering remains the
     * same as caravel but skips over the analog I/O:
     *
     * io_in/out/oeb/in_3v3 [26:14]  <--->  mprj_io[37:25]
     * io_in/out/oeb/in_3v3 [13:0]   <--->  mprj_io[13:0]	
     *
     * When the GPIOs are configured by the Management SoC for
     * user use, they have three basic bidirectional controls:
     * in, out, and oeb (output enable, sense inverted).  For
     * analog projects, a 3.3V copy of the signal input is
     * available.  out and oeb must be 1.8V signals.
     */

    input  [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in,
    input  [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in_3v3,
    output [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_oeb,

    /* Analog (direct connection to GPIO pad---not for high voltage or
     * high frequency use).  The management SoC must turn off both
     * input and output buffers on these GPIOs to allow analog access.
     * These signals may drive a voltage up to the value of VDDIO
     * (3.3V typical, 5.5V maximum).
     * 
     * Note that analog I/O is not available on the 7 lowest-numbered
     * GPIO pads, and so the analog_io indexing is offset from the
     * GPIO indexing by 7, as follows:
     *
     * gpio_analog/noesd [17:7]  <--->  mprj_io[35:25]
     * gpio_analog/noesd [6:0]   <--->  mprj_io[13:7]	
     *
     */
    
    inout [`MPRJ_IO_PADS-`ANALOG_PADS-10:0] gpio_analog,
    inout [`MPRJ_IO_PADS-`ANALOG_PADS-10:0] gpio_noesd,

    /* Analog signals, direct through to pad.  These have no ESD at all,
     * so ESD protection is the responsibility of the designer.
     *
     * user_analog[10:0]  <--->  mprj_io[24:14]
     *
     */
    inout [`ANALOG_PADS-1:0] io_analog,

    /* Additional power supply ESD clamps, one per analog pad.  The
     * high side should be connected to a 3.3-5.5V power supply.
     * The low side should be connected to ground.
     *
     * clamp_high[2:0]   <--->  mprj_io[20:18]
     * clamp_low[2:0]    <--->  mprj_io[20:18]
     *
     */
    inout [2:0] io_clamp_high,
    inout [2:0] io_clamp_low,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq

);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

user_proj_example mprj (
`ifdef USE_POWER_PINS

    .Vdda1(vdda1),	// User area 1 3.3V supply
    .vdda2(vdda2),	// User area 2 3.3V supply
    .vssa1(vssa1),	// User area 1 analog ground
    .vssa2(vssa2),	// User area 2 analog ground
    .vccd1(vccd1),	// User area 1 1.8V supply
    .vccd2(vccd2),	// User area 2 1.8v supply
    .vssd1(vssd1),	// User area 1 digital ground
    .vssd2(vssd2),	// User area 2 digital ground
`endif

    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),

    // MGMT SoC Wishbone Slave

    .wbs_cyc_i(wbs_cyc_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_ack_o(wbs_ack_o),
    .wbs_dat_o(wbs_dat_o),

    // Logic Analyzer

    .la_data_in(la_data_in),
    .la_data_out(la_data_out),
    .la_oenb (la_oenb),

    // IO Pads (for ISP Project io)
    .io_in ({io_in[37:0]}),
    .io_out({io_out[37:0]}),
    .in_oeb ({io_oeb[37:0]}),
    .analog_io (analog_io),

    .pwm_out(pwm_out[37:37]),
    .sensor_io_out(sensor_io_out[36:20]),
    .i2c_in_in(i2c_in_in{26:25}) ,  // {w_sda_i,w_scl_i};
    .i2c_in_out(i2c_in_out[26:25]),
    .analog_AD_in(analog_AD_in[19:19]),
    .NTSC_out(NTSC_out[18]), 
    .MIPI_inout(MIPI_inout{15:10}),
    .uart_rx_tx(uart_rx_tx[5:4]),
    .spi_rx_tx(spi_rx_tx[3:0]),
    .user_clock2(user_clock2),
  //  .io_oeb({io_oeb[37:30],io_oeb[7:0]}),

    // IRQ
      // To manage the arbitration for AMI bus among slave axi element.
    .irq(user_irq) ({user_irq[2:0]}),
);

endmodule	// user_analog_project_wrapper
