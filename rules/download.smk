# =================================================================================================
#     Obtaining the input sequences from genbank
# =================================================================================================

rule download_sequences:
    input:
        get_accessions
    output:
    	"{outdir}/result/{sample}/download/seqs.fa"
    log:
        "{outdir}/result/{sample}/download/dl.log"
    conda:
        "../envs/download.yaml"
    script:
        "scripts/download_fasta.py"
