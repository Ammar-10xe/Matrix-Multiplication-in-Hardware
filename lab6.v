module lab6 (
    input clk,
    input start,
    input reset,
    output reg done,
    output reg [10:0] clock_count,
    output wire [7:0] A_out, B_out,
    output wire [18:0] mac_output_test,
    output wire [5:0] address_A_test,
    output wire [5:0] address_B_test,
    output wire [5:0] address_C_test,
    output wire [18:0] calculated_test,
    output wire [5:0] x_test,
    output wire mac_high_test,
	 output wire [5:0] k_int,
	 output wire [5:0] rounded_result
	 
);

    // Define signals
    reg [2:0] i, j, k, x;
    reg signed [7:0] A, B;
    wire signed [18:0] mac_out;
    wire signed [7:0] data_outA, data_outB;
    reg [5:0] address_A;
    reg [5:0] address_B, address_C;
    reg write_enable;
    reg macc_clear;
    //wire [5:0] rounded_result; // Output from the rounding module
    reg signed [18:0] calculated;

    // State parameters
    parameter IDLE = 3'b000, LOAD = 3'b001, COMPUTE = 3'b010, STORE = 3'b011, DONE = 3'b100;

    // State variables
    reg [2:0] state, next_state;

    // Instantiate MAC module
    MAC mac (
        .A(data_outA),
        .B(data_outB),
        .macc_clear(macc_clear),
        .clk(clk),
        .out(mac_out)
    );

    // Instantiate RAM modules
    RAM_A ramA (
        .clk(clk),
        .address(address_B),
        .data(data_outA)
    );

    RAM_B ramB (
        .clk(clk),
        .address(address_A),
        .data(data_outB)
    );

    // Instantiate RAM for output
    RamOut RAMOUTPUT (
        .clk(clk),
        .address(address_C),
        .data(calculated), 
        .write_enable(write_enable)
    );

    // Instantiate rounding module
    rounding round_inst (
        .address_C(address_C),
        .rounded_result(rounded_result)
    );

    assign A_out = data_outA;
    assign B_out = data_outB;
    assign address_A_test = address_A;
    assign address_B_test = address_B;
    assign address_C_test = address_C;
    assign mac_output_test = mac_out;
    assign calculated_test = calculated;
    assign x_test = x;
    assign mac_high_test = macc_clear;
	 assign k_int = k;

    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) next_state = COMPUTE;
                else next_state = IDLE;
            end
            //LOAD: begin
            //    next_state = COMPUTE;
            //end
            COMPUTE: begin
                if (k < 8) next_state = COMPUTE;
                if (k == 7) next_state = STORE;
            end
            STORE: begin
                if (address_C < 63) begin
                    next_state = COMPUTE;
                end else begin
                    next_state = DONE;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // State and data handling
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all signals
            state <= IDLE;
            i <= 0; j <= 0; k <= 0; x <= 1;
            address_A <= 0;
            address_B <= 0;
            address_C <= 0;
            macc_clear <= 1;
            write_enable <= 0;
            done <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    i <= 0; j <= 0; k <= 0; x <= 1;
                    address_A <= 0;
                    address_B <= 0;
                    address_C <= 0;
                    macc_clear <= 1;
                    write_enable <= 0;
                end
                //LOAD: begin
                //    A <= data_outA;
                 //   B <= data_outB;
                    
                //end
                COMPUTE: begin
                    if (k == 0) begin
                        macc_clear <= 1; // Clear only if k is 0
                    end else begin
                        macc_clear <= 0; // Continue accumulating
                    end
                    if (k < 8) begin
                        address_A <= address_A + 8;
                        address_B <= address_B + 1;
                        k <= k + 1;
                    end if (k == 7) begin
                        // Keep macc_clear low for the last computation
                        macc_clear <= 0;
                        address_C <= address_C + 1; // Increment address_C here
                        k <= k + 1;
                    end
                end
                STORE: begin
                    write_enable <= 1;
                    calculated <= mac_out; 
                    if (address_C < 63) begin
                        address_B <= rounded_result * 8;
                        address_A <= address_C % 8;
                    end
                    k <= 0; // Reset k for the next computation
                    macc_clear <= 1; // Clear the MAC accumulator
                    write_enable <= 0;
                end

                DONE: begin
                    done <= 1;
                    write_enable <= 0;
                end
            endcase
        end
    end
endmodule

/*
// Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) next_state = COMPUTE;
                else next_state = IDLE;
            end
            //LOAD: begin
            //    next_state = COMPUTE;
            //end
            COMPUTE: begin
                if (k < 8) next_state = COMPUTE;
                else next_state = STORE;
            end
            STORE: begin
                if (address_C < 63) begin
                    next_state = LOAD;
                end else begin
                    next_state = DONE;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // State and data handling
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all signals
            state <= IDLE;
            i <= 0; j <= 0; k <= 0; x <= 1;
            address_A <= 0;
            address_B <= 0;
            address_C <= 0;
            macc_clear <= 1;
            write_enable <= 0;
            done <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    i <= 0; j <= 0; k <= 0; x <= 1;
                    address_A <= 0;
                    address_B <= 0;
                    address_C <= 0;
                    macc_clear <= 1;
                    write_enable <= 0;
                end
                //LOAD: begin
                //    A <= data_outA;
                 //   B <= data_outB;
                    
                //end
                COMPUTE: begin
                    if (k == 0) begin
                        macc_clear <= 1; // Clear only if k is 0
                    end else begin
                        macc_clear <= 0; // Continue accumulating
                    end
                    if (k < 8) begin
                        address_A <= address_A + 1;
                        address_B <= address_B + 8;
                        k <= k + 1;
                    end else begin
                        // Keep macc_clear low for the last computation
                        macc_clear <= 0;
                        address_C <= address_C + 1; // Increment address_C here
                        k <= k + 1;
                    end
                end
                STORE: begin
                    write_enable <= 1;
                    calculated <= mac_out; 
                    if (address_C < 63) begin
                        address_A <= rounded_result * 8;
                        address_B <= address_C % 8;
                    end
                    k <= 0; // Reset k for the next computation
                    macc_clear <= 1; // Clear the MAC accumulator
                    write_enable <= 0;
                end

                DONE: begin
                    done <= 1;
                    write_enable <= 0;
                end
            endcase
        end
    end
endmodule
*/