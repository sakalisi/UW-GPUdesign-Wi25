`include "../../lib/float_test_funcs.sv"
`include "../assert.sv"

module float_mul_pipeline_test();
    parameter float_width = 32;

    reg                     clk;
    reg                     rst;
    reg                     req;
    wire                    ack;
    reg [float_width - 1:0] a;
    reg [float_width - 1:0] b;
    wire [float_width - 1:0] out;

    float_mul_pipeline #(
        .float_width(float_width)
    ) float_mul_pipeline_(
        .clk(clk),
        .rst(rst),
        .req(req),
        .ack(ack),
        .a(a),
        .b(b),
        .out(out)
    );

    task tick();
        #5 clk = 0;
        #5 clk = 1;
    endtask

    task test_mul_zero(input real _a, input real _b, input real expected_out);
        int cnt;
        `assert(~ack);
        $display("submitting zero req %f * %f", _a, _b);
        a <= make_float(_a);
        b <= make_float(_b);
        req <= 1;

        tick();

        cnt = 0;
        do begin
            tick();
            cnt = cnt + 1;
            if (cnt == 5)
                req <= 0;
        end while(~ack && cnt < 35); // Wait for up to 5 clock cycles

        `assert(ack);
        $display("Should Be zero test_mul a=%0f b=%0f out=%0f", _a, _b, to_real(out));
        `assert(reals_near(to_real(out), expected_out));

        repeat(2) tick();
        `assert(~ack);
    endtask

    task test_mul(input real _a, input real _b, input real expected_out);
        int cnt;

        `assert(~ack);
        $display("submitting req %f * %f", _a, _b);
        a <= make_float(_a);
        b <= make_float(_b);
        req <= 1;

        tick();

        cnt = 0;
        do begin
            tick();
            cnt = cnt + 1;
            if (cnt == 5)
                req <= 0;
        end while(~ack && cnt < 35); // Wait for up to 5 clock cycles

        `assert(ack);
        $display("cnt=%0d ack=%b", cnt, ack);
        $display("Should be Equal test_mul a=%0f b=%0f out=%0f", _a, _b, to_real(out));
        `assert(reals_near(to_real(out), expected_out));
        repeat(2) tick();
        `assert(~ack);
    endtask

    real a_real, b_real, out_real;
    assign a_real = to_real(a);
    assign b_real = to_real(b);
    assign out_real = to_real(out);

    initial begin
        $monitor(
            "t=%0d test.mon a=%0f b=%0f out=%0f",
            $time, a_real, b_real, out_real);
        rst = 1;
        req = 0;
        clk = 0;

        repeat(2) tick();
        rst = 0;
        repeat(2) tick();
        rst = 1;

        test_mul_zero(0.0, 1.0, 0.0);
        test_mul_zero(1.0, 0.0, 0.0);
        test_mul_zero(0.0, 0.0, 0.0);

        test_mul(1.0, 1.0, 1.0);
        test_mul(1.1, 1.1, 1.21);
        test_mul(11.0, 11.0, 121.0);
        test_mul(1.9, 1.9, 3.61);

        test_mul(1.0, 2.0, 2.0);
        test_mul(2.0, 1.0, 2.0);
        test_mul(2.0, 2.0, 4.0);
        test_mul(2.0, 2.3, 4.6);
        test_mul(8.0, 4.0, 32.0);
        test_mul(10.0, 4.0, 40.0);
        test_mul(10.1, 4.0, 40.4);
        test_mul(101.0, 4.0, 404.0);
        test_mul(100.0, 4.5, 450.0);
        test_mul(20.0, 2.3, 46.0);
        test_mul(200.0, 2.3, 460.0);
        test_mul(200.0, 100.0, 20000.0);
        test_mul(2000.0, 2.3, 4600.0);

        test_mul(-2000.0, 2.3, -4600.0);
        test_mul(2000.0, -2.3, -4600.0);
        test_mul(-2000.0, -2.3, 4600.0);

        $finish;
    end
endmodule
