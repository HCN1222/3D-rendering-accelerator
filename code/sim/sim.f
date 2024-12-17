//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
// testbench
test_Graphic_3Dto2D_top.v

// sram behavior model
sram_model/sram_depth.v
sram_model/sram_face.v
sram_model/sram_screen_buffer_color.v
sram_model/sram_vertex_color.v
sram_model/sram_vertex_position.v

// add your module here
../hdl/Graphic_3Dto2D_top.v
../hdl/controller.v
../hdl/cross_product.v
../hdl/divider.v
../hdl/divider_unit.v
../hdl/divider_unit_last.v
../hdl/getColorDepth.v
../hdl/inv_sqrt.v
../hdl/inv_sqrt_LUT.v
../hdl/neg_dot_product.v
../hdl/Rasterizer.v
../hdl/vertex_shader.v


