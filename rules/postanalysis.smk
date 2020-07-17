# =================================================================================================
#     Statistical tests
# =================================================================================================

rule iqtree_stats_test:
    input:
        msa="aligned/{aligner}/{sample}/sample.fasta",
        best_tree="trees/pargenes/{aligner}/{sample}-best.newick",
        best_model="trees/pargenes/{aligner}/{sample}-best.model",
        ml_trees="trees/pargenes/{aligner}/{sample}-ml-trees.newick"
    output:
        "post/iqtree_stats_test/pargenes/{aligner}/{sample}/stats.iqtree"
    threads:
        config["settings"]["threads"]
    params:
        workdir="post/iqtree_stats_test/pargenes/{aligner}/{sample}/"
    log:
        "logs/iqtree_stats_test/{aligner}/{sample}.log"
    run:
        import re
        modelstring=""
        with open(input.best_model) as modelfile:
            lines = modelfile.readlines()
            if len(lines) != 1:
                raise InputError("Modelfile has weird number of lines")
            modelstring=re.sub( r",.*", "", re.sub(r"{.*}", "", lines[0]) ).rstrip()
            # fix for nonexistent "G4m"-like
            modelstring=re.sub( r"m$", "", modelstring )
        shell(  "iqtree -s {input.msa} -te {input.best_tree} -z {input.ml_trees} "
                "-m {modelstring} "
                "-pre {params.workdir}/stats -T {threads} "
                "-n 0 -zb 1000 -zw -au > {log}" )   

rule summarize_iqtree_stats_test:
    input:
        iqtree_stats="post/iqtree_stats_test/pargenes/{aligner}/{sample}/stats.iqtree",
        ml_trees="trees/pargenes/{aligner}/{sample}-ml-trees.newick"
    output:
        summary="post/iqtree_stats_test/pargenes/{aligner}/{sample}/summary.txt",
        plausible_trees="post/iqtree_stats_test/pargenes/{aligner}/{sample}/plausible_trees.newick"
    script:
        "scripts/iqtree_test_summarize.py"
