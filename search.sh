#!/bin/bash
set -e

BASE=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

OPTIND=1

verbose=0
threads=$(nproc)
do_align=0
datatype="nt"

die () {
    echo >&2 "ABORT: $@"
    exit 1
}

show_help() {
  echo "Usage: $0 [OPTION]... fasta_files..."
  echo "Options:"
  printf "  %s\t%s\n" "-h" "show help"
  printf "  %s\t%s\n" "-v" "increase verbosity"
  printf "  %s\t%s\n" "-t" "number of threads (default: ${threads})"
  printf "  %s\t%s\n" "-p" "prefix to fasta paths and output (useful to specify where data was mounted to in docker)"
  printf "  %s\t%s\n" "-a" "also align the input"
  printf "  %s\t%s\n" "-d" "Datatype, either 'aa' or 'nt' (default: ${datatype})"
}

while getopts "h?vt:ap:d:" opt; do
  case "$opt" in
  h|\?)
    show_help
    exit 0
    ;;
  v)  verbose=1
    ;;
  a)  do_align=1
    ;;
  t)  threads=$OPTARG
    ;;
  p)  prefix=$OPTARG
    ;;
  d)  datatype=$OPTARG
    ;;
  esac
done
shift $((OPTIND-1))

# input validation

# ensure threads is a number
int_regex='^[0-9]+$'
[[ $threads =~ $int_regex ]] || die "Invalid number of threads: $threads"

[[ $# -eq 0 ]] && die "Must supply some input fasta file(s)"

[[ ! -z $prefix ]] && [[ ! -d ${prefix} ]] && die "Prefix must be some valid directory path"
[[ ! -z $prefix ]] && [[ "${prefix}" != */ ]] && prefix="${prefix}/"

valid_datatypes="aa,nt"
[[ ! ",${valid_datatypes}," = *,${datatype},* ]] && die "Datatype (-d) must either be 'aa' or 'nt'"

# prepare samples.tsv for re-writing
SAMPLES=${BASE}/data/samples.tsv
head -n 1 ${SAMPLES} > tmp_samples.tsv && mv tmp_samples.tsv ${SAMPLES}

# copy fastas and update the samples.tsv
for fasta in $@ ;
do
  ppath=${prefix}${fasta}
  fname=${ppath##*/}
  name=${fname%.*}

  cp ${ppath} ${BASE}/data/

  echo -e "${name}\tdata/${fname}" >> ${SAMPLES}

done

if [[ $do_align -eq 1 ]];
then
  skip_alignment="False"
else
  skip_alignment="True"
fi

# I can't believe this is the quickest way to get an adjusted config file...
echo "# =================================================================================================
#     Input Data
# =================================================================================================

# Set the input data, using file paths relative to the directory where this config file is located.
data:

  # Input table of unaligned fasta files.
  samples: 'data/samples.tsv'

# =================================================================================================
#     Pipeline Settings
# =================================================================================================

settings:

  # If set to True, the files in the above samples table are assumed to already be aligned,
  # and the below list of alignment tools is not used.
  skip_alignment: ${skip_alignment}

  # Select the tool(s) used for sequence alignment.
  # Valid values: 'mafft', 'muscle'
  aligner:
    - 'mafft'
    - 'muscle'

  threads: ${threads}
# =================================================================================================
#     Tool Parameters
# =================================================================================================

params:
  # ----------------------------------------------------------------------
  #     mafft
  # ----------------------------------------------------------------------

  mafft:
    threads: ${threads}
    extra: '--auto'

  # ----------------------------------------------------------------------
  #     muscle
  # ----------------------------------------------------------------------

  muscle:
    extra: ''

  # ----------------------------------------------------------------------
  #     usearch
  # ----------------------------------------------------------------------

  usearch:
    command: '/usr/local/bin/usearch'

  # ----------------------------------------------------------------------
  #     ParGenes
  # ----------------------------------------------------------------------

  pargenes:
    # Set the command to run ParGenes, including the python command to execute.
    command: 'python3 ~/ParGenes/pargenes/pargenes.py'
    threads: ${threads}

    # Other options to run ParGenes with.
    extra: '--use-modeltest'
    parsimony_starting_trees: 50
    random_starting_trees: 50
    bs_trees: 1000
    datatype: '${datatype}'

  # ----------------------------------------------------------------------
  #     RAxML-ng
  # ----------------------------------------------------------------------

  raxmlng:
    # Set the command to run RAxML-ng. Can re-use the binary from ParGenes, but does not have to.
    command: '~/ParGenes/raxml-ng/bin/raxml-ng'

  # ----------------------------------------------------------------------
  #     IQTree
  # ----------------------------------------------------------------------

  iqtree:
    extra: ''
" > ${BASE}/pasta.yaml

# run the pipeline, with adjusted config
cd ${BASE}
snakemake --use-conda --cores ${threads} --configfile ${BASE}/pasta.yaml

[[ ! -z $prefix ]] && cp -R result/ ${prefix}result
