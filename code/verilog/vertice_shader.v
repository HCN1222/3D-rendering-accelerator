module vertice_shader(
	//from top
	input clk,
	input srst_n,
	input enable,
	input [23:0]  eye_x,
	input [23:0] eye_y,
	input [23:0] eye_z,
	input [23:0] center_x,
	input [23:0] center_y,
	input [23:0] center_z,
	input [23:0] up_x,
	input [23:0] up_y,
	input [23:0] up_z,
	input [23:0] vertice_x,
	input [23:0] vertice_y,
	input [23:0] vertice_z,
	input [23:0] Color_v,
	
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
	inv_sqrt inv_sqrt(
		/*input*/ .clk(clk),
		.x( ), .y( ), .z( ),
		/*output*/ .out( )
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

	// get camera Z
	reg []

	always @ (*) begin
		state_next = state;
		cnt_next = cnt;
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
					
					0: begin
					
					end
				endcase
			end
			
		endcase
	end

	always @ (posedge clk) begin
		if (~srst_n) begin
			state <= IDLE;
		end
		else begin
			state <= state_next;
		end
		
		cnt <= cnt_next;
	end

endmodule


