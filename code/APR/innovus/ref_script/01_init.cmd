# init setting
set init_verilog ../pre_layout/Graphic_3Dto2D_top_syn.v
set init_top_cell Graphic_3Dto2D_top
set init_io_file ../pre_layout/Graphic_3Dto2D_top.save.io
set init_lef_file { \
    /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef \
    /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
set init_gnd_net VSS
set init_pwr_net VDD
set init_mmmc_file ../pre_layout/mmmc.view

init_design
setDesignMode -process 45
setMultiCpuUsage -localCpu 2

# Connect Global Nets
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *

# Save design
saveDesign DBS/01_init.enc 