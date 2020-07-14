# =================================================================================================
#     Dummy for when input is already aligned
# =================================================================================================

rule align_apriori:
    input:
        get_fasta
    output:
        "aligned/apriori/{sample}/sample.fasta"
    shell:
        "cp {input} {output}"

# =================================================================================================
#     Alignment with mafft
# =================================================================================================

rule align_mafft:
    input:
        # `get_fasta` is defined in common.smk and takes the {sample} argument to return its path.
        # No need to pass the sample name - this is handed over to the function by snakemake magic.
        get_fasta
    output:
        "aligned/mafft/{sample}/sample.fasta"
    params:
        extra=config["params"]["mafft"]["extra"]
    threads:
        config["params"]["mafft"]["threads"]
    log:
        "logs/mafft/{sample}.log"
    benchmark:
        "benchmarks/mafft/{sample}.bench.log"
    conda:
        "../envs/mafft.yaml"
    shell:
        "mafft {params.extra} --thread {threads} {input} > {output} 2> {log}"

# =================================================================================================
#     Alignment with muscle
# =================================================================================================

rule align_muscle:
    input:
        # `get_fasta` is defined in common.smk and takes the {sample} argument to return its path.
        # No need to pass the sample name - this is handed over to the function by snakemake magic.
        get_fasta
    output:
        "aligned/muscle/{sample}/sample.fasta"
    params:
        extra=config["params"]["muscle"]["extra"]
    log:
        "logs/muscle/{sample}.log"
    benchmark:
        "benchmarks/muscle/{sample}.bench.log"
    conda:
        "../envs/muscle.yaml"
    shell:
        "muscle -in {input} -out {output} {params.extra} > {log} 2>&1"
