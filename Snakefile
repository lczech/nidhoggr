include: "rules/common.smk"

# =================================================================================================
#     Default "All" Target Rule
# =================================================================================================

# The rule that is executed by default. It requests the final output files,
# which are then created by applying snakemake rules.
rule all:
    input:
        expand(
            "trees/pargenes/{aligner}/{sample}-best.newick",
            aligner=config["settings"]["aligner"],
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
