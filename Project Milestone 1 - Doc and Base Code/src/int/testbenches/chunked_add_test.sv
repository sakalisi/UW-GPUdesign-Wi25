parameter width = 32;
`include "../../assert.sv"
`include "../chunked_add.sv"
module chunked_add_test();
    reg [width - 1:0] a;
    reg [width - 1:0] b;
    reg [width - 1:0] out;
    
    chunked_add chunked_add_(
            .a(a), .b(b), .out(out)
        );

    task test_add(input [width - 1:0] a_, input [width - 1:0] b_, input [width - 1:0] expected_out);
        a <= a_;
        b <= b_;
        #1;
        $display("a %0d b %0d out %0d %b", a, b, out, out);
        `assert(out == expected_out);
        #1;
    endtask

    initial begin
        test_add(1, 1, 2);
        test_add(1234500000, 67890, 1234567890);
        test_add(4294967295, 0, 4294967295);
        test_add(4294967290, 5, 4294967295);
        test_add(4294967290, 4, 4294967294);
        test_add(4, 4294967290, 4294967294);
    end
endmodule
