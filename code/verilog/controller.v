
module controller(

	// Input signals are clean, with no delay
	// Output signals go to Flip-Flops for synchronization

	// input
	// from top
	input clk,
    input srst_n,
	input enable,
	input [19:0] face_v1,
	input [19:0] face_v2,
	input [19:0] face_v3,
	input [23:0] sram_vertex_x,
	input [23:0] sram_vertex_y,
	input [23:0] sram_vertex_z,
	input [20:0] num_of_faces,
	input [23:0] Color_v,
	
	// from vertice_shader
	input [11:0] vertice1_x_update,
	input [11:0] vertice1_y_update,
	input [20:0] vertice1_depth_update,

	input [11:0] vertice2_x_update,
	input [11:0] vertice2_y_update,
	input [20:0] vertice2_depth_update,

	input [11:0] vertice3_x_update,
	input [11:0] vertice3_y_update,
	input [20:0] vertice3_depth_update,

	input MVP_ready,
	input data_ready,
	
	//from Rasterization
	input get_next_triangle,
	
	//output
	
	// to top
	output reg [19:0] address_sram_get_face,
	output reg finish,
	output reg [19:0] address_sram_get_vertice_info;
	
	// to vertice_shader
	output reg to_shader_valid,
	// output reg [19:0] to_shader_vertice_info,
	output reg start_doing_shading,
	output reg [19:0] to_shader_vertex_x,
	output reg [19:0] to_shader_vertex_y,
	output reg [19:0] to_shader_vertex_z,
	
	// to Rasterization
	output reg [11:0] vertice1_x,
	output reg [11:0] vertice1_y,
	output reg [20:0] vertice1_depth,
	output reg [23:0] vertice1_color,

	output reg [11:0] vertice2_x,
	output reg [11:0] vertice2_y,
	output reg [20:0] vertice2_depth,
	output reg [23:0] vertice2_color,

	output reg [11:0] vertice3_x,
	output reg [11:0] vertice3_y,
	output reg [20:0] vertice3_depth,
	output reg [23:0] vertice3_color,

	output reg vertice_ready
);

// output wires

// To top
reg [19:0] address_sram_get_face_wire;
reg finish_wire;
reg [19:0] address_sram_get_vertice_info_wire;
// To vertice_shader
reg to_shader_valid_wire;
// reg [19:0] to_shader_vertice_info_wire;
reg start_doing_shading_wire;
reg [19:0] to_shader_vertex_x_wire;
reg [19:0] to_shader_vertex_y_wire;
reg [19:0] to_shader_vertex_z_wire;

// To Rasterization
reg [11:0] vertice1_x_wire;
reg [11:0] vertice1_y_wire;
reg [20:0] vertice1_depth_wire;
reg [23:0] vertice1_color_wire;

reg [11:0] vertice2_x_wire;
reg [11:0] vertice2_y_wire;
reg [20:0] vertice2_depth_wire;
reg [23:0] vertice2_color_wire;

reg [11:0] vertice3_x_wire;
reg [11:0] vertice3_y_wire;
reg [20:0] vertice3_depth_wire;
reg [23:0] vertice3_color_wire;

reg vertice_ready_wire;

// Own memories
reg [23:0] VS_v1_x, VS_v1_y, VS_v1_z;
reg [23:0] VS_v1_x_next, VS_v1_y_next, VS_v1_z_next;
reg [23:0] VS_v2_x, VS_v2_y, VS_v2_z;
reg [23:0] VS_v2_x_next, VS_v2_y_next, VS_v2_z_next;
reg [23:0] VS_v3_x, VS_v3_y, VS_v3_z;
reg [23:0] VS_v3_x_next, VS_v3_y_next, VS_v3_z_next;

reg [23:0] VS_v1_color, VS_v2_color, VS_v3_color;
reg [23:0] VS_v1_color_next, VS_v2_color_next, VS_v3_color_next;
reg [23:0] buffer_v1_color, buffer_v2_color, buffer_v3_color;
reg [23:0] buffer_v1_color_next, buffer_v2_color_next, buffer_v3_color_next;
reg [23:0] RS_v1_color, RS_v2_color, RS_v3_color;
reg [23:0] RS_v1_color_next, RS_v2_color_next, RS_v3_color_next;

