// Module name: divider
// Description:
//     - A 24-bit signed division module.
//     - Takes 4 cycles to complete a division.
//     - Each cycle produces four bits of the quotient.
//     - Pipelined
// Input:
//     - clk: Clock signal
//     - dividend: 24-bit signed integer
//     - divisor: 24-bit signed integer
//     Note that the dividend is smaller than the divisor.
// Output:
//     - quotient: 13-bit signed fixed-point number
//     - 1Q12
module divider(
    input clk,
    input signed [23:0] dividend,
    input signed [23:0] divisor,
    output signed reg [13:0] quotient
);
    reg signbit;
    assign signbit = dividend[23] ^ divisor[23];

    wire [35:0] remainder_out1;
    wire [22:0] divisor_out1;
    wire signbit_out1;

    divider_unit divider_unit1(
        // input
        .clk( clk ),
        .remainder_in( {dividend[22:0],13'b0} ),
        .divisor_in( divisor[22:0] ),
        .signbit_in( signbit ),
        // output
        .remainder_out( remainder_out1 ),
        .divisor_out( divisor_out1 ),
        .signbit_out( signbit_out1 )
    );

    wire [35:0] remainder_out2;
    wire [22:0] divisor_out2;
    wire signbit_out2;

    divider_unit divider_unit2(
        // input
        .clk( clk ),
        .remainder_in( remainder_out1 ),
        .divisor_in( divisor_out1 ),
        .signbit_in( signbit_out1 ),
        // output
        .remainder_out( remainder_out2 ),
        .divisor_out( divisor_out2 ),
        .signbit_out( signbit_out2 )
    );

    wire [35:0] remainder_out3;
    wire [22:0] divisor_out3;
    wire signbit_out3;

    divider_unit divider_unit3(
        // input
        .clk( clk ),
        .remainder_in( remainder_out2 ),
        .divisor_in( divisor_out2 ),
        .signbit_in( signbit_out2 ),
        // output
        .remainder_out( remainder_out3 ),
        .divisor_out( divisor_out3 ),
        .signbit_out( signbit_out3 )
    );


    reg [12:0] quotient_next;
    always@(*) begin
        if (divisor == dividend) begin
            quotient_next = { 2{signbit_out3}, 12'b0 };
        end
        else begin
            if (signbit_out3 == 0) begin
            quotient_next  = {2'b0, remainder_out3[11:0]};
            end
            else begin
                quotient_next = -{2'b0, remainder_out3[11:0]};
            end
        end
    end

    always@(posedge clk) begin
        quotient <= quotient_next;
    end
endmodule