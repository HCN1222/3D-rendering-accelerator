module vertex_shader(
	//from top
	input clk,
	input srst_n,
	input enable,
	input [23:0] eye_x,     // 4Q20
	input [23:0] eye_y,     // 4Q20
	input [23:0] eye_z,     // 4Q20
	input [23:0] center_x,  // 4Q20
	input [23:0] center_y,  // 4Q20
	input [23:0] center_z,  // 4Q20
	input [23:0] up_x,      // 4Q20
	input [23:0] up_y,      // 4Q20
	input [23:0] up_z,      // 4Q20
	
	//from controller
	input start_doing_shading,
	// input controller_signal_get,
	// input [19:0] controller_which_vertex,
	input [23:0] vertex_x, // 4Q20
	input [23:0] vertex_y, // 4Q20
	input [23:0] vertex_z, // 4Q20
	// input [23:0] Color_v,   // 4Q20
	
	//output
	
	//to controllor
	output reg [20:0] vertex1_depth_update,
	output reg [20:0] vertex2_depth_update,
	output reg [20:0] vertex3_depth_update,
	output reg [11:0] screen_x1_update,
	output reg [11:0] screen_y1_update,
	output reg [11:0] screen_x2_update,
	output reg [11:0] screen_y2_update,
	output reg [11:0] screen_x3_update,
	output reg [11:0] screen_y3_update,
	output reg MVP_ready,
	output reg data_ready
	
	//to top
	// output reg [19:0] address_sram_get_vertex_info
	
);

	// !!!!!!!!! SPEC !!!!!!!!!!!!!!!!!
	// Model matrix: skipped
	// View matrix: 2Q24, 2Q24, 2Q24, 7Q17
	// Projection matrix: 3Q21
	// MVP matrix: 11Q13

	// output wire
	reg [20:0] vertex1_depth_update_wire;
	reg [20:0] vertex2_depth_update_wire;
	reg [20:0] vertex3_depth_update_wire;
	reg [11:0] screen_x1_update_wire;
	reg [11:0] screen_y1_update_wire;
	reg [11:0] screen_x2_update_wire;
	reg [11:0] screen_y2_update_wire;
	reg [11:0] screen_x3_update_wire;
	reg [11:0] screen_y3_update_wire;
	reg MVP_ready_wire;
	reg data_ready_wire;


	// ********** inverse sqrare root ***********
	// - Takes twelve cycles to complete
	// - The module is pipelined
	// input: 
	// x, y, z: 4Q20
	// output:
	// out: 1Q24
	// ******************************
	reg signed [23:0] inv_sqrt_x, inv_sqrt_y, inv_sqrt_z;
	wire signed [23:0] inv_sqrt_out;

	inv_sqrt inv_sqrt(
		/*input*/ .clk(clk),
		.x( inv_sqrt_x ), .y( inv_sqrt_y ), .z( inv_sqrt_z ),
		/*output*/ .out( inv_sqrt_out )
	);

	// ********** negative dot product ***********
	// - Takes two cycles to complete
	// - The module is pipelined
	// input:
	// unit_x, unit_y, unit_z: 1Q23
	// x2, y2, z2: 4Q20
	// output: - (unit dot x2, y2, z2)
	// out: 7Q17
	// ******************************
	reg signed [25:0] neg_dot_product_unit_x, neg_dot_product_unit_y, neg_dot_product_unit_z;
	reg signed [23:0] neg_dot_product_x2, neg_dot_product_y2, neg_dot_product_z2;
	wire signed [23:0] neg_dot_product_out;

	neg_dot_product neg_dot_product(
		/*input*/ .clk(clk),
		.unit_x( neg_dot_product_unit_x ), .unit_y( neg_dot_product_unit_y ), .unit_z( neg_dot_product_unit_z ),
		.x2( neg_dot_product_x2 ), .y2( neg_dot_product_y2 ), .z2( neg_dot_product_z2 ),
		/*output*/ .out( neg_dot_product_out )
	);

	// ********** cross product ***********
	// - Takes two cycles to complete
	// - The module is pipelined
	// input:
	// Ux, Uy, Uz: 1Q23 unit vector
	// Vx, Vy, Vz: 1Q23 unit vector
	// output: U X V
	// out_x, out_y, out_z: 2Q24
	// ******************************
	reg signed [23:0] cross_product_Ux, cross_product_Uy, cross_product_Uz;
	reg signed [25:0] cross_product_Vx, cross_product_Vy, cross_product_Vz;
	wire signed [25:0] cross_product_out_x, cross_product_out_y, cross_product_out_z;

	cross_product cross_product(
		/*input*/ .clk(clk),
		.Ux( cross_product_Ux ), .Uy( cross_product_Uy ), .Uz( cross_product_Uz ),
		.Vx( cross_product_Vx ), .Vy( cross_product_Vy ), .Vz( cross_product_Vz ),
		/*output*/ .out_x( cross_product_out_x ), .out_y( cross_product_out_y ), .out_z( cross_product_out_z )
	);

	// FSM
	localparam IDLE = 4'd0;
	localparam GET_CAMZ = 4'd1;
	localparam GET_CAMX = 4'd2;
	localparam GET_CAMY = 4'd3;
	localparam GET_MVP = 4'd4;
	localparam TRANSFORM = 4'd5;
	localparam DONE = 4'd6;

	reg [3:0] state, state_next;
	reg [4:0] cnt, cnt_next;

	// View matrix
	//           2Q24   2Q24  2Q24         7Q17
	// View = [ [ X[0], Y[0], Z[0], -np.dot(X, camera.eye)],
	//          [ X[1], Y[1], Z[1], -np.dot(Y, camera.eye)],
	//          [ X[2], Y[2], Z[2], -np.dot(Z, camera.eye)],
	//          [ 0.00, 0.00, 0.00,          1.00         ] ]

	// Camera coordinates
	reg signed [25:0] CamZ [0:2];
	reg signed [49:0] CamZ_norm [0:2];
	reg signed [25:0] CamZ_next [0:2];

	reg signed [25:0] CamX [0:2];
	reg signed [49:0] CamX_norm [0:2];
	reg signed [25:0] CamX_next [0:2];

	reg signed [25:0] CamY [0:2];
	reg signed [25:0] CamY_next [0:2];
	// Dot result
	reg signed [23:0] neg_Z_dot_eye, neg_Z_dot_eye_next; // 7Q17
	reg signed [23:0] neg_X_dot_eye, neg_X_dot_eye_next; // 7Q17
	reg signed [23:0] neg_Y_dot_eye, neg_Y_dot_eye_next; // 7Q17

	// reg signed [25:0] View [0:3][0:3];
	// always @(*) begin
	// 	// 2Q24                 2Q24                   2Q24                  7Q17
	// 	View[0][0] = CamX[0];  View[0][1] = CamY[0];  View[0][2] = CamZ[0]  View[0][3] = neg_X_dot_eye;
	// 	View[1][0] = CamX[1];  View[1][1] = CamY[1];  View[1][2] = CamZ[1]  View[1][3] = neg_Y_dot_eye;
	// 	View[2][0] = CamX[2];  View[2][1] = CamY[2];  View[2][2] = CamZ[2]  View[2][3] = neg_Z_dot_eye;
	// 	View[3][0] = 0;		   View[3][1] = 0;		  View[3][2] = 0;	    View[3][3] = 1<<17;
	// end

	// reg signed [25:0] View [0:15];
	// always @(*) begin
	// 	// 2Q24                 2Q24                   2Q24                  7Q17
	// 	View[0] = CamX[0];  View[1] = CamY[0];  View[2] = CamZ[0];  View[3] = neg_X_dot_eye;
	// 	View[4] = CamX[1];  View[5] = CamY[1];  View[6] = CamZ[1];  View[7] = neg_Y_dot_eye;
	// 	View[8] = CamX[2];  View[9] = CamY[2];  View[10] = CamZ[2]; View[11] = neg_Z_dot_eye;
	// 	View[12] = 0;		View[13] = 0;		View[14] = 0;	   View[15] = 1<<17;
	// end

	wire signed [25:0] View [0:15];
	// 2Q24                 2Q24                   2Q24                  9Q17
	assign View[0] = CamX[0];
	assign View[1] = CamY[0];
	assign View[2] = CamZ[0];
	assign View[3] = neg_X_dot_eye;

	assign View[4] = CamX[1];
	assign View[5] = CamY[1];
	assign View[6] = CamZ[1];
	assign View[7] = neg_Y_dot_eye;

	assign View[8] = CamX[2];
	assign View[9] = CamY[2];
	assign View[10] = CamZ[2];
	assign View[11] = neg_Z_dot_eye;

	assign View[12] = 0;
	assign View[13] = 0;
	assign View[14] = 0;
	assign View[15] = 1<<17;

	
	// Projection matrix
	// reg signed [23:0] Projection [0:3][0:3];
	// always @(*) begin
	// 	// Projection matrix
	// 	// 3Q21
	// 	Projection[0][0] = 2847922; Projection[0][1] = 0;      Projection[0][2] = 0;      Projection[0][3] = 0;
	// 	Projection[1][0] = 0;      Projection[1][1] = 5062973; Projection[1][2] = 0;      Projection[1][3] = 0;
	// 	Projection[2][0] = 0;      Projection[2][1] = 0;      Projection[2][2] = -2139518; Projection[2][3] = -423667;
	// 	Projection[3][0] = 0;      Projection[3][1] = 0;      Projection[3][2] = -2097152;      Projection[3][3] = 0;
	// end
	// reg signed [23:0] Projection [0:15];
	// always @(*) begin
	// 	// Projection matrix
	// 	// 3Q21
	// 	Projection[0] = 2847922; Projection[1] = 0;      Projection[2] = 0;      Projection[3] = 0;
	// 	Projection[4] = 0;      Projection[5] = 5062973; Projection[6] = 0;      Projection[7] = 0;
	// 	Projection[8] = 0;      Projection[9] = 0;      Projection[10] = -2139518; Projection[11] = -423667;
	// 	Projection[12] = 0;      Projection[13] = 0;      Projection[14] = -2097152;      Projection[15] = 0;
	// end

	wire signed [23:0] Projection [0:15];
	// Projection matrix
	// 3Q21
	assign Projection[0] = 2847922;
	assign Projection[1] = 0;
	assign Projection[2] = 0;
	assign Projection[3] = 0;

	assign Projection[4] = 0;
	assign Projection[5] = 5062973;
	assign Projection[6] = 0;
	assign Projection[7] = 0;

	assign Projection[8] = 0;
	assign Projection[9] = 0;
	assign Projection[10] = -2139518;
	assign Projection[11] = -423667;

	assign Projection[12] = 0;
	assign Projection[13] = 0;
	assign Projection[14] = -2097152;
	assign Projection[15] = 0;


	// MVP matrix
	// reg signed [23:0] MVP [0:3][0:3];
	// reg signed [23:0] MVP_next [0:3][0:3];
	// reg signed [23:0] MVP_T [0:3][0:3];
	// always @ (*) begin
	// 	MVP_T[0][0] = MVP[0][0]; MVP_T[0][1] = MVP[1][0]; MVP_T[0][2] = MVP[2][0]; MVP_T[0][3] = MVP[3][0];
	// 	MVP_T[1][0] = MVP[0][1]; MVP_T[1][1] = MVP[1][1]; MVP_T[1][2] = MVP[2][1]; MVP_T[1][3] = MVP[3][1];
	// 	MVP_T[2][0] = MVP[0][2]; MVP_T[2][1] = MVP[1][2]; MVP_T[2][2] = MVP[2][2]; MVP_T[2][3] = MVP[3][2];
	// 	MVP_T[3][0] = MVP[0][3]; MVP_T[3][1] = MVP[1][3]; MVP_T[3][2] = MVP[2][3]; MVP_T[3][3] = MVP[3][3];
	// end
	reg signed [23:0] MVP [0:15];
	reg signed [25:0] MVP_sum [0:15];
	reg signed [25:0] MVP_sum_round [0:15];
	reg signed [23:0] MVP_next [0:15];
	// reg signed [23:0] MVP_T [0:15];
	// always @ (*) begin
	// 	MVP_T[0] = MVP[0]; MVP_T[1] = MVP[4]; MVP_T[2] = MVP[8]; MVP_T[3] = MVP[12];
	// 	MVP_T[4] = MVP[1]; MVP_T[5] = MVP[5]; MVP_T[6] = MVP[9]; MVP_T[7] = MVP[13];
	// 	MVP_T[8] = MVP[2]; MVP_T[9] = MVP[6]; MVP_T[10] = MVP[10]; MVP_T[11] = MVP[14];
	// 	MVP_T[12] = MVP[3]; MVP_T[13] = MVP[7]; MVP_T[14] = MVP[11]; MVP_T[15] = MVP[15];
	// end
	wire signed [23:0] MVP_T [0:15];
	assign MVP_T[0] = MVP[0];
	assign MVP_T[1] = MVP[4];
	assign MVP_T[2] = MVP[8];
	assign MVP_T[3] = MVP[12];

	assign MVP_T[4] = MVP[1];
	assign MVP_T[5] = MVP[5];
	assign MVP_T[6] = MVP[9];
	assign MVP_T[7] = MVP[13];

	assign MVP_T[8] = MVP[2];
	assign MVP_T[9] = MVP[6];
	assign MVP_T[10] = MVP[10];
	assign MVP_T[11] = MVP[14];

	assign MVP_T[12] = MVP[3];
	assign MVP_T[13] = MVP[7];
	assign MVP_T[14] = MVP[11];
	assign MVP_T[15] = MVP[15];


	// product quantization
	reg signed [49:0] product [0:15];
	reg signed [49:0] product_round [0:15];
	reg signed [23:0] product_quant [0:15];
	reg signed [23:0] product_quant_next [0:15];

	// sum quantization
	reg signed [23:0] sum [0:3];
	reg signed [25:0] sum_quant_next [0:3];
	reg signed [23:0] sum_next [0:3];

	// vertex matrix 4Q20
	// create homogeneous coordinates
	reg signed [23:0] vertex[0:3];
	always @(*) begin
		vertex[0] = vertex_x;
		vertex[1] = vertex_y;
		vertex[2] = vertex_z;
		vertex[3] = 1<<20;
	end

	// NDC
	wire signed [13:0] ndc_x, ndc_y, ndc_z;

	divider divider_x(
		/*input*/ .clk(clk),
		.dividend( sum[0] ),
		.divisor( sum[3] ),
		/*output*/ .quotient( ndc_x )
	);
	divider divider_y(
		/*input*/ .clk(clk),
		.dividend( sum[1] ),
		.divisor( sum[3] ),
		/*output*/ .quotient( ndc_y )
	);
	divider divider_z(
		/*input*/ .clk(clk),
		.dividend( sum[2] ),
		.divisor( sum[3] ),
		/*output*/ .quotient( ndc_z )
	);

	// screen space
	reg [15:0]shifted_ndc_x, shifted_ndc_y;
	reg [27:0] screen_x, screen_y;
	reg [27:0] screen_x_round, screen_y_round;
	reg [11:0] screen_x_quant, screen_y_quant;

	integer row, col;
	always @ (*) begin
		// output
		vertex1_depth_update_wire = vertex1_depth_update;
		vertex2_depth_update_wire = vertex2_depth_update;
		vertex3_depth_update_wire = vertex3_depth_update;
		screen_x1_update_wire = screen_x1_update;
		screen_y1_update_wire = screen_y1_update;
		screen_x2_update_wire = screen_x2_update;
		screen_y2_update_wire = screen_y2_update;
		screen_x3_update_wire = screen_x3_update;
		screen_y3_update_wire = screen_y3_update;
		MVP_ready_wire = 0;
		data_ready_wire = 0;

		state_next = state;
		cnt_next = cnt;

		// Camera coordinates
		CamZ_next[0] = CamZ[0];
		CamZ_next[1] = CamZ[1];
		CamZ_next[2] = CamZ[2];
		CamZ_norm[0] = 0;
		CamZ_norm[1] = 0;
		CamZ_norm[2] = 0;

		CamX_next[0] = CamX[0];
		CamX_next[1] = CamX[1];
		CamX_next[2] = CamX[2];
		CamX_norm[0] = 0;
		CamX_norm[1] = 0;
		CamX_norm[2] = 0;

		CamY_next[0] = CamY[0];
		CamY_next[1] = CamY[1];
		CamY_next[2] = CamY[2];

		// Dot result
		neg_Z_dot_eye_next = neg_Z_dot_eye;
		neg_X_dot_eye_next = neg_X_dot_eye;
		neg_Y_dot_eye_next = neg_Y_dot_eye;
		// inverse square root
		inv_sqrt_x = 0;
		inv_sqrt_y = 0;
		inv_sqrt_z = 0;
		// dot product
		neg_dot_product_unit_x = 0;
		neg_dot_product_unit_y = 0;
		neg_dot_product_unit_z = 0;
		neg_dot_product_x2 = 0;
		neg_dot_product_y2 = 0;
		neg_dot_product_z2 = 0;
		// cross product
		cross_product_Ux = 0;
		cross_product_Uy = 0;
		cross_product_Uz = 0;
		cross_product_Vx = 0;
		cross_product_Vy = 0;
		cross_product_Vz = 0;

		// MVP matrix
		for(row = 0; row < 4; row = row + 1) begin
			for(col = 0; col < 4; col = col + 1) begin
				MVP_sum[row*4+col] = 0;
				MVP_sum_round[row*4+col] = 0;
				MVP_next[row*4+col] = MVP[row*4+col];
			end
		end
		// product quantization
		for(row = 0; row < 4; row = row + 1) begin
			for(col = 0; col < 4; col = col + 1) begin
				product_quant_next[row*4+col] = 0;
				product_round[row*4+col] = 0;
			end
		end
		// sum
		for(col = 0; col < 4; col = col + 1) begin
			sum_quant_next[col] = 0;
			sum_next[col] = 0;
		end

		case (state)
			IDLE: begin
				cnt_next = 0;
				state_next = (enable) ? GET_CAMZ : IDLE;
			end
			GET_CAMZ: begin
				// ********** Summary ***********
				// 1. get Z = eye - center (1 cycle)
				// 2. get 1 / |z| (12 cycle)
				// 3. get Z * 1/|z| (1cycle)
				// ******************************

				// counter
				cnt_next = cnt + 1;
				case(cnt)
					
					0: begin // get Z = eye - center
						//   4Q22               4Q20
						CamZ_next[0] = (eye_x - center_x);
						CamZ_next[1] = (eye_y - center_y);
						CamZ_next[2] = (eye_z - center_z);
					end
					1: begin // send to inv_sqrt
						inv_sqrt_x = CamZ[0];
						inv_sqrt_y = CamZ[1];
						inv_sqrt_z = CamZ[2];
					end
					2, 3, 4, 5, 6, 7, 8, 9, 10, 11: begin
						// IDLE
					end
					12: begin // get Z * 1/|z|
						//   2Q24         (4Q20  * 1Q23) = 5Q43 -> 2Q24
						CamZ_norm[0] = ( CamZ[0] * inv_sqrt_out + {5'b0,24'b0,1'b1,18'b0} ) >> 19;
						CamZ_norm[1] = ( CamZ[1] * inv_sqrt_out + {5'b0,24'b0,1'b1,18'b0} ) >> 19;
						CamZ_norm[2] = ( CamZ[2] * inv_sqrt_out + {5'b0,24'b0,1'b1,18'b0} ) >> 19;
						CamZ_next[0] = CamZ_norm[0][25:0];
						CamZ_next[1] = CamZ_norm[1][25:0];
						CamZ_next[2] = CamZ_norm[2][25:0];

						state_next = GET_CAMX;
						cnt_next = 0;
					end
				endcase
			end
			GET_CAMX: begin
				// ********** Summary ***********
				// 1. get X = up X Z (2 cycles)
				// 2. a. get 1 / |x| (12 cycles)
				//    b. get -Z dot eye
				// 3. get X * 1/|x| (1 cycle)
				// ******************************
				// counter
				cnt_next = cnt + 1;
				case(cnt)
					0: begin // assign values for X = up X Z
						cross_product_Ux = up_x;
						cross_product_Uy = up_y;
						cross_product_Uz = up_z;
						cross_product_Vx = CamZ[0];
						cross_product_Vy = CamZ[1];
						cross_product_Vz = CamZ[2];
					end
					// 1: begin // get X = up X Z
					// 	CamX_next[0] = cross_product_out_x;
					// 	CamX_next[1] = cross_product_out_y;
					// 	CamX_next[2] = cross_product_out_z;
					// end
					2: begin
						 // get X = up X Z
						CamX_next[0] = cross_product_out_x;
						CamX_next[1] = cross_product_out_y;
						CamX_next[2] = cross_product_out_z;

						// send signals to inv_sqrt
						// because CamX is a 2Q24, and inv_sqrt is a 4Q20
						// we first let CamX // 4 by taking [25:2] 2Q24 -> 0Q24
						// then, shift left by 4 0Q24 -> 4Q20
						// to sum up, we let the input be 4 * CamX[25:2]
						inv_sqrt_x = cross_product_out_x[25:2];
						inv_sqrt_y = cross_product_out_y[25:2];
						inv_sqrt_z = cross_product_out_z[25:2];
						// send signals to neg_dot_product
						neg_dot_product_unit_x = CamZ[0];
						neg_dot_product_unit_y = CamZ[1];
						neg_dot_product_unit_z = CamZ[2];
						neg_dot_product_x2 = eye_x;
						neg_dot_product_y2 = eye_y;
						neg_dot_product_z2 = eye_z;
					end
					3: begin
						//IDLE
					end
					4: begin
						// Update negative Z dot eye
						neg_Z_dot_eye_next = neg_dot_product_out;
					end
					5, 6, 7, 8, 9, 10, 11, 12: begin
						// IDLE
					end
					13: begin
						// get X * 1/|x|
						//   2Q24         (4Q20  * 4Q20) = 8Q40
						if( CamX[0] == {2'b01, 24'b0} || CamX[0] == {2'b11, 24'b0}
						 || CamX[1] == {2'b01, 24'b0} || CamX[1] == {2'b11, 24'b0}
						 || CamX[2] == {2'b01, 24'b0} || CamX[2] == {2'b11, 24'b0} ) begin
							CamX_next[0] = CamX[0];
							CamX_next[1] = CamX[1];
							CamX_next[2] = CamX[2];
						end
						else begin
							//               (2Q24          3Q21) -> 5Q45 -> 5Q24
							CamX_norm[0] = ( CamX[0] * (inv_sqrt_out) + $signed({5'b0,24'b0,1'b1,20'b0}) ) >>> 21;
							CamX_norm[1] = ( CamX[1] * (inv_sqrt_out) + $signed({5'b0,24'b0,1'b1,20'b0}) ) >>> 21;
							CamX_norm[2] = ( CamX[2] * (inv_sqrt_out) + $signed({5'b0,24'b0,1'b1,20'b0}) ) >>> 21;
							// 5Q24 -> 2Q24
							CamX_next[0] = CamX_norm[0][25:0];
							CamX_next[1] = CamX_norm[1][25:0];
							CamX_next[2] = CamX_norm[2][25:0];
						end
						state_next = GET_CAMY;
						cnt_next = 0;
					end
				endcase
			end
			GET_CAMY: begin
				// ********** Summary ***********
				// 1. get Y = Z X X (2 cycles)
				// 2. a. get 1 / |y| (12 cycles)
				//    b. get -X dot eye
				// 3. get Y * 1/|y| (1 cycle)
				// 4. get -Y dot eye (2 cycles)
				cnt_next = cnt + 1;
				case(cnt)
					0: begin // assign values for Y = Z X X
						// we are treating CamZ(2Q24) as 4Q20
						// so we need to take [25:4] to fit into 4Q20
						cross_product_Ux = CamZ[0][25:4];
						cross_product_Uy = CamZ[1][25:4];
						cross_product_Uz = CamZ[2][25:4];
						cross_product_Vx = CamX[0];
						cross_product_Vy = CamX[1];
						cross_product_Vz = CamX[2];
						
						// send signals to neg_dot_product
						neg_dot_product_unit_x = CamX[0];
						neg_dot_product_unit_y = CamX[1];
						neg_dot_product_unit_z = CamX[2];
						neg_dot_product_x2 = eye_x;
						neg_dot_product_y2 = eye_y;
						neg_dot_product_z2 = eye_z;
					end
					// 1: begin
					// end
					2: begin
						// get Y = Z X X
						// CamY is already a unit vector
						// because CamZ and CamX are unit vectors and orthogonal
						CamY_next[0] = cross_product_out_x;
						CamY_next[1] = cross_product_out_y;
						CamY_next[2] = cross_product_out_z;

						// Update negative X dot eye
						neg_X_dot_eye_next = neg_dot_product_out;

						// send signals to neg_dot_product
						neg_dot_product_unit_x = cross_product_out_x;
						neg_dot_product_unit_y = cross_product_out_y;
						neg_dot_product_unit_z = cross_product_out_z;
						neg_dot_product_x2 = eye_x;
						neg_dot_product_y2 = eye_y;
						neg_dot_product_z2 = eye_z;
					end
					3: begin
						//IDLE
					end
					4: begin
						// Update negative Y dot eye
						neg_Y_dot_eye_next = neg_dot_product_out;

						state_next = GET_MVP;
						cnt_next = 0;
					end
				endcase
			end
			GET_MVP: begin
				// ********** Summary ***********
				// 1. get MVP = Model * View * Projection (5 cycles)
				// ******************************
				// counter
				cnt_next = cnt + 1;

				if (cnt>=0 && cnt<=3) begin
					for ( col=0; col<4; col=col+1 )begin
						for ( row=0; row<4; row=row+1 )begin
							// 5Q45            = 3Q21 * 2Q24 or 12Q38 = 3Q21 * 9Q17
							product[row*4+col] = Projection[cnt*4+row] * View[row*4+col];
							if(col == 3) begin
								// 3Q21 * 9Q17 = 12Q38 ->10Q14
								product_round[row*4+col] = (product[row*4+col] + {12'sb0, 15'sb0, 1'sb1, 22'sb0});
								product_quant_next[row*4+col] = product_round[row*4+col][47:24];
							end
							else begin
								// 3Q21 * 2Q24 = 5Q45 -> 5Q14 -> 10Q14
								product_round[row*4+col] = product[row*4+col] + {5'sb0, 15'sb0, 1'sb1, 30'sb0};
								product_quant_next[row*4+col] = { product_round[row*4+col][49], product_round[row*4+col][49], 
									product_round[row*4+col][49], product_round[row*4+col][49], product_round[row*4+col][49],
									product_round[row*4+col][49:31]};
							end
						end
					end
				end
				if (cnt >= 1 && cnt <= 4) begin
					for ( col=0; col<4; col=col+1 )begin
						// 10Q14 + 10Q14 + 10Q14 + 10Q14 = 12Q14 -> 12Q12
						MVP_sum[(cnt-1)*4+col] = ( product_quant[0*4+col] + product_quant[1*4+col]
						                        + product_quant[2*4+col] + product_quant[3*4+col]);
						MVP_sum_round[(cnt-1)*4+col] = ( MVP_sum[(cnt-1)*4+col] + 2'b10 );
						MVP_next[(cnt-1)*4+col] = MVP_sum_round[(cnt-1)*4+col][25:2];
					end
				end
				if (cnt == 4) begin
					MVP_ready_wire = 1;
				end
				if (start_doing_shading) begin
					state_next = TRANSFORM;
					cnt_next = 0;
				end
			end
			TRANSFORM: begin
				// ********** Summary ***********
				// three vertices, comes in 3 cycles
				// the following steps are pipelined
				// 1. multiply MVP with vertex (1 cycle)
				// 2. sum up the result (1 cycle)
				// 3. NDC (5 cycles)
				// 4. clip space to screen space (1 cycle)
				// counter
				cnt_next = cnt + 1;

				// stage 1
				for ( col=0; col<4; col=col+1 )begin
					for ( row=0; row<4; row=row+1 )begin
						//     18Q32              4Q20             12Q12
						product[row*4+col] = vertex[row] * MVP_T[row*4+col];
						// 18Q32 -> 14Q10
						product_round[row*4+col] = ( product[row*4+col] + {14'b0, 10'b0, 1'b1, 21'b0} ) >>> 22;
						product_quant_next[row*4+col] = product_round[row*4+col];
					end
				end
				// stage 2
				for ( col=0; col<4; col=col+1 )begin
					// 14Q10 + 14Q10 + 14Q10 + 14Q10 = 16Q10
					sum_quant_next[col] = (product_quant[0*4+col] + product_quant[1*4+col] + product_quant[2*4+col] + product_quant[3*4+col]);
					// 16Q10 -> 16Q8
					sum_next[col] = ( sum_quant_next[col] + 2'b10 ) >>> 2;
				end
				// stage 3 4 5 6
					// divider divider_x(
					// 	/*input*/ .clk(clk),
					// 	.dividend( sum[0] ),
					// 	.divisor( sum[3] ),
					// 	/*output*/ .quotient( ndc_x )
					// );
					// divider divider_y(
					// 	/*input*/ .clk(clk),
					// 	.dividend( sum[1] ),
					// 	.divisor( sum[3] ),
					// 	/*output*/ .quotient( ndc_y )
					// );
					// divider divider_z(
					// 	/*input*/ .clk(clk),
					// 	.dividend( sum[2] ),
					// 	.divisor( sum[3] ),
					// 	/*output*/ .quotient( ndc_z )
				// stage 7
				// ndc_x + 1: 2Q12 + 2Q12 = 4Q12
				// (ndc_x + 1) / 2: 4Q12 -> 3Q13
				// (ndc_x + 1) / 2 * camera.screen_W: 3Q13 * 12Q0 = 15Q13
				// screen_x: 15Q13 -> 15Q0

				// screen_x = (ndc_x + 1) / 2 * camera.screen_W
				//                2Q12           2Q12
				shifted_ndc_x = (ndc_x + 14'sb01_0000_0000_0000); // 4Q12
				// divided by 2 : 4Q12 -> 3Q13
				//                 3Q13    *     12Q0 -> 15Q13 -> 15Q0
				screen_x = (shifted_ndc_x * 12'sd1280);
				screen_x_round = (screen_x  + 26'sb0_0000_0000_0000_1_0000_0000_0000) >>> 13;
				screen_x_quant = screen_x_round;

				// screen_y = (1 - (ndc_y + 1) / 2) * camera.screen_H
				//          = ( 1/2 - ndc_y/2 ) * camera.screen_H
				//              2Q13 - 1Q13 
				shifted_ndc_y = ( 16'sb000_1_0000_0000_0000 - ndc_y ); // 2Q13 -> 2Q13
				screen_y = (shifted_ndc_y[13:0] * 12'd720);
				screen_y_round = (screen_y  + 26'sb0_0000_0000_0000_1_0000_0000_0000 ) >>> 13;
				screen_y_quant = screen_y_round;

				// output wire
				case(cnt)
					7: begin
						vertex1_depth_update_wire = {ndc_z, 8'd0};
						screen_x1_update_wire = screen_x_quant;
						screen_y1_update_wire = screen_y_quant;
					end
					8: begin
						vertex2_depth_update_wire = {ndc_z, 8'd0};
						screen_x2_update_wire = screen_x_quant;
						screen_y2_update_wire = screen_y_quant;
					end
					9: begin
						vertex3_depth_update_wire = {ndc_z, 8'd0};
						screen_x3_update_wire = screen_x_quant;
						screen_y3_update_wire = screen_y_quant;
					end
					default: begin
						vertex1_depth_update_wire = vertex1_depth_update;
						vertex2_depth_update_wire = vertex2_depth_update;
						vertex3_depth_update_wire = vertex3_depth_update;
						screen_x1_update_wire = screen_x1_update;
						screen_y1_update_wire = screen_y1_update;
						screen_x2_update_wire = screen_x2_update;
						screen_y2_update_wire = screen_y2_update;
						screen_x3_update_wire = screen_x3_update;
						screen_y3_update_wire = screen_y3_update;
					end
				endcase

				if (cnt == 9) begin
					data_ready_wire = 1;
					state_next = DONE;
					cnt_next = 0;
				end
			end
			DONE: begin
				data_ready_wire = 1;
				if ( start_doing_shading ) begin
					state_next = TRANSFORM;
					cnt_next = 0;
				end
			end
			default: begin
				// output
				vertex1_depth_update_wire = vertex1_depth_update;
				vertex2_depth_update_wire = vertex2_depth_update;
				vertex3_depth_update_wire = vertex3_depth_update;
				screen_x1_update_wire = screen_x1_update;
				screen_y1_update_wire = screen_y1_update;
				screen_x2_update_wire = screen_x2_update;
				screen_y2_update_wire = screen_y2_update;
				screen_x3_update_wire = screen_x3_update;
				screen_y3_update_wire = screen_y3_update;
				MVP_ready_wire = 0;
				data_ready_wire = 0;

				state_next = state;
				cnt_next = cnt;

				// Camera coordinates
				CamZ_next[0] = CamZ[0];
				CamZ_next[1] = CamZ[1];
				CamZ_next[2] = CamZ[2];
				CamZ_norm[0] = 0;
				CamZ_norm[1] = 0;
				CamZ_norm[2] = 0;

				CamX_next[0] = CamX[0];
				CamX_next[1] = CamX[1];
				CamX_next[2] = CamX[2];
				CamX_norm[0] = 0;
				CamX_norm[1] = 0;
				CamX_norm[2] = 0;

				CamY_next[0] = CamY[0];
				CamY_next[1] = CamY[1];
				CamY_next[2] = CamY[2];

				// Dot result
				neg_Z_dot_eye_next = neg_Z_dot_eye;
				neg_X_dot_eye_next = neg_X_dot_eye;
				neg_Y_dot_eye_next = neg_Y_dot_eye;
				// inverse square root
				inv_sqrt_x = 0;
				inv_sqrt_y = 0;
				inv_sqrt_z = 0;
				// dot product
				neg_dot_product_unit_x = 0;
				neg_dot_product_unit_y = 0;
				neg_dot_product_unit_z = 0;
				neg_dot_product_x2 = 0;
				neg_dot_product_y2 = 0;
				neg_dot_product_z2 = 0;
				// cross product
				cross_product_Ux = 0;
				cross_product_Uy = 0;
				cross_product_Uz = 0;
				cross_product_Vx = 0;
				cross_product_Vy = 0;
				cross_product_Vz = 0;

				// MVP matrix
				for(row = 0; row < 4; row = row + 1) begin
					for(col = 0; col < 4; col = col + 1) begin
						MVP_sum[row*4+col] = {MVP[row*4+col], 2'b0};
						MVP_next[row*4+col] = MVP[row*4+col];
					end
				end
				// product quantization
				for(row = 0; row < 4; row = row + 1) begin
					for(col = 0; col < 4; col = col + 1) begin
						product_quant_next[row*4+col] = 0;
					end
				end
				// sum
				for(col = 0; col < 4; col = col + 1) begin
					sum_quant_next[col] = 0;
				end

			end
		endcase
	end

	integer i, j;
	always @ (posedge clk) begin
		if (~srst_n) begin
			state <= IDLE;
		end
		else begin
			state <= state_next;
		end
		
		// output wire
		vertex1_depth_update <= vertex1_depth_update_wire;
		vertex2_depth_update <= vertex2_depth_update_wire;
		vertex3_depth_update <= vertex3_depth_update_wire;
		screen_x1_update <= screen_x1_update_wire;
		screen_y1_update <= screen_y1_update_wire;
		screen_x2_update <= screen_x2_update_wire;
		screen_y2_update <= screen_y2_update_wire;
		screen_x3_update <= screen_x3_update_wire;
		screen_y3_update <= screen_y3_update_wire;
		MVP_ready <= MVP_ready_wire;
		data_ready <= data_ready_wire;

		// counter
		cnt <= cnt_next;
		// Camera axes
		CamZ[0] <= CamZ_next[0];
		CamZ[1] <= CamZ_next[1];
		CamZ[2] <= CamZ_next[2];
		
		CamX[0] <= CamX_next[0];
		CamX[1] <= CamX_next[1];
		CamX[2] <= CamX_next[2];

		CamY[0] <= CamY_next[0];
		CamY[1] <= CamY_next[1];
		CamY[2] <= CamY_next[2];
		// Dot product
		neg_Z_dot_eye <= neg_Z_dot_eye_next;
		neg_X_dot_eye <= neg_X_dot_eye_next;
		neg_Y_dot_eye <= neg_Y_dot_eye_next;

		// MVP matrix
		for (i=0; i<4; i=i+1)begin
			for (j=0; j<4; j=j+1)begin
				MVP[i*4+j] <= MVP_next[i*4+j];
			end
		end

		// product quant
		for (i=0; i<4; i=i+1)begin
			for (j=0; j<4; j=j+1)begin
				product_quant[i*4+j] <= product_quant_next[i*4+j];
			end
		end

		// sum
		for (i=0; i<4; i=i+1)begin
			sum[i] <= sum_next[i];
		end

	end

endmodule