// FSM
localparam IDLE = 3'd0;
localparam INIT = 3'd1;
localparam VS = 3'd2;
localparam RS = 3'd3;
localparam DONE = 3'd4;

reg [2:0] state, state_next;

// GET_FACE
reg [2:0] cnt, cnt_next;

// combinational logic
always @ * begin
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// Note that sram data comes in 3 cycles later.
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	// ***************** Default values *****************

	// Output wires

	// To top
	address_sram_get_face_wire = address_sram_get_face;
	finish_wire = 0;
	address_sram_get_vertice_info_wire = address_sram_get_vertice_info;
	// To vertice_shader
	// to_shader_valid_wire = 0;
	start_doing_shading_wire = 0;
	// to_shader_vertice_info_wire = 0;
	to_shader_vertex_x_wire = to_shader_vertex_x;
	to_shader_vertex_y_wire = to_shader_vertex_y;
	to_shader_vertex_z_wire = to_shader_vertex_z;

	// To Rasterization
	vertice1_x_wire = vertice1_x;
	vertice1_y_wire = vertice1_y;
	vertice1_depth_wire = vertice1_depth;
	// vertice1_color_wire = vertice1_color;

	vertice2_x_wire = vertice2_x;
	vertice2_y_wire = vertice2_y;
	vertice2_depth_wire = vertice2_depth;
	// vertice2_color_wire = vertice2_color;

	vertice3_x_wire = vertice3_x;
	vertice3_y_wire = vertice3_y;
	vertice3_depth_wire = vertice3_depth;
	// vertice3_color_wire = vertice3_color;

	vertice_ready_wire = 0;

	// FSM
	state_next = state;

	cnt_next = cnt;
	// ***************************************

	case(state) // synopsys parallel_case
		IDLE: begin
			// ****************************************
			// Wait for enable signal
			// 1. disable all output signals
			// 
			// if enable,
			//  1. Go to INIT state
			//	2. Set counter to 0
			// ****************************************
			address_sram_get_face_wire = 0;
			finish_wire = 0;
			address_sram_get_vertice_info_wire = 0;
			// to_shader_valid_wire = 0;
			start_doing_shading = 0;
			to_shader_vertex_x_wire = 0;
			to_shader_vertex_y_wire = 0;
			to_shader_vertex_z_wire = 0;

			vertice1_x_wire = 0;
			vertice1_y_wire = 0;
			vertice1_depth_wire = 0;

			vertice2_x_wire = 0;
			vertice2_y_wire = 0;
			vertice2_depth_wire = 0;

			vertice3_x_wire = 0;
			vertice3_y_wire = 0;
			vertice3_depth_wire = 0;

			vertice_ready_wire = 0;

			if(enable) begin
				state_next = INIT;
				cnt_next = 0;
			end
		end
		INIT: begin
			// ****************************************
			// Get Face info and send to vertice shader.
			//
			// counter 0
			// set address_sram_get_face to 0
			// counter 1 2
			//   - wait two cycles for the sram data
			// counter 3 4 5
			//   - set address_sram_get_vertice_info to face_v1, face_v2, face_v3
			// counter 6 7 8
			//   - stored the vertice info in the register

			// counter 9
			//   - stop counter
			//   - if(MVP_ready == 1):
			//         signal set start_doing_shading to 1
			//         Go to VS state
			// ****************************************

			// counter
			cnt_next = cnt + 1;
			case(cnt)
				0: begin
					// set address_sram_get_face to 0
					address_sram_get_face_wire = 0;
				end
				1, 2: begin
					// wait for sram data
				end
				3: begin
					// send face data to vertice_shader
					address_sram_get_vertice_info_wire = face_v1;
				end
				4: begin
					address_sram_get_vertice_info_wire = face_v2;
				end
				5: begin
					address_sram_get_vertice_info_wire = face_v3;
				end
				6: begin
					// store the vertice info in the register
					VS_v1_x_next = sram_vertex_x;
					VS_v1_y_next = sram_vertex_y;
					VS_v1_z_next = sram_vertex_z;
					VS_v1_color_next = Color_v;
				end
				7: begin
					VS_v2_x_next = sram_vertex_x;
					VS_v2_y_next = sram_vertex_y;
					VS_v2_z_next = sram_vertex_z;
					VS_v2_color_next = Color_v;
				end
				8: begin
					VS_v3_x_next = sram_vertex_x;
					VS_v3_y_next = sram_vertex_y;
					VS_v3_z_next = sram_vertex_z;
					VS_v3_color_next = Color_v;
				end
				9: begin
					if (MVP_ready) begin
						start_doing_shading_wire = 1;
						state_next = VS;
						cnt_next = 0;
					end
					else begin
						cnt_next = 9;
					end
				end
			endcase
		end
		VS: begin
			// ****************************************
			// counter 0 1 2
			//    - set to_shader_vertex_x, to_shader_vertex_y, to_shader_vertex_z
			//    - store color from VS to buffer
			//    - send new face info to top
			// counter 3 4 5
			//   - set address_sram_get_vertice_info to face_v1, face_v2, face_v3
			// counter 6 7 8
			//   - stored the vertice info in the register
			// counter 9
			//   - stop counter
			//   - if(data_ready == 1):
			//		 signal set vertice_ready_wire to 1
			//       update x, y, z, color
			//       Go to RS state
			// ****************************************
			cnt_next = cnt + 1;
			case(cnt)
				0: begin
					to_shader_vertex_x_wire = VS_v1_x;
					to_shader_vertex_y_wire = VS_v1_y;
					to_shader_vertex_z_wire = VS_v1_z;
					buffer_v1_color_next = VS_v1_color;

					address_sram_get_face_wire = address_sram_get_face + 1;
				end
				1: begin
					to_shader_vertex_x_wire = VS_v2_x;
					to_shader_vertex_y_wire = VS_v2_y;
					to_shader_vertex_z_wire = VS_v2_z;
					buffer_v2_color_next = VS_v2_color;
				end
				2: begin
					to_shader_vertex_x_wire = VS_v3_x;
					to_shader_vertex_y_wire = VS_v3_y;
					to_shader_vertex_z_wire = VS_v3_z;
					buffer_v3_color_next = VS_v3_color;
				end
				3: begin
					address_sram_get_vertice_info_wire = face_v1;
				end
				4: begin
					address_sram_get_vertice_info_wire = face_v2;
				end
				5: begin
					address_sram_get_vertice_info_wire = face_v3;
				end
				6: begin
					// store the vertice info in the register
					VS_v1_x_next = sram_vertex_x;
					VS_v1_y_next = sram_vertex_y;
					VS_v1_z_next = sram_vertex_z;
					VS_v1_color_next = Color_v;
				end
				7: begin
					VS_v2_x_next = sram_vertex_x;
					VS_v2_y_next = sram_vertex_y;
					VS_v2_z_next = sram_vertex_z;
					VS_v2_color_next = Color_v;
				end
				8: begin
					VS_v3_x_next = sram_vertex_x;
					VS_v3_y_next = sram_vertex_y;
					VS_v3_z_next = sram_vertex_z;
					VS_v3_color_next = Color_v;
				end
				9: begin
					vertice1_x_wire = vertice1_x_update;
					vertice1_y_wire = vertice1_y_update;
					vertice1_depth_wire = vertice1_depth_update;
					vertice1_color_wire = buffer_v1_color;

					vertice2_x_wire = vertice2_x_update;
					vertice2_y_wire = vertice2_y_update;
					vertice2_depth_wire = vertice2_depth_update;
					vertice2_color_wire = buffer_v2_color;

					vertice3_x_wire = vertice3_x_update;
					vertice3_y_wire = vertice3_y_update;
					vertice3_depth_wire = vertice3_depth_update;
					vertice3_color_wire = buffer_v3_color;
					if (data_ready) begin
						vertice_ready_wire = 1;
						state_next = RS;
						cnt_next = 0;
					end
					else begin
						vertice_ready_wire = 0;
						state_next = VS;
						cnt_next = 9;
					end
				end
			endcase
		end
		RS: begin
			// ****************************************
			// if (get_next_triangle == 1):
			//    if address_sram_get_face > number of faces:
			//        Go to FINISH state
			//    else:
			//        signal set start_doing_shading to 1
			//        Go to VS state
			if(get_next_triangle) begin
				if(address_sram_get_face > num_of_faces) begin
					state_next = FINISH;
				end
				else begin
					start_doing_shading_wire = 1;
					state_next = VS;
				end
			end
		end



		VS: begin
			// ****************************************
			// if rasterizor.get_next_triangle:
			//   -> Rasterizor request for the next input,
			//      a. if address_sram_get_face + 1 == number of faces:
			//           Go to FINISH state
			//      b. else:
			//          b1. if shader.data_ready == 1:
			//                1. Update the register for rasterization
			//                2. Set vertice_ready_wire to 1
			//                3. Get the next face info
			//                   - address_sram_get_face += 1
			//                   - Set GET_FACE counter to 0
			//                   - Go to GET_FACE
			//          b2. else:
			//              KEEP WAITING
			// else:
			//    KEEP WAITING
			// ****************************************

			if( get_next_triangle ) begin
				if( address_sram_get_face + 1 == num_of_faces ) begin
					state_next = FINISH;
				end
				else begin
					if( data_ready ) begin
						// Update the register for rasterization
						vertice1_x_wire = vertice1_x_update;
						vertice1_y_wire = vertice1_y_update;
						vertice1_depth_wire = vertice1_depth_update;
						vertice1_color_wire = vertice1_color_update;

						vertice2_x_wire = vertice2_x_update;
						vertice2_y_wire = vertice2_y_update;
						vertice2_depth_wire = vertice2_depth_update;
						vertice2_color_wire = vertice2_color_update;

						vertice3_x_wire = vertice3_x_update;
						vertice3_y_wire = vertice3_y_update;
						vertice3_depth_wire = vertice3_depth_update;
						vertice3_color_wire = vertice3_color_update;

						vertice_ready_wire = 1;

						// Get the next face info
						address_sram_get_face_wire = address_sram_get_face + 1;
						cnt_next = 0;
						state_next = GET_FACE;
					end
				end
			end
		end
		FINISH: begin
			// ****************************************
			// Set finish signal to 1
			// ****************************************
			finish_wire = 1;
		end
	endcase
