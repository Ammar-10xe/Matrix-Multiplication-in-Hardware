module RAM_A (
    input clk,
    input [5:0] address,
    output reg signed [7:0] data
);
    reg signed [7:0] mem [0:63];

    initial begin
        $readmemb("ram_a_init.txt", mem);
    end

    always @(posedge clk) begin
        data <= mem[address];
    end
endmodule
