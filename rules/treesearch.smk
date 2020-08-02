# =================================================================================================
#     Tree Search with ParGenes
# =================================================================================================

rule treesearch_pargenes:
    input:
        "{outdir}/result/{sample}/{aligner}/msa/aligned.fasta"
    output:
        best_tree       = "{outdir}/result/{sample}/{aligner}/pargenes/tree/best.newick",
        best_model      = "{outdir}/result/{sample}/{aligner}/pargenes/tree/best.model",
        support_tree    = "{outdir}/result/{sample}/{aligner}/pargenes/tree/bootstrap.newick",
        tbe_support_tree= "{outdir}/result/{sample}/{aligner}/pargenes/tree/transfer_bootstrap.newick",
        ml_trees        = "{outdir}/result/{sample}/{aligner}/pargenes/tree/ml_trees.newick"
    params:
        pargenes                = config["params"]["pargenes"]["command"],
        extra                   = config["params"]["pargenes"]["extra"],
        parsimony_starting_trees= config["params"]["pargenes"]["parsimony_starting_trees"],
        random_starting_trees   = config["params"]["pargenes"]["random_starting_trees"],
        bs_trees                = config["params"]["pargenes"]["bs_trees"],
        datatype                = config["params"]["pargenes"]["datatype"],

        # Need to specify the directories for ParGenes instead of the files...
        indir   = lambda wildcards: os.path.join(wildcards.outdir, "result", wildcards.sample, wildcards.aligner, "msa"),
        outdir  = lambda wildcards: os.path.join(wildcards.outdir, "result", wildcards.sample, wildcards.aligner, "pargenes/pargenes_run")
    threads:
        config["params"]["pargenes"]["threads"]
    log:
        "{outdir}/result/{sample}/{aligner}/pargenes/tree/pargenes.log"
    benchmark:
        "{outdir}/benchmarks/pargenes/{aligner}/{sample}.bench.log"
    shell:
        "{params.pargenes} --alignments-dir {params.indir} --output-dir {params.outdir} "
        "--parsimony-starting-trees {params.parsimony_starting_trees} "
        "--random-starting-trees {params.random_starting_trees} "
        "--bs-trees {params.bs_trees} "
        "--datatype {params.datatype} "
        "{params.extra} --cores {threads} --continue > {log} 2>&1 "

        # Copy the original files produced by ParGenes to keep our stuff clean.
        # As we work in a shadow directory, all other files are deleted after this.
        "&& cp {params.outdir}/mlsearch_run/results/aligned_fasta/aligned_fasta.raxml.bestTree {output.best_tree} "
        "&& cp {params.outdir}/mlsearch_run/results/aligned_fasta/aligned_fasta.raxml.bestModel {output.best_model} "
        "&& cp {params.outdir}/supports_run/results/aligned_fasta.support.raxml.support {output.support_tree} "
        "&& cp {params.outdir}/supports_run/results/aligned_fasta.support.tbe.raxml.support {output.tbe_support_tree} "
        "&& cp {params.outdir}/mlsearch_run/results/aligned_fasta/sorted_ml_trees.newick {output.ml_trees} "
        # finally delete the pargenes run dir
        "&& rm -rf {params.outdir} "

# =================================================================================================
#     Consensus Tree with RAxML-ng
# =================================================================================================

rule treesearch_consensus:
    input:
        "{outdir}/result/{sample}/{aligner}/pargenes/tree/ml_trees.newick"
    output:
        mr  = "{outdir}/result/{sample}/{aligner}/pargenes/tree/consensusTreeMR.newick",
        mre = "{outdir}/result/{sample}/{aligner}/pargenes/tree/consensusTreeMRE.newick"
    params:
        raxml   = config["params"]["raxmlng"]["command"],
        prefix  = "{outdir}/result/{sample}/{aligner}/pargenes/tree/ml_trees"
    log:
        mr  = "{outdir}/result/{sample}/{aligner}/pargenes/tree/mr.log",
        mre = "{outdir}/result/{sample}/{aligner}/pargenes/tree/mre.log"
    shell:
        "{params.raxml} --consense MR  --tree {input} --prefix {params.prefix} --redo > {log.mr}  2>&1 && "
        "mv {params.prefix}.raxml.consensusTreeMR {output.mr} && "
        "{params.raxml} --consense MRE --tree {input} --prefix {params.prefix} --redo > {log.mre} 2>&1 && "
        "mv {params.prefix}.raxml.consensusTreeMRE {output.mre}"
