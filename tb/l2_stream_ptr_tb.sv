module l2_stream_ptr_tb;

    parameter l2_ncl                    = 256;
    parameter l2_ncl_width              = $clog2(l2_ncl);

    // SETUP
    reg clk;
    reg reset;

    always
    begin
        clk <= 1'b1;
        #(2.0);
        clk <= 1'b0;
        #(2.0);
    end

    initial
    begin
        clk = 0;
        #1300;
        $finish;
    end

    initial begin
        reset = 1;
        #100;
        reset = 0;
    end

    initial begin
        // dump waveform files
        // dumpvars = dumps ALL the variables of that module and all the variables in ALL lower level modules instantiated by this top module
        `ifdef VCD
            $dumpfile("l2_stream_ptr_tb.vcd");
            $dumpvars(0, l2_stream_ptr_tb);
        `endif
    end

    // SIGNAL DECLARATIONS
    // FUNCTIONAL STREAM RESET INTERFACE
    reg 						i_rst_v;
    wire 						i_rst_r;

    // L1 REQUEST INTERFACE
    reg 						i_rd_v;
    wire 						i_rd_r;

    // L2 URAM READ INTERFACE
    wire 						o_addr_v;
    reg 						o_addr_r;
    wire [l2_ncl_width-1:0] 	o_addr_ptr;

    // OPENCAPI 3.0 REQUEST INTERFACE
    wire 						o_req_v;
    reg 						o_req_r;

    // OPENCAPI 3.0 RESPONSE INTERFACE
    reg 						i_rsp_v;
    wire 						i_rsp_r;

    // after reg
    wire 						s0_rst_v;
    wire 						s0_rd_v;
    wire 						s0_addr_r;
    wire 						s0_req_r;
    wire 						s0_rsp_v;

    // REGISTER INPUTS
    base_delay # (
        .width(5),
        .n(1)
    ) is0_input_delay (
        .clk (clk),
        .reset (reset),
        .i_d ({ i_rst_v,  i_rd_v,  o_addr_r,  o_req_r,  i_rsp_v}),
        .o_d ({s0_rst_v, s0_rd_v, s0_addr_r, s0_req_r, s0_rsp_v})
    );

    // Loop back req and rsp for OpenCAPI 3.0.
    wire                        s1_req_v;
    wire                        s1_req_r;

    wire                        s2_rsp_v;
    wire                        s2_rsp_r;

    // Loop request to response interface.
    base_areg # ( .lbl(3'b110),.width(1)) is0_req_reg (
        .clk(clk),.reset(reset),
        .i_v(s1_req_v),.i_r(s1_req_r),.i_d(),
        .o_v(s2_rsp_v),.o_r(s2_rsp_r),.o_d()
    );

    // DUT
    l2_stream_ptr IDUT (
        .clk        (clk),
        .reset      (reset),

        .i_rst_v    (s0_rst_v),
        .i_rst_r    (i_rst_r),

        .i_rd_v     (s0_rd_v),
        .i_rd_r     (i_rd_r),

        .o_addr_v   (o_addr_v),
        .o_addr_r   (s0_addr_r),
        .o_addr_ptr (o_addr_ptr),

        .o_req_v    (s1_req_v),
        .o_req_r    (s1_req_r),

        .i_rsp_v    (s2_rsp_v),
        .i_rsp_r    (s2_rsp_r)
    );

    // DRIVE INPUTS - best practise to change them on a negative edge.
    initial begin
        i_rst_v         <= 0;
        i_rd_v          <= 0;
        o_addr_r        <= 1;
        o_req_r         <= 1;
        i_rsp_v         <= 0;
        #102;

        i_rst_v         <= 1;
        #4;

        i_rst_v         <= 0;
        #100;

        i_rd_v          <= 1;
        #8;

        // Terminate testbench.
        i_rd_v          <= 0;
    end

endmodule // l2_stream_ptr_tb
