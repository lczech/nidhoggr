Overview
============

Profiles that might come in handy when running the pipeline in a cluster environment.
The `slurm` profile is based on the snakemake profile cookiecutter template for slurm from
https://github.com/Snakemake-Profiles/slurm

However, we extended it as follows:
 - Slurm log files are collected in a subdirectory, instead of cluttering the main directory.
 - Using the `host` config files, specific configurations for each host can be provided.

For now, we use a fixed cluster configuration file that needs to be adapted to contain
the specifics of the given cluster environment.

Usage
============

Direct usage example: `snakemake --profile profiles/slurm` for the `slurm` profile.

Alternatively, snakemake looks for profiles in `~/.config/snakemake`. Hence, you can also copy
the contents of the `slurm` subdirectory and the `cluster-config.yaml` to that location,
and then do not need to specify `--profile` when calling snakemake.
