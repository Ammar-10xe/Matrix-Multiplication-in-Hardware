module RamOut (
    input clk,
    input [5:0] address,
    input signed [18:0] data,
    input write_enable
);

    reg signed [18:0] mem [0:63]; // 64x19 RAM in column major order

    always @(posedge clk) begin
        if (write_enable) begin
            mem[address] <= data; // Write data into RAM at specified address
        end
    end

endmodule
