module GetColorDepth(

    input clk,

    input [11:0] screen_x1,
	input [11:0] screen_y1,
	input [11:0] screen_x2,
	input [11:0] screen_y2,
	input [11:0] screen_x3,
	input [11:0] screen_y3,

    input [20:0] vertice1_depth,
	input [20:0] vertice2_depth,
	input [20:0] vertice3_depth,
	
	input [23:0] vertice1_color,
	input [23:0] vertice2_color,
	input [23:0] vertice3_color,
	
	input [11:0] current_x,
    input [11:0] current_y,
	
	output reg [23:0] current_Color,
	output reg [20:0] current_depth,
	output reg not_draw,
	output reg in_triangle

);

// 1st pipeline
reg signed [11:0] screen_x1_s;
reg signed [11:0] screen_y1_s;
reg signed [11:0] screen_x2_s;
reg signed [11:0] screen_y2_s;
reg signed [11:0] screen_x3_s;
reg signed [11:0] screen_y3_s;
reg signed [11:0] current_x_s;
reg signed [11:0] current_y_s;

reg signed [24:0] temp0;
reg signed [24:0] temp1;
reg signed [24:0] temp2;
reg signed [24:0] temp3;
reg signed [24:0] temp4;
reg signed [24:0] temp5;
reg signed [24:0] temp6;
reg signed [24:0] temp7;
reg signed [24:0] temp8;
reg signed [24:0] temp9;
reg signed [24:0] temp10;
reg signed [24:0] temp11;

reg signed [24:0] next_temp0;
reg signed [24:0] next_temp1;
reg signed [24:0] next_temp2;
reg signed [24:0] next_temp3;
reg signed [24:0] next_temp4;
reg signed [24:0] next_temp5;
reg signed [24:0] next_temp6;
reg signed [24:0] next_temp7;
reg signed [24:0] next_temp8;
reg signed [24:0] next_temp9;
reg signed [24:0] next_temp10;
reg signed [24:0] next_temp11;

reg next_detect_pipe2;
reg detect_pipe2;
reg condition1;
reg condition2;
reg condition3;

reg next_overlap_v1_pipe2;
reg	next_overlap_v2_pipe2;
reg	next_overlap_v3_pipe2;

reg overlap_v1_pipe2;
reg	overlap_v2_pipe2;
reg	overlap_v3_pipe2;

reg signed [20:0] vertice1_depth_pipe2;
reg signed [20:0] vertice2_depth_pipe2;
reg signed [20:0] vertice3_depth_pipe2;
	
reg [23:0] vertice1_color_pipe2;
reg [23:0] vertice2_color_pipe2;
reg [23:0] vertice3_color_pipe2;

// second pipeline
reg signed [26:0] tempA1;
reg signed [26:0] tempA2;
reg signed [26:0] tempA3;
reg signed [26:0] tempAt;

reg signed [26:0] A1;
reg signed [26:0] A2;
reg signed [26:0] A3;
reg signed [26:0] At;

reg signed [26:0] next_A1;
reg signed [26:0] next_A2;
reg signed [26:0] next_A3;
reg signed [26:0] next_At;

//reg next_detect_pipe3;
reg detect_pipe3;

//reg next_detect_pipe4;
reg detect_pipe4;

//reg next_detect_pipe5;
reg detect_pipe5;

//reg next_detect_pipe6;
reg detect_pipe6;

//reg next_detect_pipe7;
reg detect_pipe7;

//reg next_detect_pipe8;
reg detect_pipe8;

reg detect_pipe9;

reg signed [20:0] vertice1_depth_pipe3;
reg signed [20:0] vertice2_depth_pipe3;
reg signed [20:0] vertice3_depth_pipe3;
	
reg [23:0] vertice1_color_pipe3;
reg [23:0] vertice2_color_pipe3;
reg [23:0] vertice3_color_pipe3;

reg signed [20:0] vertice1_depth_pipe4;
reg signed [20:0] vertice2_depth_pipe4;
reg signed [20:0] vertice3_depth_pipe4;
	
reg [23:0] vertice1_color_pipe4;
reg [23:0] vertice2_color_pipe4;
reg [23:0] vertice3_color_pipe4;

reg signed [20:0] vertice1_depth_pipe5;
reg signed [20:0] vertice2_depth_pipe5;
reg signed [20:0] vertice3_depth_pipe5;
	
reg [23:0] vertice1_color_pipe5;
reg [23:0] vertice2_color_pipe5;
reg [23:0] vertice3_color_pipe5;

reg signed [20:0] vertice1_depth_pipe6;
reg signed [20:0] vertice2_depth_pipe6;
reg signed [20:0] vertice3_depth_pipe6;
	
reg [23:0] vertice1_color_pipe6;
reg [23:0] vertice2_color_pipe6;
reg [23:0] vertice3_color_pipe6;

reg signed [20:0] vertice1_depth_pipe7;
reg signed [20:0] vertice2_depth_pipe7;
reg signed [20:0] vertice3_depth_pipe7;
	
reg [23:0] vertice1_color_pipe7;
reg [23:0] vertice2_color_pipe7;
reg [23:0] vertice3_color_pipe7;

reg signed [20:0] vertice1_depth_pipe8;
reg signed [20:0] vertice2_depth_pipe8;
reg signed [20:0] vertice3_depth_pipe8;
	
