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
	input [23:0] vertex_x, // 4Q20
	input [23:0] vertex_y, // 4Q20
	input [23:0] vertex_z, // 4Q20
	input [23:0] Color_v,   // 4Q20
	
	//from controller
	input controller_signal_get,
	input [19:0] controller_which_vertex,
	input start_doing_shading,
	
	//output
	
	//to controllor
	output [20:0] vertex1_depth_update,
	output [20:0] vertex2_depth_update,
	output [20:0] vertex3_depth_update,
	output [11:0] screen_x1_update,
	output [11:0] screen_y1_update,
	output [11:0] screen_x2_update,
	output [11:0] screen_y2_update,
	output [11:0] screen_x3_update,
	output [11:0] screen_y3_update,
	output MVP_ready,
	output data_ready,
	
	//to top
	output [19:0] address_sram_get_vertex_info
	
);

	// !!!!!!!!! SPEC !!!!!!!!!!!!!!!!!
	// Model matrix: skipped
	// View matrix: 2Q24, 2Q24, 2Q24, 7Q17
	// Projection matrix: 3Q21
	// MVP matrix: 8Q16

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
	reg [23:0] inv_sqrt_x, inv_sqrt_y, inv_sqrt_z;
	reg [24:0] inv_sqrt_out;

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
	reg signed [23:0] neg_dot_product_unit_x, neg_dot_product_unit_y, neg_dot_product_unit_z;
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
	reg signed [23:0] cross_product_Vx, cross_product_Vy, cross_product_Vz;
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
	reg signed [25:0] CamZ_next [0:2];
	reg signed [25:0] CamX [0:2];
	reg signed [25:0] CamX_next [0:2];
	reg signed [25:0] CamY [0:2];
	reg signed [25:0] CamY_next [0:2];
	// Dot result
	reg signed [23:0] neg_Z_dot_eye, neg_Z_dot_eye_next; // 7Q17
	reg signed [23:0] neg_X_dot_eye, neg_X_dot_eye_next; // 7Q17
	reg signed [23:0] neg_Y_dot_eye, neg_Y_dot_eye_next; // 7Q17

	reg signed [23:0] View [0:3][0:3];
	always @(*) begin
		// 2Q24                 2Q24                   2Q24                  7Q17
		View[0][0] = CamX[0];  View[0][1] = CamY[0];  View[0][2] = CamZ[0]  View[0][3] = neg_X_dot_eye;
		View[1][0] = CamX[1];  View[1][1] = CamY[1];  View[1][2] = CamZ[1]  View[1][3] = neg_Y_dot_eye;
		View[2][0] = CamX[2];  View[2][1] = CamY[2];  View[2][2] = CamZ[2]  View[2][3] = neg_Z_dot_eye;
		View[3][0] = 0;		   View[3][1] = 0;		  View[3][2] = 0;	    View[3][3] = 1<<17;
	end
	
	// Projection matrix
	reg signed [23:0] Projection [0:3][0:3];
	always @(*) begin
		// Projection matrix
		// 3Q21
		$display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		$display("Projection matrix NOT YET FILLED");
		Projection[0][0] = 1<<21; Projection[0][1] = 0;      Projection[0][2] = 0;      Projection[0][3] = 0;
		Projection[1][0] = 0;      Projection[1][1] = 1<<21; Projection[1][2] = 0;      Projection[1][3] = 0;
		Projection[2][0] = 0;      Projection[2][1] = 0;      Projection[2][2] = 1<<21; Projection[2][3] = 0;
		Projection[3][0] = 0;      Projection[3][1] = 0;      Projection[3][2] = 0;      Projection[3][3] = 1<<21;
	end

	// MVP matrix
	reg signed [23:0] MVP [0:3][0:3];
	reg signed [23:0] MVP_next [0:3][0:3];

	// product quantization
	reg signed [47:0] product [0:3][0:3];
	reg signed [23:0] product_quant [0:3][0:3];
	reg signed [23:0] product_quant_next [0:3][0:3];
	// sum quantization
	reg signed [25:0] sum [0:3][0:3];
	reg signed [23:0] sum_next [0:3][0:3];

	// vertex matrix 4Q20
	// create homogeneous coordinates
	reg signed [23:0] vertex [0][0:3];
	always @(*) begin
		vertex[0][0] = vertex_x;
		vertex[0][1] = vertex_y;
		vertex[0][2] = vertex_z;
		vertex[0][3] = 1<<20;
	end

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
				MVP_next[row][col] = MVP[row][col];
			end
		end
		// product quantization
		for(row = 0; row < 4; row = row + 1) begin
			for(col = 0; col < 4; col = col + 1) begin
				product_quant_next[row][col] = 0;
			end
		end
		// sum quantization
		for(row = 0; row < 4; row = row + 1) begin
			for(col = 0; col < 4; col = col + 1) begin
				sum_quant_next[row][col] = 0;
			end
		end

		case (state)
			IDLE: begin
				cnt_next = 0;
				state_next = (enable) ? CALC_VIEW : IDLE;
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
						CamZ_next[0] = eye_x - center_x;
						CamZ_next[1] = eye_y - center_y;
						CamZ_next[2] = eye_z - center_z;
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
						//   2Q24         (4Q20  * 1Q24) = 4Q44
						CamZ_next[0] = ( CamZ[0] * inv_sqrt_out + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
						CamZ_next[1] = ( CamZ[1] * inv_sqrt_out + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
						CamZ_next[2] = ( CamZ[2] * inv_sqrt_out + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
					
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
					1: begin // get X = up X Z
						CamX_next[0] = cross_product_out_x;
						CamX_next[1] = cross_product_out_y;
						CamX_next[2] = cross_product_out_z;
					end
					2: begin
						// send signals to inv_sqrt
						// because CamX is a 1Q23, and inv_sqrt is a 4Q20
						// we take the 0Q23 of CamX shift left by 4 bits(* 2^4) to make it 4Q20
						inv_sqrt_x = {CamX[0][22:0], 1'b0, 4'b0};
						inv_sqrt_y = {CamX[1][22:0], 1'b0, 4'b0};
						inv_sqrt_z = {CamX[2][22:0], 1'b0, 4'b0};
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
						//   2Q24         (4Q20  * 1Q24) = 4Q44
						if( CamX_next[0][24] == 1 || CamX_next[1][24] == 1 || CamX_next[2][24] == 1 ) begin
							Cam_next[0] = Cam[0] >>> 2;
							Cam_next[1] = Cam[1] >>> 2;
							Cam_next[2] = Cam[2] >>> 2;
						end
						else begin
							CamX_next[0] = ( CamX[0] * (inv_sqrt_out >>> 2) + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
							CamX_next[1] = ( CamX[1] * (inv_sqrt_out >>> 2) + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
							CamX_next[2] = ( CamX[2] * (inv_sqrt_out >>> 2) + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
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
						cross_product_Ux = CamZ[0];
						cross_product_Uy = CamZ[1];
						cross_product_Uz = CamZ[2];
						cross_product_Vx = CamX[0];
						cross_product_Vy = CamX[1];
						cross_product_Vz = CamX[2];
					end
					1: begin // get Y = Z X X
						CamY_next[0] = cross_product_out_x;
						CamY_next[1] = cross_product_out_y;
						CamY_next[2] = cross_product_out_z;
					end
					2: begin
						// send signals to inv_sqrt
						// because CamY is a 1Q23, and inv_sqrt is a 4Q20
						// we take the 0Q23 of CamY shift left by 4 bits(* 2^4) to make it 4Q20
						inv_sqrt_x = {CamY[0][22:0], 1'b0, 4'b0};
						inv_sqrt_y = {CamY[1][22:0], 1'b0, 4'b0};
						inv_sqrt_z = {CamY[2][22:0], 1'b0, 4'b0};
						// send signals to neg_dot_product
						neg_dot_product_unit_x = CamX[0];
						neg_dot_product_unit_y = CamX[1];
						neg_dot_product_unit_z = CamX[2];
						neg_dot_product_x2 = eye_x;
						neg_dot_product_y2 = eye_y;
						neg_dot_product_z2 = eye_z;
					end
					3: begin
						//IDLE
					end
					4: begin
						// Update negative X dot eye
						neg_X_dot_eye_next = neg_dot_product_out;
					end
					5, 6, 7, 8, 9, 10, 11, 12: begin
						// IDLE
					end
					13: begin
						// get Y * 1/|y|
						if ( CamY_next[0][24] == 1 || CamY_next[1][24] == 1 || CamY_next[2][24] == 1 ) begin
							CamY_next[0] = CamY_next[0] >>> 2;
							CamY_next[1] = CamY_next[1] >>> 2;
							CamY_next[2] = CamY_next[2] >>> 2;
						end
						else begin
							//   2Q24         (4Q20  * 1Q24) = 4Q44
							CamY_next[0] = ( CamY[0] * (inv_sqrt_out >>> 2) + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
							CamY_next[1] = ( CamY[1] * (inv_sqrt_out >>> 2) + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
							CamY_next[2] = ( CamY[2] * (inv_sqrt_out >>> 2) + {2'b0,24'b0,1'b1,21'b0} ) >> 22;
						end
					end
					14: begin
						// send signals to neg_dot_product
						neg_dot_product_unit_x = CamY[0];
						neg_dot_product_unit_y = CamY[1];
						neg_dot_product_unit_z = CamY[2];
						neg_dot_product_x2 = eye_x;
						neg_dot_product_y2 = eye_y;
						neg_dot_product_z2 = eye_z;
					end
					15: begin
						// IDLE
					end
					16: begin
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
							product[row][col] = view[cnt][row] * projection[row][col];
							if(col == 3) begin
								// 7Q17 * 3Q21 = 9Q38 ->9Q15
								product_quant_next[row][col] = ( product[row][col] + {9'b0, 15'b0, 1'b1, 22'b0} ) >> 23;
							end
							else begin
								// 2Q24 * 3Q21 = 4Q45 -> 4Q20
								product_quant_next[row][col] = ( product[row][col] + {4'b0, 20'b0, 1'b1, 24'b0} ) >> 25;
							end
						end
					end
				end
				if (cnt >= 1 && cnt <= 4) begin
					for ( col=0; col<4; col=col+1 )begin
						if(col==3) begin
							// 9Q15 + 9Q15 + 9Q15 +9Q15 = 11Q15 -> 11Q13
							MVP_next[cnt-1][col] = ( (product_quant[0][col] + product_quant[1][col] + product_quant[2][col] + product_quant[3][col])
													+ {11'b0, 13'b0, 1'b1, 1'b0} ) >> 2;
						end
						else begin
							// 4Q20 + 4Q20 + 4Q20 + 4Q20 = 6Q20 -> 6Q18
							MVP_next[cnt-1][col] = ( (product_quant[0][col] + product_quant[1][col] + product_quant[2][col] + product_quant[3][col])
													+ {6'b0, 18'b0, 1'b1, 1'b0} ) >> 2;
						end
					end
				end
				if (cnt == 4) begin
					state_next = TRANSFORM;
					cnt_next = 0;
					MVP_ready_wire = 1;
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
				cnt = cnt + 1;

				for ( col=0; col<4; col=col+1 )begin
					for ( row=0; row<4; row=row+1 )begin
						product[row][col] = vertex[0][row] * MVP[row][col];
						if(col == 3) begin
							// 4Q20 * 7Q17 = 10Q37 ->10Q14
							product_quant_next[row][col] = ( product[row][col] + {10'b0, 14'b0, 1'b1, 22'b0} ) >> 23;
						end
						else begin
							// 4Q20 * 2Q24 = 5Q44 -> 5Q19
							product_quant_next[row][col] = ( product[row][col] + {5'b0, 19'b0, 1'b1, 24'b0} ) >> 25;
						end
					end
				end

				for ( col=0; col<4; col=col+1 )begin
					if(col==3) begin
						// 10Q14 +10Q14 +10Q14 +10Q14= 12Q14 -> 12Q12
						sum_next[col] = ( (product_quant[0][col] + product_quant[1][col] + product_quant[2][col] + product_quant[3][col])
												+ {12'b0, 12'b0, 1'b1, 1'b0} ) >> 2;
					end
					else begin
						// 5Q19 +5Q19 +5Q19 +5Q19 = 7Q19 -> 7Q17
						sum_next[col] = ( (product_quant[0][col] + product_quant[1][col] + product_quant[2][col] + product_quant[3][col])
												+ {7'b0, 17'b0, 1'b1, 1'b0} ) >> 2;
					end
				end




			end
		endcase
	end

	integer i,j;
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
				MVP[i][j] <= MVP_next[i][j];
			end
		end

		// product quant
		for (i=0; i<4; i=i+1)begin
			for (j=0; j<4; j=j+1)begin
				product_quant[i][j] <= product_quant_next[i][j];
			end
		end

		// sum
		for (i=0; i<4; i=i+1)begin
			for (j=0; j<4; j=j+1)begin
				sum[i][j] <= sum_next[i][j];
			end
		end

	end

endmodule


