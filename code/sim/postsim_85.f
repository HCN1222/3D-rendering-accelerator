// testbench
test_Graphic_3Dto2D_top.v

// sram behavior model
sram_model/sram_depth.v
sram_model/sram_face.v
sram_model/sram_screen_buffer_color.v
sram_model/sram_vertex_color.v
sram_model/sram_vertex_position.v

// add your module here
../APR_85/innovus/post_layout/CHIP.v

# Logic Gate models
-v /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/verilog/slow_vdd1v2_basicCells.v

+maxdelays
+neg_tchk

