// tb.sv
module tb;
    reg clk, reset;
    wire [7:0] mem_out [0:15];
    GPU_Top gpu (.clk(clk), .reset(reset), .mem_out(mem_out));

    task display_result;
        begin
            $display("Result Matrix C:");
            $display("  C[0,0] = %0d", {mem_out[9], mem_out[8]});
            $display("  C[0,1] = %0d", {mem_out[11], mem_out[10]});
            $display("  C[1,0] = %0d", {mem_out[13], mem_out[12]});
            $display("  C[1,1] = %0d", {mem_out[15], mem_out[14]});
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        #25;  // Extended reset period
        
        // Test Case 1: Identity Matrices
        $display("\nTest Case 1: A=[1,1;1,1], B=[1,1;1,1]");
        // Matrix A (2x2)
        gpu.mem.mem[0] = 8'h01;  // A[0][0]
        gpu.mem.mem[1] = 8'h01;  // A[0][1]
        gpu.mem.mem[2] = 8'h01;  // A[1][0]
        gpu.mem.mem[3] = 8'h01;  // A[1][1]
        // Matrix B (2x2)
        gpu.mem.mem[4] = 8'h01;  // B[0][0]
        gpu.mem.mem[5] = 8'h01;  // B[0][1]
        gpu.mem.mem[6] = 8'h01;  // B[1][0]
        gpu.mem.mem[7] = 8'h01;  // B[1][1]
        
        reset = 0;
        #150;  // Wait for computation to complete
        display_result;
        

        // Test Case 3: Zero Matrices
        reset = 1;
        #25;
        $display("\nTest Case 3: A=[0,0;0,0], B=[0,0;0,0]");
        gpu.mem.mem[0] = 8'h00; gpu.mem.mem[1] = 8'h00; 
        gpu.mem.mem[2] = 8'h00; gpu.mem.mem[3] = 8'h00;
        gpu.mem.mem[4] = 8'h00; gpu.mem.mem[5] = 8'h00; 
        gpu.mem.mem[6] = 8'h00; gpu.mem.mem[7] = 8'h00;
        reset = 0;
        #150;
        display_result;



        $finish;
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testcase.vcd");
        $dumpvars(0, tb);
        $monitor("Time = %0t: reset=%b", $time, reset);
    end
endmodule