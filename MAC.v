module MAC (
    input signed [7:0] A,
    input signed [7:0] B,
    input macc_clear,
    input clk,
    output reg signed [18:0] out
);

    reg signed [18:0] product;
    reg signed [18:0] accumulator;
    reg signed [18:0] next_accumulator;

    always @(A or B) begin
        //product of the inputs
        product = A * B;

        // Mux logic 
        if (macc_clear == 1) begin
            next_accumulator = product; // Clear the accumulator
        end else begin
            next_accumulator = accumulator + product; // Accumulate
        end
    end

    always @(posedge clk) begin
        // Update the accumulator with the next value
        accumulator <= next_accumulator;
    end

    // Update the output with the value of the accumulator
    always @(posedge clk) begin
        out <= accumulator;
    end

endmodule
