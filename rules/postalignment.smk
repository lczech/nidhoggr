# =================================================================================================
#     Rules regarding post-alignment cleanup tasks
# =================================================================================================

# =================================================================================================
#     MSA trimming
# =================================================================================================

# special rule that skips trimming / does nothing
rule trim_skipped:
    input:
        "{outdir}/result/{sample}/{aligner}/aligned.afa"
    params:
        rel_input = relative_input_path,
    output:
        "{outdir}/result/{sample}/{aligner}/no_trim/trimmed.afa"
    log:
        "{outdir}/result/{sample}/{aligner}/no_trim/trim.log"
    shell:
        "ln -s {params.rel_input} {output}"

rule trim_gblocks:
    input:
        "{outdir}/result/{sample}/{aligner}/aligned.afa"
    params:
        datatype    = ('p' if config["settings"]["datatype"] == 'aa' else 'd'),
        rel_input   = relative_input_path,
        extra       = config["params"]["gblocks"]["extra"]
    output:
    	"{outdir}/result/{sample}/{aligner}/gblocks/trimmed.afa"
    log:
        "{outdir}/result/{sample}/{aligner}/gblocks/trim.log"
    conda:
        "../envs/gblocks.yaml"
    shell:
        # somehow gblocks returns a non-zero exit value regardless of success or failure?!
        "$(gblocks {input} -t={params.datatype} {params.extra} > {log} ; echo '' )"
        " && ln -s {params.rel_input}-gb {output}"

rule trim_trimal:
    input:
        "{outdir}/result/{sample}/{aligner}/aligned.afa"
    params:
        extra = config["params"]["trimal"]["extra"]
    output:
        "{outdir}/result/{sample}/{aligner}/trimal/trimmed.afa"
    log:
        "{outdir}/result/{sample}/{aligner}/trimal/trim.log"
    conda:
        "../envs/trimal.yaml"
    shell:
        "trimal -in {input} -out {output} -fasta -automated1 {params.extra} 2> {log}"

# =================================================================================================
#     Remove duplicates
# =================================================================================================
