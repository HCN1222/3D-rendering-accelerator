module divider_unit(
    input clk,
    input [35:0] remainder_in,
    input [22:0] divisor_in,
    input signbit_in,
    output reg [35:0] remainder_out,
    output reg [22:0] divisor_out,
    output reg signbit_out
);

    reg [35:0] remainder [0:3];
    reg [35:0] remainder_tmp1 [0:4];
    reg [35:0] remainder_tmp2 [0:4];

    integer i;
    always@(*) begin
        // remainder = {dividend,13'b0}
        remainder[0] = remainder_in;
        for(i=1; i<5; i=i+1) begin
            if( remainder[i-1][35:12] > {1'b0, divisor_in} ) begin
                remainder_tmp1[i] = { remainder[i-1][35:12] - {1'b0, divisor_in}, remainder[i-1][11:0] } << 1;
                remainder_tmp2[i] = { remainder_tmp1[i][35:1], 1'b1 };
            end
            else begin
                remainder_tmp1[i] = remainder[i-1] << 1;
                remainder_tmp2[i] = { remainder_tmp1[i][35:1], 1'b0 };
            end
        end
    end

    always@(posedge clk) begin
        remainder_out <= remainder_tmp2[4];
        divisor_out <= divisor_in;
        signbit_out <= signbit_in;
    end
endmodule