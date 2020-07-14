# =================================================================================================
#     Tree Search with ParGenes
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
        bs_trees=config["params"]["pargenes"]["bs_trees"],

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
        # ParGenes fails if the output dir already exists. To be sure to start from scratch,
        # and only copy the output files on success, we use a full shadow directory.
        "full"
    shell:
        config["params"]["pargenes"]["command"] +
        " --alignments-dir {params.indir} --output-dir {params.outdir} "
        "--parsimony-starting-trees {params.parsimony_starting_trees} "
        "--random-starting-trees {params.random_starting_trees} "
        "--bs-trees {params.bs_trees} "
        "{params.extra} --cores {threads} --continue > {log} 2>&1 "

        # Copy the original files produced by ParGenes to keep our stuff clean.
        # As we work in a shadow directory, all other files are deleted after this.
        "&& cp {params.outdir}/mlsearch_run/results/sample_fasta/sample_fasta.raxml.bestTree {output.best_tree} "
        "&& cp {params.outdir}/mlsearch_run/results/sample_fasta/sorted_ml_trees.newick {output.ml_trees} "

# =================================================================================================
#     Consensus Tree with RAxML-ng
# =================================================================================================

rule treesearch_consensus:
    input:
        "trees/pargenes/{aligner}/{sample}-ml-trees.newick"
    output:
        mr  = "trees/pargenes/{aligner}/{sample}-ml-trees.raxml.consensusTreeMR",
        mre = "trees/pargenes/{aligner}/{sample}-ml-trees.raxml.consensusTreeMRE"
    log:
        mr  = "logs/raxmlng-consensus/{aligner}/{sample}-mr.log",
        mre = "logs/raxmlng-consensus/{aligner}/{sample}-mre.log"
    shell:
        config["params"]["raxmlng"]["command"] +
        " --consense MR  --tree {input} --prefix trees/pargenes/{wildcards.aligner}/{wildcards.sample}-ml-trees > {log.mr}  2>&1 "
        "&& " + config["params"]["raxmlng"]["command"] +
        " --consense MRE --tree {input} --prefix trees/pargenes/{wildcards.aligner}/{wildcards.sample}-ml-trees > {log.mre} 2>&1 "
