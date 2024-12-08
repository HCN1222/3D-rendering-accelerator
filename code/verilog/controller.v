
module controller(

	// Input signals are clean, with no delay
	// Output signals go to Flip-Flops for synchronization

	// input
	// from top
	input clk,
    input srst_n
	input enable,
	input [19:0] face_v1,
	input [19:0] face_v2,
	input [19:0] face_v3,
	input [20:0] num_of_faces,
	
	// from vertice_shader
	input [11:0] vertice1_x_update,
	input [11:0] vertice1_y_update,
	input [20:0] vertice1_depth_update,
	input [23:0] vertice1_color_update,

	input [11:0] vertice2_x_update,
	input [11:0] vertice2_y_update,
	input [20:0] vertice2_depth_update,
	input [23:0] vertice2_color_update,

	input [11:0] vertice3_x_update,
	input [11:0] vertice3_y_update,
	input [20:0] vertice3_depth_update,
	input [23:0] vertice3_color_update,

	input data_ready,
	
	//from Rasterization
	input get_next_triangle,
	
	//output
	
	// to top
	output reg [19:0] address_sram_get_face,
	output reg finish,
	
	// to vertice_shader
	output reg to_shader_valid,
	output reg [19:0] to_shader_vertice_info,
	// comment due to redundancy
	// output start_doing_shading,
	
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
// To vertice_shader
reg to_shader_valid_wire;
reg [19:0] to_shader_vertice_info_wire;
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

// FSM
localparam IDLE = 0;
localparam GET_FACE = 1;
localparam WAITING = 2;
localparam FINISH = 3;

reg [1:0] state, state_next;

// GET_FACE
reg [2:0] get_face_cnt, get_face_cnt_next;

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
	// To vertice_shader
	to_shader_valid_wire = 0;
	to_shader_vertice_info_wire = 0;
	// To Rasterization
	vertice1_x_wire = vertice1_x;
	vertice1_y_wire = vertice1_y;
	vertice1_depth_wire = vertice1_depth;
	vertice1_color_wire = vertice1_color;

	vertice2_x_wire = vertice2_x;
	vertice2_y_wire = vertice2_y;
	vertice2_depth_wire = vertice2_depth;
	vertice2_color_wire = vertice2_color;

	vertice3_x_wire = vertice3_x;
	vertice3_y_wire = vertice3_y;
	vertice3_depth_wire = vertice3_depth;
	vertice3_color_wire = vertice3_color;

	vertice_ready_wire = 0;

	// FSM
	state_next = state;

	// GET_FACE
	get_face_cnt_next = get_face_cnt;
	// ***************************************

	case(state) // synopsys parallel_case
		IDLE: begin
			// ****************************************
			// Wait for enable signal
			// 1. disable all output signals
			// 
			// if enable,
			//  1. Go to GET_FACE state
			//	2. Set GET_FACE counter to 0
			//  3. set address_sram_get_face_wire to 0 to get the first face
			// ****************************************
			finish_wire = 0;
			to_shader_valid_wire = 0;
			vertice_ready_wire = 0;

			if(enable) begin
				state_next = GET_FACE;
				get_face_cnt_next = 0;
				address_sram_get_face_wire = 0;
			end
		end
		GET_FACE: begin
			// ****************************************
			// Get Face info and send to vertice shader.
			//
			// counter 0 1
			//   - wait two cycles for the sram data
			// counter 2 3 4
			//   - store the face data and send them to vertice_shader
			// counter 5
			//   - Go to WAITING state
			// ****************************************

			// counter
			get_face_cnt_next = get_face_cnt + 1;

			case(counter) // synopsys parallel_case
				0, 1: begin
					// wait for sram data
				end
				2: begin
					// send face data to vertice_shader
					to_shader_valid_wire = 1;
					to_shader_vertice_info_wire = face_v1;
				end
				3: begin
					// send face data to vertice_shader
					to_shader_valid_wire = 1;
					to_shader_vertice_info_wire = face_v2;
				end
				4: begin
					// send face data to vertice_shader
					to_shader_valid_wire = 1;
					to_shader_vertice_info_wire = face_v3;
				end
				5: begin
					// Go to WAITING state
					state_next = WAITING;
				end
			endcase
		end
		WAITING: begin
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
						get_face_cnt_next = 0;
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
	
	address_sram_get_face <= address_sram_get_face_wire;
	finish <= finish_wire;
	to_shader_valid <= to_shader_valid_wire;
	to_shader_vertice_info <= to_shader_vertice_info_wire;
	// To Rasterization
	vertice1_x <= vertice1_x_wire;
	vertice1_y <= vertice1_y_wire;
	vertice1_depth <= vertice1_depth_wire;
	vertice1_color <= vertice1_color_wire;

	vertice2_x <= vertice2_x_wire;
	vertice2_y <= vertice2_y_wire;
	vertice2_depth <= vertice2_depth_wire;
	vertice2_color <= vertice2_color_wire;

	vertice3_x <= vertice3_x_wire;
	vertice3_y <= vertice3_y_wire;
	vertice3_depth <= vertice3_depth_wire;
	vertice3_color <= vertice3_color_wire;

	vertice_ready <= vertice_ready_wire;

	// FSM
	if( ~srst_n ) begin
		state <= IDLE;
	end
	else begin
		state <= state_next;
	end

	// GET_FACE
	get_face_cnt <= get_face_cnt_next;
end

endmodule