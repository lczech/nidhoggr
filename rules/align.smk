# =================================================================================================
#     Dummy for when input is already aligned
# =================================================================================================

rule align_apriori:
    input:
        get_fasta
    output:
        "{outdir}/result/{sample}/apriori/msa/aligned.fasta"
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
        "{outdir}/result/{sample}/mafft/msa/aligned.fasta"
    params:
        extra=config["params"]["mafft"]["extra"]
    threads:
        config["params"]["mafft"]["threads"]
    log:
        "{outdir}/result/{sample}/mafft/alignment.log"
    benchmark:
        "{outdir}/benchmarks/mafft/{sample}.bench.log"
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
        "{outdir}/result/{sample}/muscle/msa/aligned.fasta"
    params:
        extra=config["params"]["muscle"]["extra"]
    log:
        "{outdir}/result/{sample}/muscle/alignment.log"
    benchmark:
        "{outdir}/benchmarks/muscle/{sample}.bench.log"
    conda:
        "../envs/muscle.yaml"
    shell:
        "muscle -in {input} -out {output} {params.extra} > {log} 2>&1"
