// module: cross_product
// This module is pipelined and takes two cycles to complete.
// Input
// - clk
// - Ux, Uy, Uz: 1Q23 unit vector
// - Vx, Vy, Vz: 1Q23 unit vector
// Output
// - out_x, out_y, out_z: 2Q24 because the maximum value of the output element is 1.0

module cross_product(
    input clk,

    // input: 1Q23
    input signed [23:0] Ux,
    input signed [23:0] Uy,
    input signed [23:0] Uz,
    // 1Q23
    input signed [23:0] Vx,
    input signed [23:0] Vy,
    input signed [23:0] Vz,

    // output 1Q23
    output signed reg [23:0] out_x,
    output signed reg [23:0] out_y,
    output signed reg [23:0] out_z
);
    // 1Q23 * 1Q23 = 1Q46
    reg [46:0] UyVz, UzVx, UxVy;
    reg [46:0] UzVy, UxVz, UyVx;
    // 1Q46 -> 1Q25
    reg [25:0] UyVz_quant_next, UzVx_quant_next, UxVy_quant_next;
    reg [25:0] UzVy_quant_next, UxVz_quant_next, UyVx_quant_next;
    reg [25:0] UyVz_quant, UzVx_quant, UxVy_quant;
    reg [25:0] UzVy_quant, UxVz_quant, UyVx_quant;

    reg [26:0] out_x_next, out_y_next, out_z_next;
    reg [25:0] out_x_quant_next, out_y_quant_next, out_z_quant_next;

    always @(*) begin
        // first stage
        UyVz = Uy * Vz;
        UzVx = Uz * Vx;
        UxVy = Ux * Vy;
        UzVy = Uz * Vy;
        UxVz = Ux * Vz;
        UyVx = Uy * Vx;

        // 1Q46 -> 1Q25
        UyVz_quant_next = (UyVz + {1'b0, 25'b0, 1'b1, 20'b0}) >> 21;
        UzVx_quant_next = (UzVx + {1'b0, 25'b0, 1'b1, 20'b0}) >> 21;
        UxVy_quant_next = (UxVy + {1'b0, 25'b0, 1'b1, 20'b0}) >> 21;
        UzVy_quant_next = (UzVy + {1'b0, 25'b0, 1'b1, 20'b0}) >> 21;
        UxVz_quant_next = (UxVz + {1'b0, 25'b0, 1'b1, 20'b0}) >> 21;
        UyVx_quant_next = (UyVx + {1'b0, 25'b0, 1'b1, 20'b0}) >> 21;

        // second stage
        out_x_next = UyVz_quant - UzVy_quant;
        out_y_next = UzVx_quant - UxVz_quant;
        out_z_next = UxVy_quant - UyVx_quant;

        // 2Q25 -> 2Q24
        out_x_quant_next = (out_x_next + {2'b0, 24'b0, 1'b1}) >> 1;
        out_y_quant_next = (out_y_next + {2'b0, 24'b0, 1'b1}) >> 1;
        out_z_quant_next = (out_z_next + {2'b0, 24'b0, 1'b1}) >> 1;
    end    

    always @(posedge clk) begin
        UyVz_quant <= UyVz_quant_next;
        UzVx_quant <= UzVx_quant_next;
        UxVy_quant <= UxVy_quant_next;
        UzVy_quant <= UzVy_quant_next;
        UxVz_quant <= UxVz_quant_next;
        UyVx_quant <= UyVx_quant_next;

        out_x <= out_x_quant_next;
        out_y <= out_y_quant_next;
        out_z <= out_z_quant_next;
    end

endmodule