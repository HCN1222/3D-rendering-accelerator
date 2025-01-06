# for sim in PRESIM GATESIM POSTSIM; do
for sim in PRESIM GATESIM; do
    for model in BOX ATHENA BUNNY DRAGON ELEPHANT TEAPOT; do
        for pattern in PAT1 PAT2; do
            if [ "$sim" == "PRESIM" ]; then
                if [ "$model" == "BOX" ]; then
                    vcs -R +v2k -full64 -f sim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim} +define+DUMPFILE
                else
                    vcs -R +v2k -full64 -f sim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim}
                fi
            elif [ "$sim" == "GATESIM" ]; then
                if [ "$model" == "BOX" ]; then
                    vcs -R +v2k -full64 -f gatesim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim} +define+DUMPFILE\
                    +warn=none
                else
                    vcs -R +v2k -full64 -f gatesim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim}\
                    +warn=none
                fi
            elif [ "$sim" == "POSTSIM" ]; then
                if [ "$model" == "BOX" ]; then
                    vcs -R +v2k -full64 -f postsim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim} +define+DUMPFILE
                else
                    vcs -R +v2k -full64 -f postsim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim}
                fi
            fi
        done
    done
done
