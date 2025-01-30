parameter width = 32;
`include "../../assert.sv"
`include "../chunked_sub.sv"
module chunked_sub_test();
    reg [width - 1:0] a;
    reg [width - 1:0] b;
    reg [width - 1:0] out;

    chunked_sub chunked_sub_(
            .a(a), .b(b), .out(out)
        );
        
    task test_sub(input [width - 1:0] a_, input [width - 1:0] b_, input [width - 1:0] expected_out);
        a = a_;
        b = b_;

        #1;
        $display("a %0d b %0d out %0d %b", a, b, out, out);
        `assert(out == expected_out);
        #1;
    endtask

    initial begin
        test_sub(1, 1, 0);
        test_sub(3, 1, 2);
        test_sub(7, 3, 4);
        test_sub(4294967295, 5, 4294967290);
        test_sub(4294967295, 0, 4294967295);
        test_sub(1234500000, 67890, 1234432110);
        test_sub(4294967295, 0, 4294967295);
        test_sub(4294967290, 5, 4294967285);
        test_sub(4294967290, 4, 4294967286);
    end
endmodule