reg [23:0] vertice1_color_pipe8;
reg [23:0] vertice2_color_pipe8;
reg [23:0] vertice3_color_pipe8;

reg signed [20:0] vertice1_depth_pipe9;
reg signed [20:0] vertice2_depth_pipe9;
reg signed [20:0] vertice3_depth_pipe9;

reg [23:0] vertice1_color_pipe9;
reg [23:0] vertice2_color_pipe9;
reg [23:0] vertice3_color_pipe9;

reg overlap_v1_pipe3;
reg	overlap_v2_pipe3;
reg	overlap_v3_pipe3;

reg overlap_v1_pipe4;
reg	overlap_v2_pipe4;
reg	overlap_v3_pipe4;

reg overlap_v1_pipe5;
reg	overlap_v2_pipe5;
reg	overlap_v3_pipe5;

reg overlap_v1_pipe6;
reg	overlap_v2_pipe6;
reg	overlap_v3_pipe6;

reg overlap_v1_pipe7;
reg	overlap_v2_pipe7;
reg	overlap_v3_pipe7;

reg overlap_v1_pipe8;
reg	overlap_v2_pipe8;
reg	overlap_v3_pipe8;

reg overlap_v1_pipe9;
reg	overlap_v2_pipe9;
reg	overlap_v3_pipe9;

wire in_triangle_pipe4;

reg in_triangle_pipe5;

reg in_triangle_pipe6;

reg in_triangle_pipe7;

reg in_triangle_pipe8;

reg in_triangle_pipe9;

reg next_in_triangle;


wire signed [20:0] L1; //1Q20
wire signed [20:0] L2; //1Q20
wire signed [20:0] L3; //1Q20


reg [28:0] temp_p1_color_R;
reg [28:0] temp_p2_color_R;
reg [28:0] temp_p3_color_R;

reg [28:0] temp_p1_color_G;
reg [28:0] temp_p2_color_G;
reg [28:0] temp_p3_color_G;

reg [28:0] temp_p1_color_B;
reg [28:0] temp_p2_color_B;
reg [28:0] temp_p3_color_B;

reg signed [41:0] temp_p1_depth;
reg signed [41:0] temp_p2_depth;
reg signed [41:0] temp_p3_depth;

reg [28:0] temp_p1_color_R_q;
reg [28:0] temp_p2_color_R_q;
reg [28:0] temp_p3_color_R_q;

reg [28:0] temp_p1_color_G_q;
reg [28:0] temp_p2_color_G_q;
reg [28:0] temp_p3_color_G_q;

reg [28:0] temp_p1_color_B_q;
reg [28:0] temp_p2_color_B_q;
reg [28:0] temp_p3_color_B_q;

reg signed [41:0] temp_p1_depth_q;
reg signed [41:0] temp_p2_depth_q;
reg signed [41:0] temp_p3_depth_q;


reg [11:0] next_p1_color_R;  // f1 = 4
reg [11:0] next_p2_color_R;  // f1 = 4
reg [11:0] next_p3_color_R;  // fl = 4

reg [11:0] next_p1_color_G;  
reg [11:0] next_p2_color_G;  
reg [11:0] next_p3_color_G;  

reg [11:0] next_p1_color_B;  
reg [11:0] next_p2_color_B;  
reg [11:0] next_p3_color_B;  

reg signed [25:0] next_p1_depth;
reg signed [25:0] next_p2_depth;
reg signed [25:0] next_p3_depth;

reg [11:0] p1_color_R;  // fl = 4
reg [11:0] p2_color_R;
reg [11:0] p3_color_R;

reg [11:0] p1_color_G;
reg [11:0] p2_color_G;
reg [11:0] p3_color_G;

reg [11:0] p1_color_B;
reg [11:0] p2_color_B;
reg [11:0] p3_color_B;

reg signed [25:0] p1_depth;
reg signed [25:0] p2_depth;
reg signed [25:0] p3_depth;

reg [11:0] temp_current_color_R;
reg [11:0] temp_current_color_G;
reg [11:0] temp_current_color_B;

reg signed [25:0] temp_current_depth;

reg [11:0] temp_current_color_R_q;
reg [11:0] temp_current_color_G_q;
reg [11:0] temp_current_color_B_q;

reg signed [25:0] temp_current_depth_q;

reg [23:0] next_current_Color;
reg signed [20:0] next_current_depth;

reg [7:0] vertice1_color_R;
reg [7:0] vertice1_color_G;
reg [7:0] vertice1_color_B;

reg [7:0] vertice2_color_R;
reg [7:0] vertice2_color_G;
reg [7:0] vertice2_color_B;

reg [7:0] vertice3_color_R;
reg [7:0] vertice3_color_G;
reg [7:0] vertice3_color_B;

reg next_not_draw;

