set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# Define a lib path
define_design_lib $TOPLEVEL -path ./$TOPLEVEL

# Add your hdl files here
analyze -library $TOPLEVEL -format verilog "../hdl/Graphic_3Dto2D_top.v"
analyze -library $TOPLEVEL -format verilog "../hdl/Rasterizer.v"
analyze -library $TOPLEVEL -format verilog "../hdl/vertex_shader.v"
analyze -library $TOPLEVEL -format verilog "../hdl/getColorDepth.v"
analyze -library $TOPLEVEL -format verilog "../hdl/controller.v"
analyze -library $TOPLEVEL -format verilog "../hdl/cross_product.v"
analyze -library $TOPLEVEL -format verilog "../hdl/divider.v"
analyze -library $TOPLEVEL -format verilog "../hdl/divider_unit.v"
analyze -library $TOPLEVEL -format verilog "../hdl/divider_unit_last.v"
analyze -library $TOPLEVEL -format verilog "../hdl/inv_sqrt.v"
analyze -library $TOPLEVEL -format verilog "../hdl/inv_sqrt_LUT.v"
analyze -library $TOPLEVEL -format verilog "../hdl/neg_dot_product.v"

# Elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve multiple instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# Link the design
current_design $TOPLEVEL
link
