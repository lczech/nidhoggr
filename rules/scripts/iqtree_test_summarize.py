import sys
import util

# courtesy of Github BenoitMorel/covid19_cme_analysis
def extract_tests_results( iqtree_tests_file ):
  # this is a very quick and dirty implementation...
  lines = open( iqtree_tests_file ).readlines()
  begin = 0
  end = 0
  for i in range(0, len( lines )):
    if lines[i] == "USER TREES\n":
      begin = i
    if lines[i] == "TIME STAMP\n":
      end = i
  res = []
  for line in lines[begin: end]:
    if (line.strip().split(" ")[0].isdigit()):
      res.append( line.replace("\n", "") )
  return res

def filter_accepted_trees( iqtree_tests_file, ml_trees_file ):
  ml_trees = open( ml_trees_file ).readlines()
  iqtree_lines = extract_tests_results( iqtree_tests_file )
  accepted_trees = []
  for i in range(0, len( iqtree_lines )):
    line = iqtree_lines[i]
    plus_count = line.count(" + ")
    minus_count = line.count(" - ")
    assert(plus_count + minus_count == 7)
    if minus_count == 0:
      accepted_trees.append(ml_trees[i])
  return accepted_trees

iqtree_stats_file = util.parse_file_path( snakemake.input.iqtree_stats )
ml_trees          = util.parse_file_path( snakemake.input.ml_trees )
plausible_trees_file = snakemake.output.plausible_trees

accepted_trees = filter_accepted_trees( iqtree_stats_file, ml_trees )
with open( snakemake.output.summary, "w+" ) as writer:
  writer.write( str( len( accepted_trees ) ) + " tree passed all IQTree consistency tests\n")

with open( plausible_trees_file, "w+" ) as writer:
  for tree in accepted_trees:
    writer.write( tree )