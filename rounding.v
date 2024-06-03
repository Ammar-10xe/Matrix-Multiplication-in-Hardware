module rounding (
    input [5:0] address_C,
    output reg [5:0] rounded_result
);
    reg [5:0] temp;
    reg add_bit;

    always @(*) begin
        // Step 1: Right shift to divide by 8
        temp = address_C >> 3; // This is the integer part of the division

        // Determine if we need to round up
        add_bit = address_C[2]; // Check if the bit for 0.5 is 1

        // Step 2: Perform rounding
        if (add_bit && (|address_C[1:0] || address_C[2])) begin
            rounded_result = temp + 1;
        end else begin
            rounded_result = temp;
        end
    end
endmodule
