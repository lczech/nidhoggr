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

# The rule that is executed by default. It requests the final output files,
# which are then created by applying snakemake rules.
rule all:
    input:
        # Best ML tree
        expand(
            "trees/pargenes/{aligner}/{sample}-best.newick",
            aligner=aligner_list,
            sample=sample_names
        ),
        # Best ML tree with support values
        expand(
            "trees/pargenes/{aligner}/{sample}.bootstrap.newick",
            aligner=aligner_list,
            sample=sample_names
        ),
        expand(
            "trees/pargenes/{aligner}/{sample}.transfer-bootstrap.newick",
            aligner=aligner_list,
            sample=sample_names
        ),

        # Consensus trees from best tree set
        expand(
            "trees/pargenes/{aligner}/{sample}-ml-trees.raxml.consensusTreeMR",
            aligner=aligner_list,
            sample=sample_names
        ),
        expand(
            "trees/pargenes/{aligner}/{sample}-ml-trees.raxml.consensusTreeMRE",
            aligner=aligner_list,
            sample=sample_names
        )

# The main `all` rule is local. It does not do anything anyway,
# except requesting the other rules to run.
localrules: all

# =================================================================================================
#     Rule Modules
# =================================================================================================

include: "rules/align.smk"
include: "rules/treesearch.smk"
