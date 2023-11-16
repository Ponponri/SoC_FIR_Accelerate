module fir #(  
    parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)(
    input   wire                     axis_clk,
    input   wire                     axis_rst_n,
    // AXI Lite
    input   wire [(pADDR_WIDTH-1):0] awaddr,  // write address
    input   wire                     awvalid,
    output  wire                     awready,

    input   wire                     wvalid,  // write data
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  wire                     wready,

    input   wire [(pADDR_WIDTH-1):0] araddr,  // read address
    input   wire                     arvalid,
    output  wire                     arready,

    input   wire                     rready,  // read data
    output  wire                     rvalid, 
    output  wire [(pDATA_WIDTH-1):0] rdata,    

    // AXI Stream
    input   wire                     ss_tvalid, // giving data Xn
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  wire                     ss_tready, 

    input   wire                     sm_tready, // output the result Yn
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 

    // bram for tap RAM
    input   wire [(pDATA_WIDTH-1):0] tap_Do,
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  wire [(pADDR_WIDTH-1):0] tap_A,

    // bram for data RAM
    input   wire [(pDATA_WIDTH-1):0] data_Do,
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A
);

// write your code here!
localparam IDLE   = 3'd0;
localparam START  = 3'd1;
localparam DONE   = 3'd2;
localparam PEND   = 3'd3;
localparam FINISH = 3'd4;

// I/O
reg wready_w, wready_r;
reg rvalid_w, rvalid_r; 
reg [pDATA_WIDTH-1:0] rdata_w, rdata_r;    
reg ss_tready_w;
reg                     sm_tvalid_w, sm_tvalid_r;
reg [(pDATA_WIDTH-1):0] sm_tdata_w,  sm_tdata_r;
reg                     sm_tlast_w, sm_tlast_r;
// Coef BRAM
reg tap_EN_w, tap_EN_r;
reg [3:0] tap_WE_w, tap_WE_r;
reg [pDATA_WIDTH-1:0] tap_Di_w, tap_Di_r;
reg [pADDR_WIDTH-1:0] tap_A_w, tap_A_r;
// Data BRAM
reg [3:0]               data_WE_w, data_WE_r;
reg                     data_EN_w, data_EN_r;
reg [(pDATA_WIDTH-1):0] data_Di_w, data_Di_r;
reg [(pADDR_WIDTH-1):0] data_A_w,  data_A_r;
// cnt
reg  [3:0] cnt_w, cnt_r;
reg  [3:0] round_cnt_w, round_cnt_r;
// multiplier
wire signed [pDATA_WIDTH*2-1:0] mult_out;
reg  signed [pDATA_WIDTH-1:0]   mult_in0, mult_in1;
// adder
wire signed [pDATA_WIDTH-1:0] adder_out;
reg  signed [pDATA_WIDTH-1:0] adder_in0, adder_in1;
// 
wire tap_write_t;
wire readBack_t;
wire w_coef_addr;
wire r_coef_addr;
wire data_t;
wire ap_start;
wire round_done; 
wire readAddr0;
wire wb_addr0;
wire cnt_st;
wire done;
reg  last_w, last_r;
reg  [2:0] ns, ps;
reg  [3:0] r_dataAddr_w, r_dataAddr_r;
reg  [pDATA_WIDTH-1:0] accumulater_w, accumulater_r;
reg  [pDATA_WIDTH-1:0] temp_w, temp_r;

