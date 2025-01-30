module mul_pipeline_cycle_32bit_2bpc (
    input [5:0] pos,
    input [31:0] a,
    input [31:0] b,
    input [5:0] cin,
    output reg [1:0] sum,
    output reg [5:0] cout
);

    reg [63:0] partial_product;
    reg [6:0] carry;
    
    always @(*) begin
        partial_product = (a & {32{b[pos[4:0]]}}) + (a & {32{b[pos[4:0]+1]}}) << 1;
        {carry, partial_product[1:0]} = partial_product[1:0] + cin;
        sum = partial_product[1:0];
        cout = carry[5:0];
    end

endmodule