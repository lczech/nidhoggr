# =================================================================================================
#     Statistical tests
# =================================================================================================

rule iqtree_stats_test:
    input:
        msa         = "result/{sample}/{aligner}/msa/aligned.fasta",
        best_tree   = "result/{sample}/{aligner}/pargenes/tree/best.newick",
        best_model  = "result/{sample}/{aligner}/pargenes/tree/best.model",
        ml_trees    = "result/{sample}/{aligner}/pargenes/tree/ml_trees.newick"
    output:
        "result/{sample}/{aligner}/pargenes/post/stats.iqtree"
    threads:
        config["settings"]["threads"]
    params:
        workdir="result/{sample}/{aligner}/pargenes/post"
    log:
        "result/{sample}/{aligner}/pargenes/post/iqtree.log"
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
        iqtree_stats    = "result/{sample}/{aligner}/pargenes/post/stats.iqtree",
        ml_trees        = "result/{sample}/{aligner}/pargenes/tree/ml_trees.newick"
    output:
        summary         = "result/{sample}/{aligner}/pargenes/post/significance.txt",
        plausible_trees = "result/{sample}/{aligner}/pargenes/post/plausible_trees.newick"
    script:
        "scripts/iqtree_test_summarize.py"
