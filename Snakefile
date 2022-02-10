include: "rules/common.smk"

# =================================================================================================
#     Default "All" Target Rule
# =================================================================================================

# Depending on the config, we either use the given alignment tools, or skip the alignment step
# and use the input sequence files from the sample table directly for tree inference.
# As we want to allow to use multiple alignment tools, we have to keep these tools as part
# of the file paths of all our result files... Hence, for skipping the alignment step, we also
# need a special case that acts as if it was an aligner, but is not. We call this "apriori"
# algiment in the result files.
aligner_list = ( "apriori" if config["settings"]["skip_alignment"] else config["settings"]["aligner"] )

# list of post-alignment trimming tools
trimmer_list = config["settings"]["trimmer"]

# The rule that is executed by default. It requests the final output files,
# which are then created by applying snakemake rules.
rule all:
    input:
        # Best ML tree and associated model
        expand(
            "{outdir}/result/{sample}/{aligner}/{trimmer}/raxml-ng/tree/best.newick",
            outdir=outdir,
            aligner=aligner_list,
            trimmer=trimmer_list,
            sample=sample_names
        ),
        expand(
            "{outdir}/result/{sample}/{aligner}/{trimmer}/raxml-ng/tree/best.model",
            outdir=outdir,
            aligner=aligner_list,
            trimmer=trimmer_list,
            sample=sample_names
        ),
        # Best ML tree with support values
        expand(
            "{outdir}/result/{sample}/{aligner}/{trimmer}/raxml-ng/tree/bootstrap.newick",
            outdir=outdir,
            aligner=aligner_list,
            trimmer=trimmer_list,
            sample=sample_names
        ),

        # Consensus trees from best tree set
        expand(
            "{outdir}/result/{sample}/{aligner}/{trimmer}/raxml-ng/tree/consensusTreeMR.newick",
            outdir=outdir,
            aligner=aligner_list,
            trimmer=trimmer_list,
            sample=sample_names
        ),
        expand(
            "{outdir}/result/{sample}/{aligner}/{trimmer}/raxml-ng/tree/consensusTreeMRE.newick",
            outdir=outdir,
            aligner=aligner_list,
            trimmer=trimmer_list,
            sample=sample_names
        ),

        # iqtree stats summary
        # expand(
        #     "result/{sample}/{aligner}/{trimmer}/raxml-ng/post/significance.txt",
        #     aligner=aligner_list,
        #     sample=sample_names
        # ),

        # # consensus trees based on plausible tree set
        # expand(
        #     "result/{sample}/{aligner}/{trimmer}/raxml-ng/post/plausible.consensusTreeMR.newick",
        #     aligner=aligner_list,
        #     sample=sample_names
        # ),
        # expand(
        #     "result/{sample}/{aligner}/{trimmer}/raxml-ng/post/plausible.consensusTreeMRE.newick",
        #     aligner=aligner_list,
        #     sample=sample_names
        # )

# The main `all` rule is local. It does not do anything anyway,
# except requesting the other rules to run.
localrules: all

# =================================================================================================
#     Rule Modules
# =================================================================================================

include: "rules/download.smk"
include: "rules/align.smk"
include: "rules/postalignment.smk"
include: "rules/treesearch.smk"
include: "rules/postanalysis.smk"
