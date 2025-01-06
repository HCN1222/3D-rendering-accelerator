
//=== Setup mode ===
set system mode setup

set log file lec.log -replace
set parallel option -threads 1
//---------------------------------------------------------------------------------//
// Top level
setenv TOP_DESIGN Graphic_3Dto2D_top

// Blackbox (before reading design!!!)
//add notranslate module xxx -library -both

read design -file golden.f -golden
read design -file revised.f -revised
report design data
report black box -detail

// Software renames golden design instances to be the same as revised design
uniquify -nolib -all -use_renaming_rule


// Specify modeling directives for clock-gating & constant optimization 
set flatten model -gated_clock
set flatten model -seq_constant

set root module $TOP_DESIGN -golden
set root module $TOP_DESIGN -revised