/*
// 3th pipeline
reg signed [27:0] A1_1_1;
reg signed [27:0] A1_2_1;
reg signed [27:0] A1_3_1;
reg signed [27:0] A1_4_1;

reg signed [27:0] next_A1pipe2;
reg signed [27:0] A1pipe2;
reg signed [20:0] next_L1pipe2;
reg signed [20:0] L1pip2;
reg signed [27:0] next_Atpipe2;
reg signed [27:0] Atpipe2;


// 4th pipeline
reg signed [27:0] A1_1_2;
reg signed [27:0] A1_2_2;
reg signed [27:0] A1_3_2;
reg signed [27:0] A1_4_2;

reg signed [27:0] next_A1pipe3;
reg signed [27:0] A1pipe3;
reg signed [20:0] next_L1pipe3;
reg signed [20:0] L1pip3;
reg signed [27:0] next_Atpipe3;
reg signed [27:0] Atpipe3;

// 5th pipeline
reg signed [27:0] A1_1_3;
reg signed [27:0] A1_2_3;
reg signed [27:0] A1_3_3;
reg signed [27:0] A1_4_3;

reg signed [27:0] next_A1pipe4;
reg signed [27:0] A1pipe4;
reg signed [20:0] next_L1pipe4;
reg signed [20:0] L1pip4;
reg signed [27:0] next_Atpipe4;
reg signed [27:0] Atpipe4;

// 6th pipeline
reg signed [27:0] A1_1_4;
reg signed [27:0] A1_2_4;
reg signed [27:0] A1_3_4;
reg signed [27:0] A1_4_4;

reg signed [27:0] next_A1pipe5;
reg signed [27:0] A1pipe5;
reg signed [20:0] next_L1pipe5;
reg signed [20:0] L1pip5;
reg signed [27:0] next_Atpipe5;
reg signed [27:0] Atpipe5;

// 7th pipeline
reg signed [27:0] A1_1_5;
reg signed [27:0] A1_2_5;
reg signed [27:0] A1_3_5;
reg signed [27:0] A1_4_5;

reg signed [20:0] next_L1;
reg signed [20:0] L1;
*/


always@* begin

    // 1st pipline

    condition1 = ( (screen_x1 == screen_x2) && (screen_y1 == screen_y2) );
	condition2 = ( (screen_x1 == screen_x3) && (screen_y1 == screen_y3) );
	condition3 = ( (screen_x2 == screen_x3) && (screen_y2 == screen_y3) );
	
	if(condition1 || condition2 || condition3)
	    next_detect_pipe2 = 1;
	else
	    next_detect_pipe2 = 0;
		
	next_overlap_v1_pipe2 = ( (current_x == screen_x1) && (current_y == screen_y1) );
	next_overlap_v2_pipe2 = ( (current_x == screen_x2) && (current_y == screen_y2) );
	next_overlap_v3_pipe2 = ( (current_x == screen_x3) && (current_y == screen_y3) );
	
	screen_x1_s = screen_x1;
	screen_y1_s = screen_y1;
	screen_x2_s = screen_x2;
	screen_y2_s = screen_y2;
	screen_x3_s = screen_x3;
	screen_y3_s = screen_y3;
	current_x_s = current_x;
	current_y_s = current_y;
    
    next_temp0 = current_x_s*(screen_y2_s - screen_y3_s);
	next_temp1 = screen_x2_s*(screen_y3_s - current_y_s);
	next_temp2 = screen_x3_s*(current_y_s - screen_y2_s);
	next_temp3 = screen_x1_s*(current_y_s - screen_y3_s);
	next_temp4 = current_x_s*(screen_y3_s - screen_y1_s);
	next_temp5 = screen_x3_s*(screen_y1_s - current_y_s);
	next_temp6 = screen_x1_s*(screen_y2_s - current_y_s);
	next_temp7 = screen_x2_s*(current_y_s - screen_y1_s);
	next_temp8 = current_x_s*(screen_y1_s - screen_y2_s);
	next_temp9 = screen_x1_s*(screen_y2_s - screen_y3_s);
	next_temp10 = screen_x2_s*(screen_y3_s - screen_y1_s);
	next_temp11 = screen_x3_s*(screen_y1_s - screen_y2_s);
	
	//2nd pipeline
	
	tempA1 = temp0 + temp1 + temp2;
    tempA2 = temp3 + temp4 + temp5;
	tempA3 = temp6 + temp7 + temp8;
	tempAt = temp9 + temp10 + temp11;
	
	if(tempA1 < 0)
	    next_A1 = ~tempA1 + 1;
	else
	    next_A1 = tempA1;
		
	if(tempA2 < 0)
	    next_A2 = ~tempA2 + 1;
	else
	    next_A2 = tempA2;
		
	if(tempA3 < 0)
	    next_A3 = ~tempA3 + 1;
	else
	    next_A3 = tempA3;
		
	if(tempAt < 0)
	    next_At = ~tempAt + 1;
	else
	    next_At = tempAt;

end


