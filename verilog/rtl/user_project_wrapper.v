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
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
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
       // Internal UART0,SPDX
    input  [`MPRJ_IO_PADS-13:1] io_in, 

    // sensor CIS_data input (d9-d0)   , io_in [36:27]
    input  [`MPRJ_IO_PADS-1:28] io_in, 
    
    // analog_io_in for MIPI_clk_N,MIPI_clk_P,MIPI_D0_N,MIPI_D0_P,MIPI_D1_N,MIPI_D1_P
    // analog_io_in[15:10]
    inout  [`MPRJ_IO_PADS_1-3:11] analog_io,

    // analog_io_out for DAC_cabin,DAC_outN 
    // analog_io_iout[18:18]
    inout [`MPRJ_IO_PADS_1:`MPRJ_IO_PADS_1] analog_io,

       // analog_io_out for  AD1 
       // analog_io_out[19:19]
    inout [`MPRJ_IO_PADS_2+1:`MPRJ_IO_PADS_2+1] analog_io, 

    //(CIS:PICLK,HSYNC,VSYNC,XCLK,RST)  
    input  [`MPRJ_IO_PADS-1:MPRJ_IO_PADS-1] io_in, 

    output [`MPRJ_IO_PADS:MPRJ_IO_PADS-1] io_out
   output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [3:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

user_proj_example mprj (
`ifdef USE_POWER_PINS

        inout vdda1,	// User area 1 3.3V supply
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
        //(CIS_data: D9 - D0)  
    .io_in ({io_in[36:27]}),

        //(MIPI_clk_P,MIPI_clk_N),(MIPI_D1_P,MIPI_D1_N),(MIPI_D0_P,MIPI_D0_N),
    .analog_io_in ({analog_io_in[15:14],analog_io_in[13:12],analog_io_in[11:10]}),
    
       //(DAC_outN),disable on OCT-12-2023
    //.analog_io_in ({analog_io_in[17:17]}), 
    
       //(DAC_cabin),
    .analog_io_in ({analog_io_in[18:18]}),

        //AD1 convert analog input 
        //DISABLE, AD0 conver analog input), OCT-17-2023
    .analog_io_in ({analog_io_in[19:19]}),
    
     //(CIS:PICLK,HSYNC,VSYNC,XCLK,RST)  
    //.io_in ({io_in[24:20]}), change to port (36 :32)
    .io_in ({io_in[36:32]}), // OCT-17-2023 disable

        //(UART0 TX,RX),
    .io_in ({io_in[6:5]})   
        //(SDO,SDI,CSB,SCK) , 
    .io_in ({io_in[4:4],io_in[3:3],io_in[2:2],io_in[1:1]}),
    
        //(PWM_1) 
    .io_out({io_out[37:37]}),
    
    .io_oeb({io_oeb[37:30],io_oeb[7:0]}),

    // IRQ
      // To manage the arbitration for AMI bus among slave axi element.
    .irq(user_irq) ({user_irq[3:0]}),
;

endmodule	// user_project_wrapper

`default_nettype wire
