for model in ATHENA BOX BUNNY DRAGON ELEPHANT TEAPOT; do
    for pattern in PAT1 PAT2; do
        for sim in PRESIM GATESIM; do
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
                    vcs -R +v2k -full64 -f sim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim} +define+DUMPFILE\
                    +warn=noSDFCOM_CFIIS
                else
                    vcs -R +v2k -full64 -f sim.f -debug_acc -l sim_${model}_${pattern}_${sim}.log\
                    +define+${model} +define+${pattern} +define+${sim}\
                    +warn=noSDFCOM_CFIIS
                fi
            fi
        done
    done
done