always@* begin

    // 8th pipeline
	vertice1_color_R = vertice1_color_pipe8[23:16];
	vertice1_color_G = vertice1_color_pipe8[15:8];
	vertice1_color_B = vertice1_color_pipe8[7:0];

	vertice2_color_R = vertice2_color_pipe8[23:16];
	vertice2_color_G = vertice2_color_pipe8[15:8];
	vertice2_color_B = vertice2_color_pipe8[7:0];

	vertice3_color_R = vertice3_color_pipe8[23:16];
	vertice3_color_G = vertice3_color_pipe8[15:8];
	vertice3_color_B = vertice3_color_pipe8[7:0];
	
	temp_p1_color_R = L1*vertice1_color_R;
	temp_p2_color_R = L2*vertice2_color_R;
    temp_p3_color_R = L3*vertice3_color_R;
	
	temp_p1_color_G = L1*vertice1_color_G;
	temp_p2_color_G = L2*vertice2_color_G;
	temp_p3_color_G = L3*vertice3_color_G;
	
	temp_p1_color_B = L1*vertice1_color_B;
	temp_p2_color_B = L2*vertice2_color_B;
	temp_p3_color_B = L3*vertice3_color_B;
	
	temp_p1_depth = L1*vertice1_depth_pipe8;
	temp_p2_depth = L2*vertice2_depth_pipe8;
	temp_p3_depth = L3*vertice3_depth_pipe8;
	
	temp_p1_color_R_q = (temp_p1_color_R + {13'd0,1'd1,15'd0}) >>> 16;
	temp_p2_color_R_q = (temp_p2_color_R + {13'd0,1'd1,15'd0}) >>> 16;
	temp_p3_color_R_q = (temp_p3_color_R + {13'd0,1'd1,15'd0}) >>> 16;
	
	temp_p1_color_G_q = (temp_p1_color_G + {13'd0,1'd1,15'd0}) >>> 16;
	temp_p2_color_G_q = (temp_p2_color_G + {13'd0,1'd1,15'd0}) >>> 16;
	temp_p3_color_G_q = (temp_p3_color_G + {13'd0,1'd1,15'd0}) >>> 16;
	
	temp_p1_color_B_q = (temp_p1_color_B + {13'd0,1'd1,15'd0}) >>> 16;
	temp_p2_color_B_q = (temp_p2_color_B + {13'd0,1'd1,15'd0}) >>> 16;
	temp_p3_color_B_q = (temp_p3_color_B + {13'd0,1'd1,15'd0}) >>> 16;
	
	temp_p1_depth_q = (temp_p1_depth + {26'd0,1'd1,15'd0}) >>> 16;
	temp_p2_depth_q = (temp_p2_depth + {26'd0,1'd1,15'd0}) >>> 16;
	temp_p3_depth_q = (temp_p3_depth + {26'd0,1'd1,15'd0}) >>> 16;
	
	next_p1_color_R = temp_p1_color_R_q[11:0];
	next_p2_color_R = temp_p2_color_R_q[11:0];
	next_p3_color_R = temp_p3_color_R_q[11:0];
	
	
	next_p1_color_G = temp_p1_color_G_q[11:0];
	next_p2_color_G = temp_p2_color_G_q[11:0];
	next_p3_color_G = temp_p3_color_G_q[11:0];
	
	
	next_p1_color_B = temp_p1_color_B_q[11:0];
	next_p2_color_B = temp_p2_color_B_q[11:0];
	next_p3_color_B = temp_p3_color_B_q[11:0];
	
	next_p1_depth = temp_p1_depth_q[25:0];
	next_p2_depth = temp_p2_depth_q[25:0];
	next_p3_depth = temp_p3_depth_q[25:0];


    // 9th pipeline
    temp_current_color_R = p1_color_R + p2_color_R + p3_color_R;
    temp_current_color_G = p1_color_G + p2_color_G + p3_color_G;
    temp_current_color_B = p1_color_B + p2_color_B + p3_color_B;   // fl=4
	
	temp_current_depth = p1_depth + p2_depth + p3_depth;           // fl=24
	
	//quantization2:
	temp_current_color_R_q = (temp_current_color_R + {8'd0,1'd1,3'd0}) >>> 4;
    temp_current_color_G_q = (temp_current_color_G + {8'd0,1'd1,3'd0}) >>> 4;
	temp_current_color_B_q = (temp_current_color_B + {8'd0,1'd1,3'd0}) >>> 4;
	temp_current_depth_q   = (temp_current_depth + {22'd0,1'd1,3'd0} ) >>> 4;
	
	casez({detect_pipe9,overlap_v1_pipe9,overlap_v2_pipe9,overlap_v3_pipe9})
	    4'b1???: begin  // vertice have overlap
		    next_not_draw = 1;
			next_current_Color = 0;
			next_current_depth = 0;
		end 
		4'b0100: begin  // overlap with vertice1
		    next_not_draw = 0;
			next_current_Color = vertice1_color_pipe9;
			next_current_depth = vertice1_depth_pipe9;
		end
		4'b0010: begin  // overlap with vertice2
		    next_not_draw = 0;
			next_current_Color = vertice2_color_pipe9;
			next_current_depth = vertice2_depth_pipe9;
		end
		4'b0001: begin  //overlap with vertice3
		    next_not_draw = 0;
			next_current_Color = vertice3_color_pipe9;
			next_current_depth = vertice3_depth_pipe9;
		end
		default: begin
		    next_not_draw = 0;
			next_current_Color = {temp_current_color_R_q[7:0],temp_current_color_G_q[7:0],temp_current_color_B_q[7:0]};
	        next_current_depth = temp_current_depth_q[20:0];
		end
	endcase
	
	next_in_triangle = in_triangle_pipe9;

end

always@(posedge clk) begin

    // 1st pipeline
    temp0 <= next_temp0;
    temp1 <= next_temp1;
    temp2 <= next_temp2;
    temp3 <= next_temp3;
    temp4 <= next_temp4;
    temp5 <= next_temp5;
    temp6 <= next_temp6;
    temp7 <= next_temp7;
    temp8 <= next_temp8;
    temp9 <= next_temp9;
    temp10 <= next_temp10;
    temp11 <= next_temp11;
	
	detect_pipe2 <= next_detect_pipe2;
	
	overlap_v1_pipe2 <= next_overlap_v1_pipe2;
	overlap_v2_pipe2 <= next_overlap_v2_pipe2;
    overlap_v3_pipe2 <= next_overlap_v3_pipe2;
	
    vertice1_depth_pipe2 <= vertice1_depth;
    vertice2_depth_pipe2 <= vertice2_depth;
    vertice3_depth_pipe2 <= vertice3_depth;
	
    vertice1_color_pipe2 <= vertice1_color;
    vertice2_color_pipe2 <= vertice2_color;
    vertice3_color_pipe2 <= vertice3_color;
	
	// 2nd pipeline
	
	A1 <= next_A1;
	A2 <= next_A2;
	A3 <= next_A3;
	At <= next_At;
	
	detect_pipe3 <= detect_pipe2;
	overlap_v1_pipe3 <= overlap_v1_pipe2;
	overlap_v2_pipe3 <= overlap_v2_pipe2;
    overlap_v3_pipe3 <= overlap_v3_pipe2;
	
	vertice1_depth_pipe3 <= vertice1_depth_pipe2;
    vertice2_depth_pipe3 <= vertice2_depth_pipe2;
    vertice3_depth_pipe3 <= vertice3_depth_pipe2;
	
	vertice1_color_pipe3 <= vertice1_color_pipe2;
    vertice2_color_pipe3 <= vertice2_color_pipe2;
    vertice3_color_pipe3 <= vertice3_color_pipe2;
	
	// 3rd pipeline
	detect_pipe4 <= detect_pipe3;
	overlap_v1_pipe4 <= overlap_v1_pipe3;
	overlap_v2_pipe4 <= overlap_v2_pipe3;
    overlap_v3_pipe4 <= overlap_v3_pipe3;
	
	vertice1_depth_pipe4 <= vertice1_depth_pipe3;
    vertice2_depth_pipe4 <= vertice2_depth_pipe3;
    vertice3_depth_pipe4 <= vertice3_depth_pipe3;
	
	vertice1_color_pipe4 <= vertice1_color_pipe3;
    vertice2_color_pipe4 <= vertice2_color_pipe3;
    vertice3_color_pipe4 <= vertice3_color_pipe3;
	
	// 4th pipeline
	detect_pipe5 <= detect_pipe4;
	overlap_v1_pipe5 <= overlap_v1_pipe4;
	overlap_v2_pipe5 <= overlap_v2_pipe4;
    overlap_v3_pipe5 <= overlap_v3_pipe4;
	
	vertice1_depth_pipe5 <= vertice1_depth_pipe4;
    vertice2_depth_pipe5 <= vertice2_depth_pipe4;
    vertice3_depth_pipe5 <= vertice3_depth_pipe4;
	
	vertice1_color_pipe5 <= vertice1_color_pipe4;
    vertice2_color_pipe5 <= vertice2_color_pipe4;
    vertice3_color_pipe5 <= vertice3_color_pipe4;
	
	in_triangle_pipe5 <= in_triangle_pipe4;
	
	// 5th pipeline
	detect_pipe6 <= detect_pipe5;
	overlap_v1_pipe6 <= overlap_v1_pipe5;
	overlap_v2_pipe6 <= overlap_v2_pipe5;
    overlap_v3_pipe6 <= overlap_v3_pipe5;
	
	vertice1_depth_pipe6 <= vertice1_depth_pipe5;
    vertice2_depth_pipe6 <= vertice2_depth_pipe5;
    vertice3_depth_pipe6 <= vertice3_depth_pipe5;
	
	vertice1_color_pipe6 <= vertice1_color_pipe5;
    vertice2_color_pipe6 <= vertice2_color_pipe5;
    vertice3_color_pipe6 <= vertice3_color_pipe5;
	
	in_triangle_pipe6 <= in_triangle_pipe5;
	
	// 6th pipeline
	detect_pipe7 <= detect_pipe6;
	overlap_v1_pipe7 <= overlap_v1_pipe6;
	overlap_v2_pipe7 <= overlap_v2_pipe6;
    overlap_v3_pipe7 <= overlap_v3_pipe6;
	
	vertice1_depth_pipe7 <= vertice1_depth_pipe6;
    vertice2_depth_pipe7 <= vertice2_depth_pipe6;
    vertice3_depth_pipe7 <= vertice3_depth_pipe6;
	
	vertice1_color_pipe7 <= vertice1_color_pipe6;
    vertice2_color_pipe7 <= vertice2_color_pipe6;
    vertice3_color_pipe7 <= vertice3_color_pipe6;
	
	in_triangle_pipe7 <= in_triangle_pipe6;
	
	// 7th pipeline
	detect_pipe8 <= detect_pipe7;
	overlap_v1_pipe8 <= overlap_v1_pipe7;
	overlap_v2_pipe8 <= overlap_v2_pipe7;
    overlap_v3_pipe8 <= overlap_v3_pipe7;
	
	vertice1_depth_pipe8 <= vertice1_depth_pipe7;
    vertice2_depth_pipe8 <= vertice2_depth_pipe7;
    vertice3_depth_pipe8 <= vertice3_depth_pipe7;
	
	vertice1_color_pipe8 <= vertice1_color_pipe7;
    vertice2_color_pipe8 <= vertice2_color_pipe7;
    vertice3_color_pipe8 <= vertice3_color_pipe7;
	
	in_triangle_pipe8 <= in_triangle_pipe7;
	
	// 8th pipeline
	detect_pipe9 <= detect_pipe8;
	overlap_v1_pipe9 <= overlap_v1_pipe8;
	overlap_v2_pipe9 <= overlap_v2_pipe8;
    overlap_v3_pipe9 <= overlap_v3_pipe8;
	
	vertice1_depth_pipe9 <= vertice1_depth_pipe8;
    vertice2_depth_pipe9 <= vertice2_depth_pipe8;
    vertice3_depth_pipe9 <= vertice3_depth_pipe8;
	
	vertice1_color_pipe9 <= vertice1_color_pipe8;
    vertice2_color_pipe9 <= vertice2_color_pipe8;
    vertice3_color_pipe9 <= vertice3_color_pipe8;
	
	in_triangle_pipe9 <= in_triangle_pipe8;
	
    p1_color_R <= next_p1_color_R;
    p2_color_R <= next_p2_color_R;
    p3_color_R <= next_p3_color_R;

    p1_color_G <= next_p1_color_G;
    p2_color_G <= next_p2_color_G;
    p3_color_G <= next_p3_color_G;

    p1_color_B <= next_p1_color_B;
    p2_color_B <= next_p2_color_B;
    p3_color_B <= next_p3_color_B;

    p1_depth <= next_p1_depth;
    p2_depth <= next_p2_depth;
    p3_depth <= next_p3_depth;	
	
	// 9th pipeline
	current_Color <= next_current_Color;
	current_depth <= next_current_depth;
	not_draw <= next_not_draw;
	in_triangle <= next_in_triangle;

end


	div_pipe div_pipe_1(
	.clk(clk),
	.A(A1),
	.At(At),
	.L(L1)
	);

	div_pipe div_pipe_2(
	.clk(clk),
	.A(A2),
	.At(At),
	.L(L2)
	);

	div_pipe div_pipe_3(
	.clk(clk),
	.A(A3),
	.At(At),
	.L(L3)
	);
	
	InTriangle InTriangle(
	.clk(clk),
	.screen_x1(screen_x1),
	.screen_y1(screen_y1),
	.screen_x2(screen_x2),
	.screen_y2(screen_y2),
	.screen_x3(screen_x3),
	.screen_y3(screen_y3),
	.current_x(current_x),
	.current_y(current_y),
	.in_triangle_flag(in_triangle_pipe4)
	);

endmodule



module div_pipe(
  input clk,
  input [26:0] A,
  input [26:0] At,
  output reg [20:0] L
  
);

// input
//reg signed [26:0] A;   
//reg signed [26:0] At;

// 3th pipeline
reg signed [26:0] A_1_1;
reg signed [26:0] A_2_1;
reg signed [26:0] A_3_1;
reg signed [26:0] A_4_1;
reg [3:0] temp_store_1;

reg signed [26:0] next_Apipe2;
reg signed [26:0] Apipe2;
reg signed [20:0] next_Lpipe2;
reg signed [20:0] Lpipe2;
reg signed [26:0] next_Atpipe2;
reg signed [26:0] Atpipe2;


// 4th pipeline
reg signed [26:0] A_1_2;
reg signed [26:0] A_2_2;
reg signed [26:0] A_3_2;
reg signed [26:0] A_4_2;
reg [3:0] temp_store_2;

reg signed [26:0] next_Apipe3;
reg signed [26:0] Apipe3;
reg signed [20:0] next_Lpipe3;
reg signed [20:0] Lpipe3;
reg signed [26:0] next_Atpipe3;
reg signed [26:0] Atpipe3;

// 5th pipeline
reg signed [26:0] A_1_3;
reg signed [26:0] A_2_3;
reg signed [26:0] A_3_3;
reg signed [26:0] A_4_3;
reg [3:0] temp_store_3;

reg signed [26:0] next_Apipe4;
reg signed [26:0] Apipe4;
reg signed [20:0] next_Lpipe4;
reg signed [20:0] Lpipe4;
reg signed [26:0] next_Atpipe4;
reg signed [26:0] Atpipe4;

// 6th pipeline
reg signed [26:0] A_1_4;
reg signed [26:0] A_2_4;
reg signed [26:0] A_3_4;
reg signed [26:0] A_4_4;
reg [3:0] temp_store_4;

reg signed [26:0] next_Apipe5;
reg signed [26:0] Apipe5;
reg signed [20:0] next_Lpipe5;
reg signed [20:0] Lpipe5;
reg signed [26:0] next_Atpipe5;
reg signed [26:0] Atpipe5;

// 7th pipeline
reg signed [26:0] A_1_5;
reg signed [26:0] A_2_5;
reg signed [26:0] A_3_5;
reg signed [26:0] A_4_5;
reg [3:0] temp_store_5;


reg signed [20:0] next_L;

// output
// reg signed [20:0] L;


integer i1,i2,i3,i4,i5;


//3rd pipeline (div1)
always@* begin

    A_1_1 = A << 1;
	
	if(A_1_1 > At) begin
	    A_2_1 = (A_1_1 - At) << 1;
		temp_store_1[3] = 1'b1;
	end else begin
	    A_2_1 = A_1_1 << 1;
        temp_store_1[3] = 1'b0;		
	end

    if(A_2_1 > At) begin
	    A_3_1 = (A_2_1 - At) << 1;
		temp_store_1[2] = 1'b1;
	end else begin
	    A_3_1 = A_2_1 << 1;
	    temp_store_1[2] = 1'b0;
	end
	
	if(A_3_1 > At) begin
	    A_4_1 = (A_3_1 - At) << 1;
		temp_store_1[1] = 1'b1;
	end else begin
	    A_4_1 = A_3_1 << 1;
	    temp_store_1[1] = 1'b0;
	end
	
	if(A_4_1 > At) begin
	    next_Apipe2 = (A_4_1 - At) << 1;
		temp_store_1[0] = 1'b1;
	end else begin
	    next_Apipe2 = A_4_1 << 1;
	    temp_store_1[0] = 1'b0;
	end
	
	next_Atpipe2 = At;
	
	next_Lpipe2[3:0] = temp_store_1;
	
	for(i1=4; i1<=20; i1=i1+1) begin 
	    next_Lpipe2[i1] = 1'b0;
	end
	
end

// 4th pipeline (div2)
always@* begin

    A_1_2 = Apipe2;
	
	if(A_1_2 > Atpipe2) begin
	    A_2_2 = (A_1_2 - Atpipe2) << 1;
		temp_store_2[3] = 1'b1;
	end else begin
	    A_2_2 = A_1_2 << 1;
        temp_store_2[3] = 1'b0;		
	end

    if(A_2_2 > Atpipe2) begin
	    A_3_2 = (A_2_2 - Atpipe2) << 1;
		temp_store_2[2] = 1'b1;
	end else begin
	    A_3_2 = A_2_2 << 1;
	    temp_store_2[2] = 1'b0;
	end
	
	if(A_3_2 > Atpipe2) begin
	    A_4_2 = (A_3_2 - Atpipe2) << 1;
		temp_store_2[1] = 1'b1;
	end else begin
	    A_4_2 = A_3_2 << 1;
	    temp_store_2[1] = 1'b0;
	end
	
	if(A_4_2 > Atpipe2) begin
	    next_Apipe3 = (A_4_2 - Atpipe2) << 1;
		temp_store_2[0] = 1'b1;
	end else begin
	    next_Apipe3 = A_4_2 << 1;
	    temp_store_2[0] = 1'b0;
	end
	
	next_Atpipe3 = Atpipe2;
	
	next_Lpipe3[3:0] = temp_store_2;
	
	for(i2=4; i2<=20; i2=i2+1) begin 
	    next_Lpipe3[i2] = Lpipe2[i2-4];
	end
	
end

// 5th pipeline (div3)
always@* begin

    A_1_3 = Apipe3;
	
	if(A_1_3 > Atpipe3) begin
	    A_2_3 = (A_1_3 - Atpipe3) << 1;
		temp_store_3[3] = 1'b1;
	end else begin
	    A_2_3 = A_1_3 << 1;
        temp_store_3[3] = 1'b0;		
	end

    if(A_2_3 > Atpipe3) begin
	    A_3_3 = (A_2_3 - Atpipe3) << 1;
		temp_store_3[2] = 1'b1;
	end else begin
	    A_3_3 = A_2_3 << 1;
	    temp_store_3[2] = 1'b0;
	end
	
	if(A_3_3 > Atpipe3) begin
	    A_4_3 = (A_3_3 - Atpipe3) << 1;
		temp_store_3[1] = 1'b1;
	end else begin
	    A_4_3 = A_3_3 << 1;
	    temp_store_3[1] = 1'b0;
	end
	
	if(A_4_3 > Atpipe3) begin
	    next_Apipe4 = (A_4_3 - Atpipe3) << 1;
		temp_store_3[0] = 1'b1;
	end else begin
	    next_Apipe4 = A_4_3 << 1;
	    temp_store_3[0] = 1'b0;
	end
	
	next_Atpipe4 = Atpipe3;
	
	next_Lpipe4[3:0] = temp_store_3;
	
	for(i3=4; i3<=20; i3=i3+1) begin 
	    next_Lpipe4[i3] = Lpipe3[i3-4];
	end
	
end

// 6th pipeline (div4)
always@* begin

    A_1_4 = Apipe4;
	
	if(A_1_4 > Atpipe4) begin
	    A_2_4 = (A_1_4 - Atpipe4) << 1;
		temp_store_4[3] = 1'b1;
	end else begin
	    A_2_4 = A_1_4 << 1;
        temp_store_4[3] = 1'b0;		
	end

    if(A_2_4 > Atpipe4) begin
	    A_3_4 = (A_2_4 - Atpipe4) << 1;
		temp_store_4[2] = 1'b1;
	end else begin
	    A_3_4 = A_2_4 << 1;
	    temp_store_4[2] = 1'b0;
	end
	
	if(A_3_4 > Atpipe4) begin
	    A_4_4 = (A_3_4 - Atpipe4) << 1;
		temp_store_4[1] = 1'b1;
	end else begin
	    A_4_4 = A_3_4 << 1;
	    temp_store_4[1] = 1'b0;
	end
	
	if(A_4_4 > Atpipe4) begin
	    next_Apipe5 = (A_4_4 - Atpipe4) << 1;
		temp_store_4[0] = 1'b1;
	end else begin
	    next_Apipe5 = A_4_4 << 1;
	    temp_store_4[0] = 1'b0;
	end
	
	next_Atpipe5 = Atpipe4;
	
	next_Lpipe5[3:0] = temp_store_4;
	
	for(i4=4; i4<=20; i4=i4+1) begin 
	    next_Lpipe5[i4] = Lpipe4[i4-4];
	end
	
end


// 7th pipeline (div5)
always@* begin

    A_1_5 = Apipe5;
	
	if(A_1_5 > Atpipe5) begin
	    A_2_5 = (A_1_5 - Atpipe5) << 1;
		temp_store_5[3] = 1'b1;
	end else begin
	    A_2_5 = A_1_5 << 1;
        temp_store_5[3] = 1'b0;		
	end

    if(A_2_5 > Atpipe5) begin
	    A_3_5 = (A_2_5 - Atpipe5) << 1;
		temp_store_5[2] = 1'b1;
	end else begin
	    A_3_5 = A_2_5 << 1;
	    temp_store_5[2] = 1'b0;
	end
	
	if(A_3_5 > Atpipe5) begin
	    A_4_5 = (A_3_5 - Atpipe5) << 1;
		temp_store_5[1] = 1'b1;
	end else begin
	    A_4_5 = A_3_5 << 1;
	    temp_store_5[1] = 1'b0;
	end
	
	if(A_4_5 > Atpipe5) begin
		temp_store_5[0] = 1'b1;
	end else begin
	    temp_store_5[0] = 1'b0;
	end
	
	next_L[3:0] = temp_store_5;
	
	for(i5=4; i5<=20; i5=i5+1) begin 
	    next_L[i5] = Lpipe5[i5-4];
	end
	
end

always@(posedge clk) begin

    Apipe2 <= next_Apipe2;
    Lpipe2 <= next_Lpipe2;
	Atpipe2 <= next_Atpipe2;

    Apipe3 <= next_Apipe3;
	Lpipe3 <= next_Lpipe3;
	Atpipe3 <= next_Atpipe3;
	
	Apipe4 <= next_Apipe4;
	Lpipe4 <= next_Lpipe4;
	Atpipe4 <= next_Atpipe4;
	
	Apipe5 <= next_Apipe5;
	Lpipe5 <= next_Lpipe5;
	Atpipe5 <= next_Atpipe5;

	L <= next_L;

end

endmodule


module InTriangle(

    input clk,
    input [11:0] screen_x1,
	input [11:0] screen_y1,
	input [11:0] screen_x2,
	input [11:0] screen_y2,
	input [11:0] screen_x3,
	input [11:0] screen_y3,

    input [11:0] current_x,
    input [11:0] current_y,
	
	output reg in_triangle_flag
);

reg signed [11:0] Ax; //screen_x1_s
reg signed [11:0] Ay; //screen_y1_s
reg signed [11:0] Bx; //screen_x2_s
reg signed [11:0] By; //screen_y2_s
reg signed [11:0] Cx; //screen_x3_s
reg signed [11:0] Cy; //screen_y3_s
reg signed [11:0] Px; //current_x_s
reg signed [11:0] Py; //current_y_s

reg signed [25:0] next_temp1;
reg signed [25:0] next_temp2;
reg signed [25:0] next_temp3;
reg signed [25:0] next_temp4;
reg signed [25:0] next_temp5;
reg signed [25:0] next_temp6;

reg signed [25:0] temp1;
reg signed [25:0] temp2;
reg signed [25:0] temp3;
reg signed [25:0] temp4;
reg signed [25:0] temp5;
reg signed [25:0] temp6;

reg signed [26:0] next_cross1;
reg signed [26:0] next_cross2;
reg signed [26:0] next_cross3;

reg signed [26:0] cross1;
reg signed [26:0] cross2;
reg signed [26:0] cross3;

reg next_in_triangle_flag;

reg has_neg;
reg has_pos;

always@* begin

    // 1st pipeline (outside)
	Ax = screen_x1;
	Ay = screen_y1;
	Bx = screen_x2;
	By = screen_y2;
	Cx = screen_x3;
	Cy = screen_y3;
	Px = current_x;
	Py = current_y;

    next_temp1 = (Bx - Ax)*(Py - Ay);
    next_temp2 = (By - Ay)*(Px - Ax);
	next_temp3 = (Cx - Bx)*(Py - By);
	next_temp4 = (Cy - By)*(Px - Bx);
	next_temp5 = (Ax - Cx)*(Py - Cy);
	next_temp6 = (Ay - Cy)*(Px - Cx);
	
	//2nd pipeline (outside)
	next_cross1 = temp1 - temp2;
	next_cross2 = temp3 - temp4;
	next_cross3 = temp5 - temp6;
	
	//3th pipeline (outside)
	has_neg = ((cross1 < 0) || (cross2 < 0) || (cross3 < 0));
	has_pos = ((cross1 > 0) || (cross2 > 0) || (cross3 > 0));
	next_in_triangle_flag = !(has_neg && has_pos);


end

always@(posedge clk) begin

    temp1 <= next_temp1;
    temp2 <= next_temp2;
    temp3 <= next_temp3;
    temp4 <= next_temp4;
    temp5 <= next_temp5;
    temp6 <= next_temp6;    

    cross1 <= next_cross1;
	cross2 <= next_cross2;
	cross3 <= next_cross3;
	
	in_triangle_flag <= next_in_triangle_flag;

end


endmodule