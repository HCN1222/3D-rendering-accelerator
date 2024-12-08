
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
	output reg [11:0] vertice1_x_use,
	output reg [11:0] vertice1_y_use,
	output reg [20:0] vertice1_depth_use,
	output reg [23:0] vertice1_color_use,

	output reg [11:0] vertice2_x_use,
	output reg [11:0] vertice2_y_use,
	output reg [20:0] vertice2_depth_use,
	output reg [23:0] vertice2_color_use,

	output reg [11:0] vertice3_x_use,
	output reg [11:0] vertice3_y_use,
	output reg [20:0] vertice3_depth_use,
	output reg [23:0] vertice3_color_use,

	output reg data_ready_use
);

// output wires

// To top
reg [19:0] address_sram_get_face_wire;
reg finish_wire;
// To vertice_shader
reg to_shader_valid_wire;
reg [19:0] to_shader_vertice_info_wire;
// To Rasterization
reg [11:0] vertice1_x_use_wire;
reg [11:0] vertice1_y_use_wire;
reg [20:0] vertice1_depth_use_wire;
reg [23:0] vertice1_color_use_wire;

reg [11:0] vertice2_x_use_wire;
reg [11:0] vertice2_y_use_wire;
reg [20:0] vertice2_depth_use_wire;
reg [23:0] vertice2_color_use_wire;

reg [11:0] vertice3_x_use_wire;
reg [11:0] vertice3_y_use_wire;
reg [20:0] vertice3_depth_use_wire;
reg [23:0] vertice3_color_use_wire;

reg data_ready_use_wire;

// FSM
localparam IDLE = 0;
localparam GET_FACE = 1;
localparam WAITING = 2;
localparam FINISH = 3;

reg [1:0] state, state_next;

// combinational logic
always @ * begin
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// Note that sram data comes in 3 cycles later.
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	state_next = state;
	case(state) // synopsys parallel_case
		IDLE: begin
			// ****************************************
			// Wait for enable signal
			// 1. disable all output signals
			// 2. set address_sram_get_face to 0 to get the first face
			// 
			// if enable,
			//     Go to GET_FACE state
			// ****************************************
			state_next = (enable) ? GET_FACE : IDLE;
		end
		GET_FACE: begin
			// ****************************************
			// counter 0 1
			// 1. wait two cycles for the sram data
			// counter 2 3 4
			// 2. store the face data and send them to vertice_shader
			// counter 5
			// 3. Go to WAITING state
			state_next = WAITING;
		end
		WAITING: begin
			state_next = (get_next_triangle) ? GET_FACE : WAITING;
		end
		FINISH: begin
			state_next = IDLE;
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
	vertice1_x_use <= vertice1_x_use_wire;
	vertice1_y_use <= vertice1_y_use_wire;
	vertice1_depth_use <= vertice1_depth_use_wire;
	vertice1_color_use <= vertice1_color_use_wire;

	vertice2_x_use <= vertice2_x_use_wire;
	vertice2_y_use <= vertice2_y_use_wire;
	vertice2_depth_use <= vertice2_depth_use_wire;
	vertice2_color_use <= vertice2_color_use_wire;

	vertice3_x_use <= vertice3_x_use_wire;
	vertice3_y_use <= vertice3_y_use_wire;
	vertice3_depth_use <= vertice3_depth_use_wire;
	vertice3_color_use <= vertice3_color_use_wire;

	data_ready_use <= data_ready_use_wire;

	// FSM
	if( ~srst_n ) begin
		state <= IDLE;
	end
	else begin
		state <= state_next;
	end
end

endmodule