`define ALL_DATA  32'h3000_0000
`define SS_LAST   32'h3000_0004
`define TAP_DONE  32'hF000_0000
`define DATA_DONE 32'hFF00_0000
`define FIRDONE   3'd4

module wb2axi #(
    parameter pDATA_WIDTH = 32,
    parameter pADDR_WIDTH = 12
)(
    // wishbone Slave ports
    input                             wb_clk_i,
    input                             wb_rst_i,

    input    wire                     wbs_stb_i,
    input    wire                     wbs_cyc_i,
    input    wire                     wbs_we_i,
    input    wire [3:0]               wbs_sel_i,
    input    wire [pDATA_WIDTH-1:0]   wbs_dat_i,
    input    wire [pDATA_WIDTH-1:0]   wbs_adr_i,
    output   wire                     wbs_ack_o,
    output   wire [pDATA_WIDTH-1:0]   wbs_dat_o,

    // AXI Lite
    input    wire                     awready,
    output   wire [(pADDR_WIDTH-1):0] awaddr,  // write address
    output   wire                     awvalid,

    input    wire                     wready,
    output   wire                     wvalid,  // write data
    output   wire [(pDATA_WIDTH-1):0] wdata,

    input    wire                     arready,
    output   wire [(pADDR_WIDTH-1):0] araddr,  // read address
    output   wire                     arvalid,

    input    wire                     rvalid, 
    input    wire [(pDATA_WIDTH-1):0] rdata,    
    output   wire                     rready,  // read data

    // AXI Stream
    input    wire                     ss_tready, 
    output   wire                     ss_tvalid, // giving data Xn
    output   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    output   wire                     ss_tlast, 

    input   wire                      sm_tvalid, 
    input   wire [(pDATA_WIDTH-1):0]  sm_tdata, 
    input   wire                      sm_tlast, 
    output  wire                      sm_tready  // output the result Yn
);

localparam TAP      = 0;
localparam AP_START = 1;
localparam DATA     = 2;
localparam DONE     = 3;

// wishbone
reg  wbs_ack_w, wbs_ack_r;
reg  [pDATA_WIDTH-1:0] wbs_dat_w, wbs_dat_r;
// axi-lite
reg  awvalid_w, awvalid_r, wvalid_w, wvalid_r, arvalid_w, arvalid_r;
reg  [pADDR_WIDTH-1:0] awaddr_w, awaddr_r; 
reg  [pDATA_WIDTH-1:0] wdata_w, wdata_r;
// axi stream
reg  ss_tvalid_w, ss_tvalid_r; 
reg  ss_tlast_w, ss_tlast_r;
reg  [pDATA_WIDTH-1:0] ss_tdata_w,  ss_tdata_r;
wire write_en;
wire tap_rd;
//
reg  [1:0] ns, ps;
wire invalidAddr;

// wishbone
assign wbs_ack_o = wbs_ack_r;
assign wbs_dat_o = wbs_dat_r;
// axi
assign awaddr  = awaddr_r;
assign awvalid = awvalid_r;
assign wdata   = wdata_r;
assign wvalid  = wvalid_r;
assign arvalid = arvalid_r;
assign araddr  = {pADDR_WIDTH{1'b0}};
assign rready  = 1'b1;
// axi stream
assign ss_tvalid = ss_tvalid_r;
assign ss_tlast  = ss_tlast_r;
assign ss_tdata  = ss_tdata_r;
assign sm_tready = 1'b1;
//
assign write_en = wbs_cyc_i & wbs_stb_i & wbs_we_i;
assign tap_rd   = awready & wready;
assign invalidAddr = (wbs_adr_i[31:20] != 12'h380);

always @(*) begin
    case(ps)
        TAP:      ns = (write_en && wbs_dat_i == `TAP_DONE) ? AP_START : TAP;
        AP_START: ns = DATA;
        DATA:     ns = (write_en && wbs_dat_i == `DATA_DONE) ? DONE : DATA;
        DONE:     ns = (rvalid && rdata == `FIRDONE) ? TAP : DONE;
        default:  ns = TAP;
    endcase
