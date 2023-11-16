module lutram#(
    parameter N = 14,
    parameter DEPTH = 16384
)(
    CLK,
    WE0,
    EN0,
    Di0,
    Do0,
    A0
);

    input   wire            CLK;
    input   wire    [3:0]   WE0;
    input   wire            EN0;
    input   wire    [31:0]  Di0;
    output  reg     [31:0]  Do0;
    input   wire    [N-1:0]   A0;

    // 16 kB
//    (* ram_style = "reg" *) reg [31:0] RAM[0:DEPTH-1];
//    (* ram_style = "block" *) reg [31:0] RAM[0:DEPTH-1];
//    (* ram_style = "distributed" *) reg [31:0] RAM[0:DEPTH-1];
    reg [31:0] RAM[0:DEPTH-1];

    always @(posedge CLK)
        if(EN0) begin
            Do0 <= RAM[A0[N-1:0]];
            if(WE0[0]) RAM[A0[N-1:0]][7:0] <= Di0[7:0];
            if(WE0[1]) RAM[A0[N-1:0]][15:8] <= Di0[15:8];
            if(WE0[2]) RAM[A0[N-1:0]][23:16] <= Di0[23:16];
            if(WE0[3]) RAM[A0[N-1:0]][31:24] <= Di0[31:24];
        end
        else begin
            Do0 <= 32'b0;
        end 
        

        
endmodule
