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

//`default_nettype none
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
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/
localparam pDATA_WIDTH = 32;
localparam pADDR_WIDTH = 12;

wire awready;
wire awvalid;
wire [pADDR_WIDTH-1:0] awaddr;

wire wready;
wire wvalid;
wire [pDATA_WIDTH-1:0] wdata;

wire arready;
wire arvalid;
wire [pADDR_WIDTH-1:0] araddr;

wire rvalid;
wire rready;
wire [pDATA_WIDTH-1:0] rdata;

wire ss_tready;
wire ss_tvalid;
wire ss_tlast;
wire [pDATA_WIDTH-1:0] ss_tdata;

wire sm_tvalid;                
wire sm_tlast;
wire sm_tready;
wire [pDATA_WIDTH-1:0] sm_tdata;
wire [pDATA_WIDTH-1:0] wb2axi_dat, urpj_dat;
wire wb2axi_ack, urpj_ack;

wire [(pDATA_WIDTH-1):0] tap_Do;
wire [3:0]               tap_WE;
wire                     tap_EN;
wire [(pDATA_WIDTH-1):0] tap_Di;
wire [(pADDR_WIDTH-1):0] tap_A;

wire [(pDATA_WIDTH-1):0] data_Do;
wire [3:0]               data_WE;
wire                     data_EN;
wire [(pDATA_WIDTH-1):0] data_Di;
wire [(pADDR_WIDTH-1):0] data_A;

assign wbs_ack_o = (wbs_adr_i[31:16] == 32'h3000) ? wb2axi_ack : urpj_ack;
assign wbs_dat_o = (wbs_adr_i[31:16] == 32'h3000) ? wb2axi_dat : urpj_dat;

user_proj_example mprj (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .wbs_cyc_i(wbs_cyc_i),      // MGMT SoC Wishbone Slave
    .wbs_stb_i(wbs_stb_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_ack_o(urpj_ack),
    .wbs_dat_o(urpj_dat),
    .la_data_in(la_data_in),    // Logic Analyzer
    .la_data_out(la_data_out),
    .la_oenb (la_oenb),
    .io_in (io_in),             // IO Pads
    .io_out(io_out),
    .io_oeb(io_oeb),
    .irq(user_irq)              // IRQ
);


wb2axi #(
    .pDATA_WIDTH(pDATA_WIDTH),
    .pADDR_WIDTH(pADDR_WIDTH)
)wb2axi_inst(
    .wb_clk_i(wb_clk_i),        // Wishbone
    .wb_rst_i(wb_rst_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_ack_o(wb2axi_ack),
    .wbs_dat_o(wb2axi_dat),
    .awready(awready),          // AIX Lite
    .awvalid(awvalid),
    .awaddr(awaddr), 
    .wready(wready),
    .wvalid(wvalid), 
    .wdata(wdata),
    .arready(arready),
    .arvalid(arvalid),
    .araddr(araddr), 
    .rvalid(rvalid), 
    .rready(rready), 
    .rdata(rdata),  
    .ss_tready(ss_tready),      // AXI Stream
    .ss_tvalid(ss_tvalid),
    .ss_tdata(ss_tdata),
    .ss_tlast(ss_tlast),
    .sm_tvalid(sm_tvalid),
    .sm_tdata(sm_tdata),
    .sm_tlast(sm_tlast),
    .sm_tready(sm_tready)
);

(* DONT_TOUCH = "yes" *) fir #(
    .pDATA_WIDTH(pDATA_WIDTH),
    .pADDR_WIDTH(pADDR_WIDTH)
)fir_inst(
    .axis_clk(wb_clk_i),
    .axis_rst_n(wb_rst_i),
    // AIX Lite
    .awready(awready),
    .awvalid(awvalid),
    .awaddr(awaddr), 
    .wready(wready),
    .wvalid(wvalid), 
    .wdata(wdata),
    .arready(arready),
    .arvalid(arvalid),
    .araddr(araddr), 
    .rvalid(rvalid), 
    .rready(rready), 
    .rdata(rdata),  
    .ss_tready(ss_tready),      // AXI Stream
    .ss_tvalid(ss_tvalid),
    .ss_tdata(ss_tdata),
    .ss_tlast(ss_tlast),
    .sm_tvalid(sm_tvalid),
    .sm_tdata(sm_tdata),
    .sm_tlast(sm_tlast),
    .sm_tready(sm_tready),
    .tap_Do(tap_Do),            // tap BRAM
    .tap_WE(tap_WE),
    .tap_EN(tap_EN),
    .tap_Di(tap_Di),
    .tap_A(tap_A),
    .data_Do(data_Do),          // data BRAM
    .data_WE(data_WE),
    .data_EN(data_EN),
    .data_Di(data_Di),
    .data_A(data_A)
);

lutram #(
    .N(pADDR_WIDTH),
    .DEPTH(11)
)tapRAM(
    .CLK(wb_clk_i),
    .Do0(tap_Do),
    .WE0(tap_WE),
    .EN0(tap_EN),
    .Di0(tap_Di),
    .A0(tap_A)
);

lutram #(
    .N(pADDR_WIDTH),
    .DEPTH(11)
)dataRAM(
    .CLK(wb_clk_i),
    .Do0(data_Do),
    .WE0(data_WE),
    .EN0(data_EN),
    .Di0(data_Di),
    .A0(data_A)
);
//bram #(
//    .N(pADDR_WIDTH),
//    .DEPTH(11)
//)tapBRAM(
//    .CLK(wb_clk_i),
//    .Do0(tap_Do),
//    .WE0(tap_WE),
//    .EN0(tap_EN),
//    .Di0(tap_Di),
//    .A0(tap_A)
//);

//bram #(
//    .N(pADDR_WIDTH),
//    .DEPTH(11)
//)dataBRAM(
//    .CLK(wb_clk_i),
//    .Do0(data_Do),
//    .WE0(data_WE),
//    .EN0(data_EN),
//    .Di0(data_Di),
//    .A0(data_A)
//);

endmodule	// user_project_wrapper

`default_nettype wire
