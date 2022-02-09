# =================================================================================================
#     Statistical tests
# =================================================================================================

def modelstring_params():
    import re
    modelstring=""
    with open(input.best_model) as modelfile:
        lines = modelfile.readlines()
        if len(lines) != 1:
            raise InputError("Modelfile has weird number of lines")
        modelstring=re.sub( r",.*", "", re.sub(r"{.*}", "", lines[0]) ).rstrip()
        # fix for nonexistent "G4m"-like
        modelstring=re.sub( r"m$", "", modelstring )
    return modelstring

rule iqtree_stats_test:
    input:
        msa         = "result/{sample}/{aligner}/msa/aligned.fasta",
        best_tree   = "result/{sample}/{aligner}/raxml-ng/tree/best.newick",
        best_model  = "result/{sample}/{aligner}/raxml-ng/tree/best.model",
        ml_trees    = "result/{sample}/{aligner}/raxml-ng/tree/ml_trees.newick"
    output:
        "result/{sample}/{aligner}/raxml-ng/post/stats.iqtree"
    threads:
        get_highest_override( "iqtree", "threads" )
    params:
        workdir     = "result/{sample}/{aligner}/raxml-ng/post",
        modelstring = modelstring_params
    log:
        "result/{sample}/{aligner}/raxml-ng/post/iqtree.log"
    conda:
        "../envs/iqtree.yaml"
    shell:
        "iqtree -s {input.msa} -te {input.best_tree} -z {input.ml_trees}"
        " -m {params.modelstring}"
        " -pre {params.workdir}/stats -T {threads}"
        " -n 0 -zb 1000 -zw -au > {log}"

rule summarize_iqtree_stats_test:
    input:
        iqtree_stats    = "result/{sample}/{aligner}/raxml-ng/post/stats.iqtree",
        ml_trees        = "result/{sample}/{aligner}/raxml-ng/tree/ml_trees.newick"
    output:
        summary         = "result/{sample}/{aligner}/raxml-ng/post/significance.txt",
        plausible_trees = "result/{sample}/{aligner}/raxml-ng/post/plausible_trees.newick"
    script:
        "scripts/iqtree_test_summarize.py"

rule plausible_consensus:
    input:
        "result/{sample}/{aligner}/raxml-ng/post/plausible_trees.newick"
    output:
        mr  = "result/{sample}/{aligner}/raxml-ng/post/plausible.consensusTreeMR.newick",
        mre = "result/{sample}/{aligner}/raxml-ng/post/plausible.consensusTreeMRE.newick"
    params:
        prefix  = "result/{sample}/{aligner}/raxml-ng/post/plausible"
    log:
        mr  = "result/{sample}/{aligner}/raxml-ng/post/mr.log",
        mre = "result/{sample}/{aligner}/raxml-ng/post/mre.log"
    conda:
        "../envs/raxml-ng.yaml"
    shell:
        "raxml-ng --consense MR  --tree {input} --prefix {params.prefix} --redo > {log.mr}  2>&1 && "
        "mv {params.prefix}.raxml.consensusTreeMR {output.mr} && "
        "raxml-ng --consense MRE --tree {input} --prefix {params.prefix} --redo > {log.mre} 2>&1 && "
        "mv {params.prefix}.raxml.consensusTreeMRE {output.mre}"
