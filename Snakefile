include: "rules/common.smk"

# =================================================================================================
#     Default "All" Target Rule
# =================================================================================================

# The rule that is executed by default. It requests the final output files,
# which are then created by applying snakemake rules.
rule all:
    input:
        # Best ML tree
        expand(
            "trees/pargenes/{aligner}/{sample}-best.newick",
            aligner=config["settings"]["aligner"],
            sample=sample_names
        ),

        # Consensus trees from best tree set
        expand(
            "trees/pargenes/{aligner}/{sample}-ml-trees.raxml.consensusTreeMR",
            aligner=config["settings"]["aligner"],
            sample=sample_names
        ),
        expand(
            "trees/pargenes/{aligner}/{sample}-ml-trees.raxml.consensusTreeMRE",
            aligner=config["settings"]["aligner"],
            sample=sample_names
        )

rule skip_align:
    input:
        # Best ML tree
        expand(
            "trees/pargenes/apriori/{sample}-best.newick",
            sample=sample_names
        ),

        # Consensus trees from best tree set
        expand(
            "trees/pargenes/apriori/{sample}-ml-trees.raxml.consensusTreeMR",
            sample=sample_names
        ),
        expand(
            "trees/pargenes/apriori/{sample}-ml-trees.raxml.consensusTreeMRE",
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
