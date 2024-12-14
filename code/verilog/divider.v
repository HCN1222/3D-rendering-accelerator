module divider #(
    parameter len_q = 24  // Define the width of the quotient
)(
    input  [23:0] dividend,
    input  [23:0] divisor,
    output reg [len_q-1:0] quotient,
    output reg [23:0] remainder
);
    integer i; // Loop index

    always @(*) begin
        // Initialize remainder and quotient
        remainder = dividend;
        quotient = 0;

        // Perform division logic
        for (i = len_q-1; i >= 0; i = i - 1) begin
            if (remainder >= divisor) begin
                remainder = (remainder - divisor) << 1;
                quotient = (quotient << 1) | 1; // Add 1 to quotient LSB
            end else begin
                remainder = remainder << 1;
                quotient = quotient << 1; // Add 0 to quotient LSB
            end
        end

        // Adjust remainder (last shift correction)
        remainder = remainder >> 1; 
    end
endmodule
