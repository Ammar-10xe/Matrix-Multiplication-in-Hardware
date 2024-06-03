module RAM_B (
    input clk,
    input [5:0] address,
    output reg signed [7:0] data
);
    reg signed [7:0] mem [0:63];

    initial begin
        $readmemb("ram_b_init.txt", mem);
    end

    always @(posedge clk) begin
        data <= mem[address];
    end
endmodule
