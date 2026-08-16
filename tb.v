`timescale 1ns / 1ps

module booth_multiplier_tb;

    parameter N = 4;

    reg clk;
    reg rst;
    reg start;
    reg signed [N-1:0] multiplicand;
    reg signed [N-1:0] multiplier;

    wire signed [2*N-1:0] product;
    wire done;

    // Instantiate DUT
    booth_multiplier #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Task for multiplication
    task test_multiply;
        input signed [N-1:0] a;
        input signed [N-1:0] b;
        begin
            @(posedge clk);

            multiplicand = a;
            multiplier   = b;
            start        = 1;

            @(posedge clk);
            start = 0;

            // Wait until multiplication is complete
            wait(done == 1);

            #1;

            $display(
                "Time=%0t | %0d x %0d = %0d",
                $time, a, b, product
            );

            @(posedge clk);
        end
    endtask

    initial begin

        // Initialize
        clk = 0;
        rst = 1;
        start = 0;
        multiplicand = 0;
        multiplier = 0;

        // Reset
        #20;
        rst = 0;

        // Test cases
        test_multiply(3, 2);
        test_multiply(5, 3);
        test_multiply(-3, 5);
        test_multiply(-4, 3);
        test_multiply(-4, -3);
        test_multiply(7, 2);

        #20;

        $display("All tests completed.");
        $finish;
    end

endmodule
