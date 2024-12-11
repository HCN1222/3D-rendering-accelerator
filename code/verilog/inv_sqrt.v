module inv_sqrt
(
    input  clk,
    input  [23:0] x,
    input  [23:0] y,
    input  [23:0] z,
    output reg [23:0] out
);

    // ********** Summary ***********
    // 1. find the square of x, y, and z
    //    quantized x, y, z to 4Q13
    //        4Q13 * 4Q13 = 8Q26
    //    Quantized to 8Q24

    // 2. Add the square of x_2_quant, y_2_quant, and z_2_quant
    //        SUM = 8Q24 + 8Q24 + 8Q24 = 10Q24  (0~128*3)
    //    The value of SUM is always possitive, take the integer part of SUM (9Q0)
    //    By LUT, we get the inital value of 1/sqrt( int(SUM) )
    //    We call this X0 (1Q24)

    // 3. Newton-Raphson iteration 1-1
    //    because X0 is promised to be smaller than 1, X0_2 is smaller than 1
    //    X0_2 = X0 * X0 (1Q24 * 1Q24 = 1Q48)
    //    quantized to 1Q24

    // 4. Newton-Raphson iteration 1-2
    //                  10Q24   1Q24
    //    coeff = ( 3 - (SUM) * X0_2 ) / 2 (10Q48 -> 9Q49)
    //    By simulation, we find that the value of coeff is always smaller than 2
    //    quantized to 3Q24

    // 5. Newton-Raphson iteration 1-3
    //    X1 = X0 * coeff (1Q24 * 3Q24 = 4Q48)
    //    By simulation, we find that the value of X1 is always smaller than 1
    //    quantized to 1Q24

    // 6 7 8 9 10 11
    // Repeat 3-5 for 2 times
    // Last assign out_wire = abs( X3 )


    // ASSIGN X3 to out
    // ******************************

    // ************** step 1 *******************
    // find the square of x, y, and z
    reg signed [47:0] x_2, y_2, z_2;

    // quantized the value of x_2, y_2, and z_2 to 8Q24
    reg signed [23:0] x_2_quant, x_2_quant_next;
    reg signed [23:0] y_2_quant, y_2_quant_next;
    reg signed [23:0] z_2_quant, z_2_quant_next;

    // ************** step 2 *******************
    // SUM
    reg signed [33:0] SUM, SUM_next;
    // LUT
    reg signed [24:0] X0, X_next;
    inv_sqrt_LUT LUT( .IN(SUM_next[32:0]), .OUT(X0_next) );

    // ************** step 3 *******************
    // Newton-Raphson iteration 1-1
    reg signed [49:0] X0_2;
    reg signed [48:0] X0_2_trunc;
    reg signed [24:0] X0_2_quant, X0_2_quant_next;

    // ************** step 4 *******************
    // Newton-Raphson iteration 1-2
    reg signed [57:0] coeff_0; // 9Q49
    reg signed [51:0] coeff_0_trunc; // 3Q49
    reg signed [26:0] coeff_0_quant, coeff_0_quant_next; // 3Q24

    // ************** step 5 *******************
    // Newton-Raphson iteration 1-3
    reg signed [53:0] X1; // 4Q48
    reg signed [48:0] X1_trunc; // 1Q48
    reg signed [24:0] X1_quant, X1_quant_next; // 1Q24

    // ************** step 6 *******************
    // Newton-Raphson iteration 2-1
    reg signed [49:0] X1_2;
    reg signed [48:0] X1_2_trunc;
    reg signed [24:0] X1_2_quant, X1_2_quant_next;

    // ************** step 7 *******************
    // Newton-Raphson iteration 2-2
    reg signed [57:0] coeff_1; // 9Q49
    reg signed [51:0] coeff_1_trunc; // 3Q49
    reg signed [26:0] coeff_1_quant, coeff_1_quant_next; // 3Q24

    // ************** step 8 *******************
    // Newton-Raphson iteration 2-3
    reg signed [53:0] X2; // 4Q48
    reg signed [48:0] X2_trunc; // 1Q48
    reg signed [24:0] X2_quant, X2_quant_next; // 1Q24

    // ************** step 9 *******************
    // Newton-Raphson iteration 3-1
    reg signed [49:0] X2_2;    
    reg signed [48:0] X2_2_trunc;
    reg signed [24:0] X2_2_quant, X2_2_quant_next;

    // ************** step 10 *******************
    // Newton-Raphson iteration 3-2
    reg signed [57:0] coeff_2; // 9Q49
    reg signed [51:0] coeff_2_trunc; // 3Q49
    reg signed [26:0] coeff_2_quant, coeff_2_quant_next; // 3Q24

    // ************** step 11 *******************
    // Newton-Raphson iteration 3-3
    reg signed [53:0] X3; // 4Q48
    reg signed [48:0] X3_trunc; // 1Q48
    reg signed [24:0] X3_quant, X3_quant_next; // 1Q24

    // output
    reg signed [24:0] out_wire;

    // combinational logic
    always @(*) begin
        // ***************** step 1 *******************
        // get the square of x, y, and z
        x_2 = x * x;
        y_2 = y * y;
        z_2 = z * z;
        // quantized: 8Q48 -> 8Q24
        //          8Q25   +     1
        x_2_quant_next = (x_2 + {8'b0, 1'b1, 47'b0}) >> 24;
        y_2_quant_next = (y_2 + {8'b0, 1'b1, 47'b0}) >> 24;
        z_2_quant_next = (z_2 + {8'b0, 1'b1, 47'b0}) >> 24;

        // ************** step 2 *******************
        // Calculate SUM
        SUM_next = x_2_quant + y_2_quant + z_2_quant;
        // Connected to LUT module
        // .IN(SUM_next[32:0]), .OUT(X0_next)

        // ************** step 3 *******************
        // Newton-Raphson iteration 1-1
        X0_2 = X0 * X0;
        // truncation: 2Q48 -> 1Q48
        X0_2_trunc = X0_2[48:0];
        // quantized: 1Q48 -> 1Q24
        X0_2_quant_next = (X0_2_trunc + {1'b0, 24'b0, 1'b1, 23'b0}) >> 24;

        // ************** step 4 *******************
        // Newton-Raphson iteration 1-2
        coeff_0 = ( (3<<48) - (SUM * X0_2_quant) );
        // divide by 2 -> 10Q48 -> 9Q49
        // truncation: 9Q49 -> 3Q49
        coeff_0_trunc = coeff_0[51:0];
        // quantized: 3Q49 -> 3Q24
        coeff_0_quant_next = (coeff_0_trunc + {3'b0, 24'b0, 1'b1, 24'b0}) >> 25;

        // ************** step 5 *******************
        // Newton-Raphson iteration 1-3
        X1 = X0 * coeff_0_quant;
        // truncate: 4Q48 -> 1Q48
        X1_trunc = X1[48:0];
        // quantized: 1Q48 -> 1Q24
        X1_quant_next = (X1_trunc + {1'b0, 24'b0, 1'b1, 23'b0}) >> 24;

        // ************** step 6 *******************
        // Newton-Raphson iteration 2-1
        X1_2 = X1 * X1;
        // truncation: 2Q48 -> 1Q48
        X1_2_trunc = X1_2[48:0];
        // quantized: 1Q48 -> 1Q24
        X1_2_quant_next = (X1_2_trunc + {1'b0, 24'b0, 1'b1, 23'b0}) >> 24;

        // ************** step 7 *******************
        // Newton-Raphson iteration 2-2
        coeff_1 = ( (3<<48) - (SUM * X1_2_quant) );
        // divide by 2 -> 10Q48 -> 9Q49
        // truncation: 9Q49 -> 3Q49
        coeff_1_trunc = coeff_1[51:0];
        // quantized: 3Q49 -> 3Q24
        coeff_1_quant_next = (coeff_1_trunc + {3'b0, 24'b0, 1'b1, 24'b0}) >> 25;

        // ************** step 8 *******************
        // Newton-Raphson iteration 2-3
        X2 = X1 * coeff_1_quant;
        // truncate: 4Q48 -> 1Q48
        X2_trunc = X2[48:0];
        // quantized: 1Q48 -> 1Q24
        X2_quant_next = (X2_trunc + {1'b0, 24'b0, 1'b1, 23'b0}) >> 24;

        // ************** step 9 *******************
        // Newton-Raphson iteration 3-1
        X2_2 = X2 * X2;
        // truncation: 2Q48 -> 1Q48
        X2_2_trunc = X2_2[48:0];
        // quantized: 1Q48 -> 1Q24
        X2_2_quant_next = (X2_2_trunc + {1'b0, 24'b0, 1'b1, 23'b0}) >> 24;

        // ************** step 10 *******************
        // Newton-Raphson iteration 3-2
        coeff_2 = ( (3<<48) - (SUM * X2_2_quant) );
        // divide by 2 -> 10Q48 -> 9Q49
        // truncation: 9Q49 -> 3Q49
        coeff_2_trunc = coeff_2[51:0];
        // quantized: 3Q49 -> 3Q24
        coeff_2_quant_next = (coeff_2_trunc + {3'b0, 24'b0, 1'b1, 24'b0}) >> 25;

        // ************** step 11 *******************
        // Newton-Raphson iteration 3-3
        X3 = X2 * coeff_2_quant;
        // truncate: 4Q48 -> 1Q48
        X3_trunc = X3[48:0];
        // quantized: 1Q48 -> 1Q24
        X3_quant_next = (X3_trunc + {1'b0, 24'b0, 1'b1, 23'b0}) >> 24;

        out_wire = (X3_quant_next > 0) ? X3_quant_next : -X3_quant_next;




    end
    // sequential logic
    always @(posedge clk) begin
        // ***************** step 1 *******************
        y_2_quant <= y_2_quant_next;
        x_2_quant <= x_2_quant_next;
        z_2_quant <= z_2_quant_next;
        // ***************** step 2 *******************
        SUM <= SUM_next;
        X0 <= X0_next;
        // ***************** step 3 *******************
        X0_2_quant <= X0_2_quant_next;
        // ***************** step 4 *******************
        coeff_0_quant <= coeff_0_quant_next;
        // ***************** step 5 *******************
        X1_quant <= X1_quant_next;
        // ***************** step 6 *******************
        X1_2_quant <= X1_2_quant_next;
        // ***************** step 7 *******************
        coeff_1_quant <= coeff_1_quant_next;
        // ***************** step 8 *******************
        X2_quant <= X2_quant_next;
        // ***************** step 9 *******************
        X2_2_quant <= X2_2_quant_next;
        // ***************** step 10 *******************
        coeff_2_quant <= coeff_2_quant_next;
        // ***************** step 11 *******************
        X3_quant <= X3_quant_next;
        out <= out_wire;
    end

endmodule