//--------------------------------------------------------------------------------
// Continuous Assignment
//--------------------------------------------------------------------------------
// output
assign awready = 1'b1; // don't touch
assign wready = wready_r;
assign ss_tready = ss_tready_w;
assign arready = 1'b1;
assign rvalid  = rvalid_r;
assign rdata   = rdata_r;
assign sm_tvalid = sm_tvalid_r;
assign sm_tdata  = sm_tdata_r;
assign sm_tlast  = sm_tlast_r;
// TAP BRAM
assign tap_WE = tap_WE_r;
assign tap_EN = tap_EN_r;
assign tap_Di = tap_Di_r;
assign tap_A  = tap_A_r;
// DATA BRAM
assign data_WE = data_WE_r;
assign data_EN = data_EN_r;
assign data_Di = data_Di_r;
assign data_A  = data_A_r;
//
assign tap_write_t = (awvalid && wvalid && w_coef_addr);
assign w_coef_addr = (awaddr[7:4] != 4'd0 && awaddr[7:4] != 4'd1);
assign r_coef_addr = (araddr[7:4] != 4'd0 && araddr[7:4] != 4'd1);
assign readBack_t = (arvalid && r_coef_addr);
assign data_t = (cnt_r[1:0] == 2'd3);
assign ap_start = (awvalid && awaddr == {pADDR_WIDTH{1'b0}} && wvalid && wdata == {{pDATA_WIDTH-1{1'b0}},1'b1});
assign round_done = (cnt_r == round_cnt_r);
assign readAddr0 = (arvalid && araddr == {pADDR_WIDTH{1'b0}});
assign wb_addr0 = (readAddr0 && ~rvalid_r);
assign done = (cnt_r == 4'd1 && wb_addr0);
assign cnt_st = (cnt_r == 4'd0);

//--------------------------------------------------------------------------------
// Combinational Logic
//--------------------------------------------------------------------------------
always @(*) begin
    case(ps)
        IDLE:    ns = (ap_start)   ? PEND  : IDLE;
        START:   ns = (round_done) ? DONE   : START;
        DONE:    ns = (last_r) ? FINISH : PEND;
        PEND:    ns = (ss_tvalid) ? START : PEND;
        FINISH:  ns = (done)  ? IDLE   : FINISH;
        default: ns = IDLE;
    endcase
end

always @(*) begin
    case(ps)
        IDLE:    wready_w = 1'b1;
        default: wready_w = 1'b0;
    endcase
end

always @(*) begin
    case(ps)
        IDLE: begin
            case(1'b1)
                ap_start: begin
                    tap_WE_w = 4'h0;
                    tap_EN_w = 1'b1;
                    tap_Di_w = tap_Di_r;
                    tap_A_w  = {pADDR_WIDTH{1'b0}};
                end
                readBack_t: begin
                    tap_WE_w = 4'h0;
                    tap_EN_w = 1'b1;
                    tap_Di_w = tap_Di_r;
                    tap_A_w  = {(araddr[pADDR_WIDTH-1:5] + {(pADDR_WIDTH-5){1'b1}}), araddr[4:0]}; 
                end
                tap_write_t: begin
                    tap_WE_w = 4'hf;
                    tap_EN_w = 1'b1;
                    tap_Di_w = wdata;
                    tap_A_w  = tap_A_r + 12'd1;
                end
                default: begin
                    tap_WE_w = 4'd0;
                    tap_EN_w = 1'b0;
                    tap_Di_w = tap_Di_r;
                    tap_A_w  = tap_A_r;
                end
            endcase
        end
        START: begin
            tap_WE_w = tap_WE_r;
            tap_EN_w = tap_EN_r;
            tap_Di_w = tap_Di_r;
            if(round_done) begin
                tap_A_w  = {pADDR_WIDTH{1'b0}};
            end else begin
                tap_A_w  = tap_A_r + 12'd1;
            end
        end
        PEND: begin
            tap_WE_w = tap_WE_r;
            tap_EN_w = tap_EN_r;
            tap_Di_w = tap_Di_r;
            tap_A_w  = (ss_tvalid) ? tap_A_r + 12'd1 : tap_A_r; 
        end
        default: begin
            tap_WE_w = tap_WE_r;
            tap_EN_w = tap_EN_r;
            tap_Di_w = tap_Di_r;
            tap_A_w = tap_A_r;
        end
    endcase
end

always @(*) begin
    case(ps)
        START: begin
            // if(round_done) begin // write
            // end else begin
            data_WE_w = 4'd0;
            data_EN_w = 1'b1;
            data_Di_w = data_Di_r;
            if(data_A_r == 12'd0) begin
                data_A_w = 12'd10;
            end else begin
                data_A_w  = data_A_r + 12'hfff;
            end
            // end
        end
        DONE: begin
            data_WE_w = 4'hf;
            data_EN_w = 1'b1;
            data_Di_w = ss_tdata;
            data_A_w = {{pADDR_WIDTH-4{1'b0}}, r_dataAddr_r};
        end
        PEND: begin
            data_WE_w = 4'd0;
            data_EN_w = 1'b1;
            data_Di_w = data_Di_r;
            data_A_w  = r_dataAddr_r;
        end
        default: begin
            data_WE_w = data_WE_r;
            data_EN_w = data_EN_r;
            data_Di_w = data_Di_r;
            data_A_w  = data_A_r;
        end
    endcase
end

always @(*) begin
    case(ps)
        START: begin
            if(round_done) begin
                if(r_dataAddr_r == 4'd10) begin
                    r_dataAddr_w = {pADDR_WIDTH{1'b0}};
                end else begin
                    r_dataAddr_w = r_dataAddr_r + 4'd1;
                end
            end else begin
                r_dataAddr_w = r_dataAddr_r;
            end 
        end
        FINISH:  r_dataAddr_w = 4'hf;
        default: r_dataAddr_w = r_dataAddr_r;
    endcase
end

always @(*) begin
    case(ps)
        IDLE: begin
            if(data_t) begin
                rvalid_w = 1'b1;
                rdata_w  = tap_Do;
            end else begin
                rvalid_w = 1'b0;
                rdata_w  = {pDATA_WIDTH{1'b0}};
            end
        end
        START: begin
            if(wb_addr0) begin
                rvalid_w = 1'b1;
                rdata_w  = {pDATA_WIDTH{1'b0}};
            end else begin
                rvalid_w = 1'b0;
                rdata_w  = {pDATA_WIDTH{1'b0}};
            end
        end
        FINISH: begin
            if(wb_addr0 && cnt_r == 4'd1) begin
                rvalid_w = 1'b1;
                rdata_w  = {{pDATA_WIDTH-3{1'b0}}, 3'd4};
            end else if(wb_addr0) begin
                rvalid_w = 1'b1;
                rdata_w  = {{pDATA_WIDTH-2{1'b0}}, 2'd2};
            end else begin
                rvalid_w = 1'b0;
                rdata_w  = {pDATA_WIDTH{1'b0}};
            end
        end
        default: begin
            rvalid_w = 1'b0;
            rdata_w  = {pDATA_WIDTH{1'b0}};
        end
    endcase
end

always @(*) begin
    case(ps)
        IDLE: begin
            if(data_t || ap_start) begin
                cnt_w = 4'd0;
            end else if(arvalid) begin
                cnt_w = {{2{1'b0}},(cnt_r[1:0] + 2'd1)};
            end else begin
                cnt_w = cnt_r;
            end
        end
        START: begin
            if(cnt_r == round_cnt_r) begin
                cnt_w = 4'd0;
            end else begin
                cnt_w = cnt_r + 4'd1;
            end
        end
        FINISH: begin
            if(readAddr0 && rvalid) begin
                cnt_w = cnt_r + 4'd1;
            end else begin
                cnt_w = cnt_r;
            end
        end
        default: cnt_w = 4'd0;
    endcase
end

always @(*) begin
    case(ps)
        DONE:    round_cnt_w = (round_cnt_r == 4'd10) ? round_cnt_r : round_cnt_r + 4'd1;
        FINISH:  round_cnt_w = 4'd1;
        default: round_cnt_w = round_cnt_r;
    endcase
end

always @(*) begin
    case(ps)
        DONE:    ss_tready_w = 1'b1;
        default: ss_tready_w = 1'b0;
    endcase
end

assign mult_out = mult_in0 * mult_in1;
always @(*) begin
    mult_in0 = $signed(tap_Do);
    if(cnt_st) begin
        mult_in1 = $signed(ss_tdata);
    end else begin
        mult_in1 = $signed(data_Do);
    end
end

always @(*) begin
    temp_w = mult_out[pDATA_WIDTH-1:0];
end

assign adder_out = adder_in0 + adder_in1;
always @(*) begin
    case(ps)
        START: begin
            adder_in0 = $signed(accumulater_r);
            adder_in1 = $signed(temp_r);
        end
        default: begin
            adder_in0 = {pDATA_WIDTH{1'b0}};
            adder_in1 = {pDATA_WIDTH{1'b0}};
        end
    endcase
end

always @(*) begin
    case(ps)
        START: begin
            if(r_dataAddr_r == 4'hf || cnt_st) begin
                accumulater_w = accumulater_r;
            end else begin
                accumulater_w = adder_out;
            end
        end
        DONE:    accumulater_w = {pDATA_WIDTH{1'b0}};
        default: accumulater_w = accumulater_r;
    endcase
end

always @(*) begin
    sm_tlast_w  = (ps == DONE && last_r) ? 1'b1 : 1'b0;
    if(ps == DONE) begin
        sm_tvalid_w = 1'b1;
        sm_tdata_w  = accumulater_r;
    end else begin
        sm_tvalid_w = 1'b0;
        sm_tdata_w  = sm_tdata_r;
    end
end

always @(*) begin
    if(ss_tlast) begin
        last_w = 1'b1;
    end else if(ps == IDLE) begin
        last_w = 1'b0;
    end else begin
        last_w = last_r;
        end
end

//--------------------------------------------------------------------------------
// Sequential Logic
//--------------------------------------------------------------------------------

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        ps <= IDLE;
    end else begin
        ps <= ns;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        wready_r <= 1'b0;
    end else begin
        wready_r <= wready_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        tap_WE_r <= 4'd0;
        tap_EN_r <= 1'b0;
        tap_Di_r <= {pDATA_WIDTH{1'b0}};
        tap_A_r  <= {{pADDR_WIDTH{1'b1}}};
    end else begin
        tap_WE_r <= tap_WE_w;
        tap_EN_r <= tap_EN_w;
        tap_Di_r <= tap_Di_w;
        tap_A_r  <= tap_A_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        data_WE_r <= 4'd0; 
        data_EN_r <= 1'b0; 
        data_Di_r <= {pDATA_WIDTH{1'b0}}; 
        data_A_r  <= {{pADDR_WIDTH{1'b1}}};
    end else begin
        data_WE_r <= data_WE_w; 
        data_EN_r <= data_EN_w; 
        data_Di_r <= data_Di_w; 
        data_A_r  <= data_A_w; 
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        rvalid_r <= 1'b0;
        rdata_r  <= {pDATA_WIDTH{1'b0}};
    end else begin
        rvalid_r <= rvalid_w;
        rdata_r  <= rdata_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        cnt_r <= 4'b0;
        round_cnt_r <= 4'd1;
    end else begin
        cnt_r <= cnt_w;
        round_cnt_r <= round_cnt_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        r_dataAddr_r <= 4'hf;
    end else begin
        r_dataAddr_r <= r_dataAddr_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        temp_r <= {pDATA_WIDTH{1'b0}};
        accumulater_r <= {pDATA_WIDTH{1'b0}};
    end else begin
        temp_r <= temp_w;
        accumulater_r <= accumulater_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        sm_tvalid_r <= 1'b0;
        sm_tlast_r  <= 1'b0;
        sm_tdata_r  <= {pDATA_WIDTH{1'b0}};
    end else begin
        sm_tvalid_r <= sm_tvalid_w;
        sm_tlast_r  <= sm_tlast_w;
        sm_tdata_r  <= sm_tdata_w;
    end
end

always @(posedge axis_clk or posedge axis_rst_n) begin
    if(axis_rst_n) begin
        last_r <= 1'b0;
    end else begin
        last_r <= last_w;
    end
end

endmodule

