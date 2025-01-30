module mul_pipeline_32bit #(
    parameter width = 32
) (
    input clk,
    input rst,
    input req,
    input [width - 1:0] a,
    input [width - 1:0] b,
    output reg [width - 1:0] out,
    output reg ack
);

    parameter bits_per_cycle = 2;
    reg [width - 1:0] multiplicand;
    reg [width - 1:0] multiplier;
    reg [2*width - 1:0] product;
    reg [$clog2(width):0] bit_count;

    // State machine
    localparam IDLE = 2'b00;
    localparam MULTIPLY = 2'b01;
    localparam FINISH = 2'b10;
    localparam WAIT_FOR_REQ_LOW = 2'b11;
    reg [1:0] state;

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            multiplicand <= 0;
            multiplier <= 0;
            product <= 0;
            bit_count <= 0;
            out <= 0;
            ack <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (req) begin
                        multiplicand <= a;
                        multiplier <= b;
                        product <= 0;
                        bit_count <= 0;
                        ack <= 0;
                        state <= MULTIPLY;
                    end
                end

                MULTIPLY: begin
		// BLOCK B : Add the code for the "MULTIPLY" state
		// We envision a 2 bit multiplier, but students are free to try larger per cycle multipliers too, if they would like to
		// START BLOCK
                    case (multiplier[1:0])
                        2'b00: product <= product; // No addition needed
                        2'b01: product <= product + (multiplicand << bit_count); // Add multiplicand shifted by bit_count
                        2'b10: product <= product + ((multiplicand << bit_count) << 1); // Multiply by 2 (shift left by 1)
                        2'b11: product <= product + ((multiplicand << bit_count) + ((multiplicand << bit_count) << 1)); // Multiply by 3
                    endcase
                    
                    // Store the updated product
//                    product <= new_product;
                    // Shift the multiplier right by 2 bits to process the next pair
                    multiplier <= multiplier >> bits_per_cycle;

                    // Increment the bit count
                    bit_count <= bit_count + bits_per_cycle;

                    // Check if multiplication is complete (all bits processed)
                    if (bit_count >= width-1) begin
                        state <= FINISH;
                    end	
                // END BLOCK     
                end

                FINISH: begin
                    out <= product[width-1:0];
                    ack <= 1;
                    state <= WAIT_FOR_REQ_LOW;
                end

                WAIT_FOR_REQ_LOW: begin
                    if (~req) begin
                        ack <= 0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule