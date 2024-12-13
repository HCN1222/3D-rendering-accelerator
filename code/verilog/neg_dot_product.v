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
    // 2Q24
    input signed [25:0] unit_x,
    input signed [25:0] unit_y,
    input signed [25:0] unit_z,
    // input: 4Q20
    input signed [23:0] x2,
    input signed [23:0] y2,
    input signed [23:0] z2,
    // output: 7Q17
    output signed reg [23:0] out
);    
    // product_x = unit_x *  x
    //   5Q44    2Q24    4Q20
    reg [48:0] product_x, product_y, product_z;
    // quantization: 5Q44 -> 5Q24
    reg [28:0] product_x_quant_next, product_y_quant_next, product_z_quant_next;
    reg [28:0] product_x_quant, product_y_quant, product_z_quant;

    // output: 7Q17
    reg [23:0] out_wire;

    always @(*) begin
        product_x = unit_x * x2;
        product_y = unit_y * y2;
        product_z = unit_z * z2;
        // 5Q44 -> 5Q24
        product_x_quant_next = ( product_x + {5'b0, 24'b0, 1'b1, 19'b0} ) >> 20;
        product_y_quant_next = ( product_y + {5'b0, 24'b0, 1'b1, 19'b0} ) >> 20;
        product_z_quant_next = ( product_z + {5'b0, 24'b0, 1'b1, 19'b0} ) >> 20;
        // 5Q24 -> 7Q24 -> 7Q17
        out_wire = - ( ( (product_x_quant + product_y_quant + product_z_quant) + {7'b0,17'b0,1'b1,6'b0} ) >> 7);
    end

    always @ (posedge clk) begin
        product_x_quant <= product_x_quant_next;
        product_y_quant <= product_y_quant_next;
        product_z_quant <= product_z_quant_next;

        out <= out_wire;
    end
endmodule