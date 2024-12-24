// module name: neg_dot_product
//  - Takes two cycles to complete
//  - The module is pipelined
// input:
//  - unit_x, unit_y, unit_z: 2Q24
//  - x2, y2, z2: 4Q20
// output:
//  - out: 7Q17
// ******************************

module neg_dot_product(
    input clk,
    input srst_n,
    // 2Q24
    input signed [25:0] unit_x,
    input signed [25:0] unit_y,
    input signed [25:0] unit_z,
    // input: 4Q20
    input signed [23:0] x2,
    input signed [23:0] y2,
    input signed [23:0] z2,
    // output: 7Q17
    output reg signed [23:0] out
);    
    // product_x = unit_x *  x
    //   5Q44    2Q24    4Q20
    reg signed [48:0] product_x, product_y, product_z;
    reg signed [48:0] product_x_round_next, product_y_round_next, product_z_round_next;
    // quantization: 5Q44 -> 5Q24
    reg signed [28:0] product_x_quant_next, product_y_quant_next, product_z_quant_next;
    reg signed [28:0] product_x_quant, product_y_quant, product_z_quant;

    // 7Q24
    reg signed [30:0] sum;
    reg signed [30:0] neg_sum;
    reg signed [30:0] neg_sum_round;
    // output: 7Q17
    reg signed [23:0] out_wire;

    always @(*) begin
        product_x = unit_x * x2;
        product_y = unit_y * y2;
        product_z = unit_z * z2;
        // 5Q44 -> 5Q24
        product_x_round_next = ( product_x + {5'sb0, 24'sb0, 1'sb1, 19'sb0} );
        product_y_round_next = ( product_y + {5'sb0, 24'sb0, 1'sb1, 19'sb0} );
        product_z_round_next = ( product_z + {5'sb0, 24'sb0, 1'sb1, 19'sb0} );
        product_x_quant_next = product_x_round_next[48:20];
        product_y_quant_next = product_y_round_next[48:20];
        product_z_quant_next = product_z_round_next[48:20];
        // 5Q24 -> 7Q24 -> 7Q17
        sum = product_x_quant + product_y_quant + product_z_quant;
        neg_sum = (~sum + 1'sb1);
        neg_sum_round = neg_sum + {7'sb0,17'sb0,1'sb1,6'sb0};
        out_wire = neg_sum_round[30:7];
    end

    always @ (posedge clk) begin
        if(~srst_n) begin

            product_x_quant <= 0;
            product_y_quant <= 0;
            product_z_quant <= 0;

            out <= 0;
        end
        else begin
            product_x_quant <= product_x_quant_next;
            product_y_quant <= product_y_quant_next;
            product_z_quant <= product_z_quant_next;

            out <= out_wire;
        end
    end
endmodule