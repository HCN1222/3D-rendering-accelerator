
//=== Setup mode ===
set system mode setup

set log file lec.log -replace
set parallel option -threads 8
//---------------------------------------------------------------------------------//
// Top level
setenv TOP_DESIGN Graphic_3Dto2D_top

// Resource file (MDP flow)
setenv RESRC_FILE ../syn/report/report_resources_Graphic_3Dto2D_top.out
//read setup information info.vsdc -type VSDC

// Blackbox (before reading design!!!)
//add notranslate module xxx -library -both

read design -file golden.f -golden -verilog2k
read design -file revised.f -revised
report design data
report black box -detail

// Specify module renaming rule 
// (correspond to DC 'set uniquify_naming_style "%s_mydesign_%d"')
// (%w, %d) <-- (@1, @2)
add renaming rule rule1 "%w_mydesign_%d$" "@1" -module -revised
add renaming rule rule2 "%d_reg\[%d\]" "reg[@1][@2]" -revised

// Software renames golden design instances to be the same as revised design
uniquify -nolib -all -use_renaming_rule

// Specify modeling directives for clock-gating & constant optimization 
set flatten model -gated_clock
set flatten model -seq_constant
set flatten model -seq_redundant
set undriven signal 0 -both

set analyze option -effort_analyze_abort high

set root module $TOP_DESIGN -golden
set root module $TOP_DESIGN -revised

