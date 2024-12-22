# Iterate through the list of models
for model in ATHENA BOX BUNNY DRAGON ELEPHANT TEAPOT; do
    # Iterate through the list of patterns
    for pattern in PAT1 PAT2; do
        # Run the simulation with the current model and pattern
        vcs -R +v2k -full64 -f sim.f -debug_acc -l sim_${model}_${pattern}.log +define+${model} +define+${pattern} +define+PRESIM
    done
done