import sys
import util
from Bio import AlignIO
from collections import Counter

def has_at_least_n_nongap( column, n, datatype ):
	gap_chars = "X*-?." if datatype == 'aa' else "NOX.-?"
	counts = Counter( map(str.upper, column) )

	# tally up the counts of all gap chars
	num_gap_chars = 0
	for g in gap_chars:
		if g in counts.keys():
			num_gap_chars = num_gap_chars + counts[g]

	return (len(column) - num_gap_chars) >= n

def trim_ends( input_file, output_file, n=4, datatype='nt' ):
	"""Trims alignment to first and last columns that contain at least 'n' non-gap characters"""
	if not datatype in ['nt', 'aa']:
		util.fail("datatype must be either 'nt' or 'aa', instead '{}' was passed.".format(datatype)) 

	util.expect_file_exists( input_file )

	aln = AlignIO.read( open(input_file), "fasta" )

	start = 0
	finish = aln.get_alignment_length() - 1

	while not has_at_least_n_nongap( aln[:, start], n, datatype ) and start <= finish:
		start = start + 1

	while not has_at_least_n_nongap( aln[:, finish], n, datatype ) and finish > 0:
		finish = finish - 1

	if finish <= start:
		util.fail(
			"Alignment '{}' did not contain any columns that contained at least {} IUPAC chars!"
			.format( input_file, n ))
	# end of slice is exclusive, but right now finish is still an index to the last viable column
	finish = finish + 1    

	AlignIO.write( aln[:, start:finish], open(output_file, "w"), "fasta" )

with open(snakemake.log[0], "w") as f:
	sys.stderr = sys.stdout = f
	trim_ends( snakemake.input[0],
		snakemake.output[0],
		n=snakemake.params.n,
		datatype=snakemake.params.datatype )

# trim_ends( "test.afa",
#         "cleaned.afa",
#         n=4,
#         datatype='nt' )
