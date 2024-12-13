module vertice_shader(
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
	input [23:0] vertice_x, // 4Q20
	input [23:0] vertice_y, // 4Q20
	input [23:0] vertice_z, // 4Q20
	input [23:0] Color_v,   // 4Q20
	
	//from controller
	input controller_signal_get,
	input [19:0] controller_which_vertice,
	input start_doing_shading,
	
	//output
	
	//to controllor
	output [20:0] vertice1_depth_update,
	output [20:0] vertice2_depth_update,
	output [20:0] vertice3_depth_update,
	output [23:0] vertice1_color_update,
	output [23:0] vertice2_color_update,
	output [23:0] vertice3_color_update,
	output [11:0] screen_x1_update,
	output [11:0] screen_y1_update,
	output [11:0] screen_x2_update,
	output [11:0] screen_y2_update,
	output [11:0] screen_x3_update,
	output [11:0] screen_y3_update,
	output MVP_ready,
	output data_ready,
	
	//to top
	output [19:0] address_sram_get_vertice_info
	
);

	// ********** Summary ***********
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

	// Camera coordinates
	reg [23:0] CamZ [0:2]; //4Q20
	reg [23:0] CamZ_next [0:2]; //4Q20


	integer i;
	always @ (*) begin
		state_next = state;
		cnt_next = cnt;

		// Camera coordinates
		for (i=0; i<3; i=i+1) begin
			CamZ_next[i] = CamZ[i];
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
						// 4Q20         4Q20         1Q24
						CamZ_next[0] = ( CamZ[0] * inv_sqrt_out + {15,b0,1'b1,23'b0} ) >> 24;
						CamZ_next[1] = ( CamZ[1] * inv_sqrt_out + {15,b0,1'b1,23'b0} ) >> 24;
						CamZ_next[2] = ( CamZ[2] * inv_sqrt_out + {15,b0,1'b1,23'b0} ) >> 24;
					end
				endcase
			end
			
		endcase
	end

	integer j;
	always @ (posedge clk) begin
		if (~srst_n) begin
			state <= IDLE;
		end
		else begin
			state <= state_next;
		end
		
		// counter
		cnt <= cnt_next;
		// Camera axes
		for (j=0; j<3; j=j+1) begin
			CamZ[j] <= CamZ_next[j];
		end
	end

endmodule


