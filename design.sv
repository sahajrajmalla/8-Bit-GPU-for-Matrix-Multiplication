// GPU_Top.sv
module GPU_Top (
    input clk,
    input reset,
    output [7:0] mem_out [0:15]
);

    // Memory module
    wire [15:0] we;
    wire [7:0] wdata [0:15];
    Memory mem (
        .clk(clk),
        .reset(reset),
        .we(we),
        .wdata(wdata),
        .mem_out(mem_out)
    );

    // Controller module
    wire store_result;
    Controller ctrl (
        .clk(clk),
        .reset(reset),
        .store_result(store_result)
    );

    // Processing Units with fixed (i,j) assignments
    wire [15:0] pu00_result, pu01_result, pu10_result, pu11_result;
    
    PU pu00 (.clk(clk), .reset(reset), .i(2'd0), .j(2'd0), .mem_out(mem_out), .result(pu00_result));
    PU pu01 (.clk(clk), .reset(reset), .i(2'd0), .j(2'd1), .mem_out(mem_out), .result(pu01_result));
    PU pu10 (.clk(clk), .reset(reset), .i(2'd1), .j(2'd0), .mem_out(mem_out), .result(pu10_result));
    PU pu11 (.clk(clk), .reset(reset), .i(2'd1), .j(2'd1), .mem_out(mem_out), .result(pu11_result));

    // Connect PU results to memory write data
    assign wdata[8] = pu00_result[7:0];
    assign wdata[9] = pu00_result[15:8];
    assign wdata[10] = pu01_result[7:0];
    assign wdata[11] = pu01_result[15:8];
    assign wdata[12] = pu10_result[7:0];
    assign wdata[13] = pu10_result[15:8];
    assign wdata[14] = pu11_result[7:0];
    assign wdata[15] = pu11_result[15:8];
    
    // Generate write enables for result locations (8-15)
    assign we = store_result ? 16'hFF00 : 16'h0000;

endmodule

module Memory (
    input clk,
    input reset,
    input [15:0] we,    // Write enable for each address
    input [7:0] wdata [0:15], // Write data for each address
    output reg [7:0] mem_out [0:15]
);

    reg [7:0] mem [0:15];
    
    always @(posedge clk) begin
        if (reset) begin
            // Initialize memory to 0
            for (int i = 0; i < 16; i++) begin
                mem[i] <= 8'h00;
            end
        end
        else begin
            // Write to memory locations based on we
            for (int i = 0; i < 16; i++) begin
                if (we[i]) begin
                    mem[i] <= wdata[i];
                end
            end
        end
        
        // Continuous read
        for (int i = 0; i < 16; i++) begin
            mem_out[i] <= mem[i];
        end
    end

endmodule

module Controller (
    input clk,
    input reset,
    output reg store_result
);

    reg [3:0] state;
    reg [3:0] counter;
    
    // State definitions
    localparam IDLE     = 4'd0;
    localparam COMPUTE  = 4'd1;
    localparam STORE    = 4'd2;
    localparam DONE     = 4'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            counter <= 0;
            store_result <= 0;
        end
        else begin
            store_result <= 0;  // Default value
            
            case (state)
                IDLE: begin
                    state <= COMPUTE;
                    counter <= 0;
                end
                
                COMPUTE: begin
                    if (counter < 5) begin  // Wait 5 cycles for computation
                        counter <= counter + 1;
                    end
                    else begin
                        state <= STORE;
                        counter <= 0;
                    end
                end
                
                STORE: begin
                    store_result <= 1;  // Pulse store_result for 1 cycle
                    state <= DONE;
                end
                
                DONE: begin
                    // Stay in done state
                end
            endcase
        end
    end

endmodule

module PU (
    input clk,
    input reset,
    input [1:0] i,
    input [1:0] j,
    input [7:0] mem_out [0:15],
    output reg [15:0] result
);

    // Matrix multiplication logic
    reg [15:0] accumulator;
    reg [1:0] state;
    reg [1:0] k;
    
    // State definitions
    localparam START   = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam STORE   = 2'd2;
    localparam FINISH  = 2'd3;
    
    // Memory address calculation functions
    function automatic [3:0] a_addr(input [1:0] i, k);
        return {i, k};  // A[i][k] = mem[{i,k}]
    endfunction
    
    function automatic [3:0] b_addr(input [1:0] k, j);
        return {2'b10, k, j};  // B[k][j] = mem[4 + {k,j}]
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            accumulator <= 0;
            state <= START;
            k <= 0;
            result <= 0;
        end
        else begin
            case (state)
                START: begin
                    accumulator <= 0;
                    k <= 0;
                    state <= COMPUTE;
                end
                
                COMPUTE: begin
                    // C[i][j] += A[i][k] * B[k][j]
                    accumulator <= accumulator + 
                                  (mem_out[a_addr(i, k)] * mem_out[b_addr(k, j)]);
                    k <= k + 1;
                    
                    if (k == 1) begin
                        state <= STORE;
                    end
                end
                
                STORE: begin
                    result <= accumulator;
                    state <= FINISH;
                end
                
                FINISH: begin
                    // Hold the result
                end
            endcase
        end
    end

endmodule