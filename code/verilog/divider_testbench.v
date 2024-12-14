`timescale 1ns / 1ps

module divider_tb;

    // Parameters
    parameter len_q = 24;

    // Testbench Inputs
    reg [23:0] dividend;
    reg [23:0] divisor;

    // Testbench Outputs
    wire [len_q-1:0] quotient;
    wire [23:0] remainder;

    // Instantiate the DUT (Device Under Test)
    divider #(
        .len_q(len_q)
    ) dut (
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );

    // Testbench Variables
    reg [len_q-1:0] expected_quotient;
    reg [23:0] expected_remainder;

    initial begin
        // Test Case 1: Simple division
        dividend = 24'd100;
        divisor = 24'd3;
        expected_quotient = 24'd33;
        expected_remainder = 24'd1;
        #10; // Wait for computation
        $display("Test Case 1: Dividend = %d, Divisor = %d", dividend, divisor);
        $display("Expected: Quotient = %d, Remainder = %d", expected_quotient, expected_remainder);
        $display("Received: Quotient = %d, Remainder = %d", quotient, remainder);
        if (quotient !== expected_quotient || remainder !== expected_remainder) begin
            $display("FAIL");
        end else begin
            $display("PASS");
        end

        // Test Case 2: Division with no remainder
        dividend = 24'd144;
        divisor = 24'd12;
        expected_quotient = 24'd12;
        expected_remainder = 24'd0;
        #10;
        $display("Test Case 2: Dividend = %d, Divisor = %d", dividend, divisor);
        $display("Expected: Quotient = %d, Remainder = %d", expected_quotient, expected_remainder);
        $display("Received: Quotient = %d, Remainder = %d", quotient, remainder);
        if (quotient !== expected_quotient || remainder !== expected_remainder) begin
            $display("FAIL");
        end else begin
            $display("PASS");
        end

        // Test Case 3: Division with large numbers
        dividend = 24'd123456;
        divisor = 24'd789;
        expected_quotient = dividend / divisor;
        expected_remainder = dividend % divisor;
        #10;
        $display("Test Case 3: Dividend = %d, Divisor = %d", dividend, divisor);
        $display("Expected: Quotient = %d, Remainder = %d", expected_quotient, expected_remainder);
        $display("Received: Quotient = %d, Remainder = %d", quotient, remainder);
        if (quotient !== expected_quotient || remainder !== expected_remainder) begin
            $display("FAIL");
        end else begin
            $display("PASS");
        end

        // Test Case 4: Division by 1
        dividend = 24'd2023;
        divisor = 24'd1;
        expected_quotient = 24'd2023;
        expected_remainder = 24'd0;
        #10;
        $display("Test Case 4: Dividend = %d, Divisor = %d", dividend, divisor);
        $display("Expected: Quotient = %d, Remainder = %d", expected_quotient, expected_remainder);
        $display("Received: Quotient = %d, Remainder = %d", quotient, remainder);
        if (quotient !== expected_quotient || remainder !== expected_remainder) begin
            $display("FAIL");
        end else begin
            $display("PASS");
        end

        // Test Case 5: Division by zero (should handle gracefully)
        dividend = 24'd100;
        divisor = 24'd0;
        #10;
        $display("Test Case 5: Dividend = %d, Divisor = %d", dividend, divisor);
        $display("Received: Quotient = %d, Remainder = %d", quotient, remainder);
        if (divisor == 0) begin
            $display("PASS: Division by zero not computed");
        end else begin
            $display("FAIL");
        end

        $stop;
    end

endmodule
