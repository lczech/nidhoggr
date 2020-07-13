# =================================================================================================
#     Dependencies
# =================================================================================================

import pandas as pd
import os

# Ensure min Snakemake version
snakemake.utils.min_version("5.7")

# =================================================================================================
#     Pipeline Configuration
# =================================================================================================

# Load the config. If --directory was provided, this is also loaded from there.
# This is useful to have runs that have different settings, but generally re-use the main setup.
configfile: "config.yaml"
# snakemake.utils.validate(config, schema="../schemas/config.schema.yaml")

# =================================================================================================
#     Read Samples Table
# =================================================================================================

# Read samples and units table
samples = pd.read_table(config["data"]["samples"], dtype=str).set_index(["sample"], drop=False)
# samples.index = samples.index.set_levels([i.astype(str) for i in samples.index.levels])  # enforce str in index
# snakemake.utils.validate(samples, schema="../schemas/samples.schema.yaml")

# Transform for ease of use
sample_names=list(set(samples.index.get_level_values("sample")))

# Wildcard constraints: only allow sample names from the table to be used
wildcard_constraints:
    sample="|".join(sample_names)

# =================================================================================================
#     Pipeline User Output
# =================================================================================================

# Some helpful messages
logger.info("===========================================================================")
logger.info("    nidhoggr - snakemake pipeline to run phylogenetic tree inferences")
logger.info("")
logger.info("    Snakefile:          " + (workflow.snakefile))
logger.info("    Base directory:     " + (workflow.basedir))
logger.info("    Working directory:  " + os.getcwd())
logger.info("    Config files:       " + (", ".join(workflow.configfiles)))
logger.info("    Sample count:       " + str(len(sample_names)))
logger.info("===========================================================================")
logger.info("")

# =================================================================================================
#     Common File Access Functions
# =================================================================================================

def get_fasta(wildcards):
    """Get fasta files of given sample."""
    return samples.loc[wildcards.sample, "fasta"]