end

always @(*) begin
    if(write_en && ~wbs_ack_r) begin
        wbs_ack_w  = 1'b1;
        wbs_dat_w = wbs_dat_i;
    end else begin
        wbs_ack_w  = 1'b0;
        wbs_dat_w = wbs_dat_r;
    end
end

always @(*) begin
    case(ps)
        TAP: begin
            if(wbs_ack_r && tap_rd && wbs_adr_i != `TAP_DONE && invalidAddr) begin
                awvalid_w = 1'b1;
                wvalid_w  = 1'b1;
                awaddr_w  = awaddr_r + {{pADDR_WIDTH-3{1'b0}}, 3'd4};
                wdata_w   = wbs_dat_r;
            end else begin
                awvalid_w = 1'b0;
                wvalid_w  = 1'b0;
                awaddr_w  = awaddr_r;
                wdata_w   = wdata_r;
            end
            arvalid_w = 1'b0;
        end
        AP_START: begin
            awvalid_w = 1'b1;
            wvalid_w  = 1'b1;
            awaddr_w  = {pADDR_WIDTH{1'b0}};
            wdata_w   = {{pDATA_WIDTH-1{1'b0}}, 1'b1};
            arvalid_w = 1'b0;
        end
        DONE: begin
            awvalid_w = 1'b0;
            wvalid_w  = 1'b0;
            awaddr_w  = {pADDR_WIDTH{1'b0}};
            wdata_w   = {pDATA_WIDTH{1'b0}};
            arvalid_w = 1'b1;
        end
        default: begin
            awvalid_w = 1'b0;
            wvalid_w  = 1'b0;
            awaddr_w  = {pADDR_WIDTH{1'b0}};
            wdata_w   = {pDATA_WIDTH{1'b0}};
            arvalid_w = 1'b0;
        end
    endcase
end

always @(*) begin
    case(ps)
        DATA: begin
            if(write_en && invalidAddr && ~ss_tvalid_r) begin
                ss_tvalid_w = 1'b1;
                ss_tdata_w  = wbs_dat_i;
            end else begin
                ss_tvalid_w = 1'b0;
                ss_tdata_w  = ss_tdata_r;
            end
            if(write_en && wbs_adr_i == `SS_LAST && invalidAddr) begin
                ss_tlast_w = 1'b1;
            end else begin
                ss_tlast_w = 1'b0;
            end
        end
        default: begin
            ss_tdata_w  = {pDATA_WIDTH{1'b0}};
            ss_tlast_w  = 1'b0;
            ss_tvalid_w = 1'b0;
        end
    endcase
end

//=====================================================================

always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        ps <= TAP;
    end else begin
        ps <= ns;
    end
end

always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        wbs_ack_r <= 1'b0;
        wbs_dat_r <= {pDATA_WIDTH{1'b0}};
    end else begin
        wbs_ack_r <= wbs_ack_w;
        wbs_dat_r <= wbs_dat_w;
    end
end


always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        awvalid_r <= 1'b0;
        awaddr_r  <= 12'd28;
        wvalid_r  <= 1'b0;
        wdata_r   <= {pDATA_WIDTH{1'b0}};
        arvalid_r <= 1'b0;
    end else begin
        awvalid_r <= awvalid_w;
        awaddr_r  <= awaddr_w;
        wvalid_r  <= wvalid_w;
        wdata_r   <= wdata_w;
        arvalid_r <= arvalid_w;
    end
end


always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        ss_tvalid_r <= 1'b0;
        ss_tlast_r  <= 1'b0;
        ss_tdata_r  <= {pDATA_WIDTH{1'b0}};
    end else begin
        ss_tvalid_r <= ss_tvalid_w;
        ss_tlast_r  <= ss_tlast_w;
        ss_tdata_r  <= ss_tdata_w;
    end
end

endmodule

