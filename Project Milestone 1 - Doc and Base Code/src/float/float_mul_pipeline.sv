`default_nettype wire
`include "../assert.sv"
`include "float_params.sv"

module float_mul_pipeline #(
    parameter float_width = 32
) (
    input wire clk,
    input wire rst,
    input wire req,
    output reg ack,
    input wire [float_width-1:0] a,
    input wire [float_width-1:0] b,
    output reg [float_width-1:0] out
);

    // Constants for IEEE 754 single-precision
    localparam EXPONENT_WIDTH = 8;
    localparam MANTISSA_WIDTH = 23;
    localparam BIAS = 127;

    // State machine
    reg [2:0] state;
    localparam IDLE = 3'b000, UNPACK = 3'b001, MULTIPLY = 3'b010, NORMALIZE = 3'b011, SET_EXP = 3'b100, PACK = 3'b101;

    // Registers and wires
    reg sign;
    reg [EXPONENT_WIDTH-1:0] exponent_a, exponent_b;
    reg [MANTISSA_WIDTH:0] mantissa_a, mantissa_b;
    reg [EXPONENT_WIDTH:0] exponent_sum;
    wire [47:0] mantissa_product;
    reg [MANTISSA_WIDTH-1:0] normalized_mantissa;
    reg [EXPONENT_WIDTH-1:0] final_exponent;

    // Mantissa multiplier signals
    reg start_mul;
    reg set_ack;
    wire mul_ack;

    // Instantiate the mantissa multiplier
    mul_pipeline_cycle_24bit_2bpc mantissa_mul (
        .clk(clk),
        .rst(rst),
        .start(start_mul),
        .set_ack(set_ack),
        .a(mantissa_a),
        .b(mantissa_b),
        .product(mantissa_product),
        .ack(mul_ack)
    );

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            state <= IDLE;
            ack <= 1'b0;
            out <= {float_width{1'b0}};
            start_mul <= 1'b0;
            set_ack <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    ack <= 1'b0;
                    if (req) begin
                        state <= UNPACK;                      
                        set_ack <= 1'b1;
                    end
                end

                UNPACK: begin
                    // BLOCK D : The UNPACK stage : Set up the multiplier for the "MULTPLY" stage
		    // START BLOCK
		    // END BLOCK
                end

                MULTIPLY: begin
                    start_mul <= 1'b0;
                    if (mul_ack) begin
                        exponent_sum <= $signed({1'b0, exponent_a}) + $signed({1'b0, exponent_b}) - BIAS;
                        state <= NORMALIZE;
                    end
                end

                NORMALIZE: begin
                    // BLOCK E : Get the normalised mantissa from the mantissa product outputted from the mantissa multiplier
		    // START BLOCK
		    // END BLOCK
                end
                
                SET_EXP: begin
                    if ($signed(exponent_sum) < 0) begin
                        final_exponent <= {EXPONENT_WIDTH{1'b0}};
                    end else if (exponent_sum[EXPONENT_WIDTH]) begin
                        final_exponent <= {EXPONENT_WIDTH{1'b1}};
                    end else begin
                        final_exponent <= exponent_sum[EXPONENT_WIDTH-1:0];
                    end
                    state <= PACK;
                end
                
                PACK: begin
                    out <= {sign, final_exponent[EXPONENT_WIDTH-1:0], normalized_mantissa[MANTISSA_WIDTH-1:0]};
                    ack <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
