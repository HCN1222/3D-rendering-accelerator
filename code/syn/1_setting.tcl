# Set design and I/O environment
set_operating_conditions -library slow_vdd1v2 PVT_1P08V_125C

# Assume outputs go to DFF and inputs also come from DFF
set_driving_cell -library slow_vdd1v2 -lib_cell DFFHQX1 -pin {Q} [all_inputs]	
set_load [load_of "slow_vdd1v2/DFFHQX1/D"] [all_outputs]

# Set wireload model
set_wire_load_mode enclosed
set_wire_load_model -name "Large" $TOPLEVEL

# Set timing constraint
#-- ceate clock
create_clock -name clk -period $TEST_CYCLE [get_ports clk]
#-- set clock constraint
set_ideal_network      [get_ports clk]
set_dont_touch_network [all_clocks]
#-- set I/O delay
#set_input_delay  [expr $TEST_CYCLE*0.7] -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay [expr $TEST_CYCLE*0.7] -clock clk [all_outputs]

# Set DRC constraint
# Defensive setting: default fanout_load 1.0 and our target max fanout # 20 => 1.0*20 = 20.0
# max_transition and max_capacitance are given in the cell library
set_max_fanout 20.0 $TOPLEVEL

# Set area constraint
set_max_area 0
