// module: cross_product
// This module is pipelined and takes two cycles to complete.
// Input
// - clk
// - Ux, Uy, Uz: 4Q20 unit vector
// - Vx, Vy, Vz: 2Q24 unit vector
// Output
// - out_x, out_y, out_z: 2Q24 because the maximum value of the output element is 1.0

module cross_product(
    input clk,

    // input: 4Q20
    input signed [23:0] Ux,
    input signed [23:0] Uy,
    input signed [23:0] Uz,
    // 2Q24
    input signed [25:0] Vx,
    input signed [25:0] Vy,
    input signed [25:0] Vz,

    // output 2Q24
    output reg signed [25:0] out_x,
    output reg signed [25:0] out_y,
    output reg signed [25:0] out_z
);
    // 4Q20 * 2Q24 = 6Q44
    reg [49:0] UyVz, UzVx, UxVy;
    reg [49:0] UzVy, UxVz, UyVx;
    // 6Q44 -> 2Q44
    reg [45:0] UyVz_round_next, UzVx_round_next, UxVy_round_next;
    reg [45:0] UzVy_round_next, UxVz_round_next, UyVx_round_next;
    // 2Q44 -> 2Q25
    reg [26:0] UyVz_quant_next, UzVx_quant_next, UxVy_quant_next;
    reg [26:0] UzVy_quant_next, UxVz_quant_next, UyVx_quant_next;
    reg [26:0] UyVz_quant, UzVx_quant, UxVy_quant;
    reg [26:0] UzVy_quant, UxVz_quant, UyVx_quant;
    // 2Q25 -> 2Q24
    reg [26:0] out_x_next, out_y_next, out_z_next;
    reg [26:0] out_x_round_next, out_y_round_next, out_z_round_next;
    reg [25:0] out_x_quant_next, out_y_quant_next, out_z_quant_next;

    always @(*) begin
        // first stage
        UyVz = Uy * Vz;
        UzVx = Uz * Vx;
        UxVy = Ux * Vy;
        UzVy = Uz * Vy;
        UxVz = Ux * Vz;
        UyVx = Uy * Vx;

        // 6Q44 -> 2Q44
        UyVz_round_next = UyVz[45:0] + {27'b0, 1'b1, 18'b0};
        UzVx_round_next = UzVx[45:0] + {27'b0, 1'b1, 18'b0};
        UxVy_round_next = UxVy[45:0] + {27'b0, 1'b1, 18'b0};
        UzVy_round_next = UzVy[45:0] + {27'b0, 1'b1, 18'b0};
        UxVz_round_next = UxVz[45:0] + {27'b0, 1'b1, 18'b0};
        UyVx_round_next = UyVx[45:0] + {27'b0, 1'b1, 18'b0};
        // 2Q44 -> 2Q25
        UyVz_quant_next = UyVz_round_next[45:19];
        UzVx_quant_next = UzVx_round_next[45:19];
        UxVy_quant_next = UxVy_round_next[45:19];
        UzVy_quant_next = UzVy_round_next[45:19];
        UxVz_quant_next = UxVz_round_next[45:19];
        UyVx_quant_next = UyVx_round_next[45:19];

        // second stage
        out_x_next = UyVz_quant - UzVy_quant;
        out_y_next = UzVx_quant - UxVz_quant;
        out_z_next = UxVy_quant - UyVx_quant;

        // 2Q25 -> 2Q24
        out_x_round_next = out_x_next + {2'b0, 24'b0, 1'b1};
        out_y_round_next = out_y_next + {2'b0, 24'b0, 1'b1};
        out_z_round_next = out_z_next + {2'b0, 24'b0, 1'b1};
        out_x_quant_next = out_x_round_next[26:1];
        out_y_quant_next = out_y_round_next[26:1];
        out_z_quant_next = out_z_round_next[26:1];
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