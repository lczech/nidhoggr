# =================================================================================================
#     Treesearch with ParGenes
# =================================================================================================

rule treesearch_pargenes:
    input:
        "aligned/{aligner}/{sample}/sample.fasta"
    output:
        best_tree="trees/pargenes/{aligner}/{sample}-best.newick",
        ml_trees="trees/pargenes/{aligner}/{sample}-ml-trees.newick"
    params:
        extra=config["params"]["pargenes"]["extra"],
        parsimony_starting_trees=config["params"]["pargenes"]["parsimony_starting_trees"],
        random_starting_trees=config["params"]["pargenes"]["random_starting_trees"],

        # Need to specify the directories for ParGenes instead of the files...
        indir=lambda wildcards: os.path.join("aligned", wildcards.aligner, wildcards.sample),
        outdir=lambda wildcards: os.path.join("trees/pargenes", wildcards.aligner, wildcards.sample)
    threads:
        config["params"]["pargenes"]["threads"]
    log:
        "logs/pargenes/{aligner}/{sample}.log"
    benchmark:
        "benchmarks/pargenes/{aligner}/{sample}.bench.log"
    shadow:
        # ParGenes fails if the output dir already exists. To be sure, we use a full shadow.
        "full"
    shell:
        config["params"]["pargenes"]["command"] +
        " --alignments-dir {params.indir} --output-dir {params.outdir} "
        "--parsimony-starting-trees {params.parsimony_starting_trees} "
        "--random-starting-trees {params.random_starting_trees} "
        "{params.extra} --cores {threads} --continue > {log} 2>&1 "

        # Copy the original files produced by ParGenes to keep our stuff clean.
        "&& cp {params.outdir}/mlsearch_run/results/sample_fasta/sample_fasta.raxml.bestTree {output.best_tree} "
        "&& cp {params.outdir}/mlsearch_run/results/sample_fasta/sorted_ml_trees.newick {output.ml_trees} "
