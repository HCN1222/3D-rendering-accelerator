
//=== LEC mode ===
set system mode lec
map key point

// Analyze Setup 
// (Advanced command for resolving setup issues more accurately before compare)
analyze setup -verbose

// Analyze datapath modules (MDP flow) 
analyze datapath -module -resourcefile $RESRC_FILE -effort medium -verbose
analyze datapath -flowgraph -verbose

// -isolate_abort_module

// Comparison
add compare point -all
compare

// Attempt to resolve abort points if any
// analyze abort -compare


// Report
report unmap point -notmapped 
report compare data -nonequivalent
report verification

// Save session
save session DBS/lec_compare


// Back GUI to check details
//restore session DBS/lec_compare
//set system mode lec
//set gui on