end

// sequential logic
always @ ( posedge clk) begin

	// Output wires
	// To top
	address_sram_get_face <= address_sram_get_face_wire;
	finish <= finish_wire;
	address_sram_get_vertice_info <= address_sram_get_vertice_info_wire;
	// To vertice_shader
	to_shader_valid <= to_shader_valid_wire;
	// to_shader_vertice_info <= to_shader_vertice_info_wire;
	start_doing_shading <= start_doing_shading_wire;
	to_shader_vertex_x <= to_shader_vertex_x_wire;
	to_shader_vertex_y <= to_shader_vertex_y_wire;
	to_shader_vertex_z <= to_shader_vertex_z_wire;

	
	// To Rasterization
	vertice1_x <= vertice1_x_wire;
	vertice1_y <= vertice1_y_wire;
	vertice1_depth <= vertice1_depth_wire;


	vertice2_x <= vertice2_x_wire;
	vertice2_y <= vertice2_y_wire;
	vertice2_depth <= vertice2_depth_wire;


	vertice3_x <= vertice3_x_wire;
	vertice3_y <= vertice3_y_wire;
	vertice3_depth <= vertice3_depth_wire;


	vertice_ready <= vertice_ready_wire;

	// Own memories
	VS_v1_x <= VS_v1_x_next;
	VS_v1_y <= VS_v1_y_next;
	VS_v1_z <= VS_v1_z_next;
	VS_v2_x <= VS_v2_x_next;
	VS_v2_y <= VS_v2_y_next;
	VS_v2_z <= VS_v2_z_next;
	VS_v3_x <= VS_v3_x_next;
	VS_v3_y <= VS_v3_y_next;
	VS_v3_z <= VS_v3_z_next;

	VS_v1_color <= VS_v1_color_next;
	VS_v2_color <= VS_v2_color_next;
	VS_v3_color <= VS_v3_color_next;
	buffer_v1_color <= buffer_v1_color_next;
	buffer_v2_color <= buffer_v2_color_next;
	buffer_v3_color <= buffer_v3_color_next;
	RS_v1_color <= RS_v1_color_next;
	RS_v2_color <= RS_v2_color_next;
	RS_v3_color <= RS_v3_color_next;

	// FSM
	if( ~srst_n ) begin
		state <= IDLE;
	end
	else begin
		state <= state_next;
	end

	// GET_FACE
	cnt <= cnt_next;
end

endmodule