from shutil import rmtree, copyfile, copytree
import os
import sys
import stat
import subprocess

# =================================================================================================
#     Error Handling
# =================================================================================================

def fail( msg ):
  print( "ERROR: " + msg )
  sys.exit(1)

# =================================================================================================
#     Input Validation
# =================================================================================================

def expect_dir_exists( dir_path ):
  if not os.path.isdir( dir_path ):
    fail( "Directory doesn't exist: " + dir_path )

def expect_file_exists( file_path ):
  if not os.path.isfile( file_path ):
    fail( "File doesn't exist: " + file_path )

def expect_executable_exists( executable ):
  import distutils.spawn
  if not distutils.spawn.find_executable( executable ):
    fail( "Executable not found: " + executable )

def parse_file_path( file_path ):
  file_path = os.path.normpath( file_path )
  expect_file_exists( file_path )
  return file_path

def parse_dir_path( dir_path ):
  dir_path = os.path.normpath( dir_path )
  expect_dir_exists( dir_path )
  return dir_path

def parse_executable_path( executable_path ):
  executable_path = os.path.normpath( executable_path )
  expect_executable_exists( executable_path )
  return executable_path

# =================================================================================================
#     File System Manipulation
# =================================================================================================

def splitpath(path, maxdepth=20):
  path = os.path.normpath(path) 
  ( head, tail ) = os.path.split(path)
  return splitpath(head, maxdepth - 1) + [ tail ] if maxdepth and head and head != path else [ head or tail ]

def copy( src, dest ):
  copyfile( src, dest )

def copy_dir( src, dest, ignore=None ):
  if ignore:
    ign_f = shutil.ignore_patterns(*ignore)
  else:
    ign_f = None
  copytree( src, dest, ignore=ign_f )

def clean_dir( path ):
  if os.path.exists( path ):
    rmtree( path, ignore_errors=True )

def clean_file ( path ):
  if os.path.exists( path ):
    os.remove( path )

def chmod_path( path ):
  if not os.path.isdir( path ):
    raise RuntimeError( "Directory doesn't exist: " + path )
  else:
    os.chmod( path, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO )

def chmod_file( file_path ):
  if not os.path.isfile( file_path ):
    raise RuntimeError( "File doesn't exist: " + file_path )
  else:
    os.chmod( file_path, stat.S_IRUSR|stat.S_IWUSR|stat.S_IRGRP|stat.S_IWGRP|stat.S_IROTH|stat.S_IWOTH )

def mkdirp( path ):
  if not os.path.exists( path ):
    os.mkdir( path )
    chmod_path( path )

def make_path( path ):
  if not os.path.exists( path ):
    os.makedirs( path )
    chmod_path( path )

def make_path_clean( path ):
  clean_dir( path )
  make_path( path )

# =================================================================================================
#     String Functions
# =================================================================================================

"""
  returns the first occurence of the string matching
  .*${marker1}${input_str}${marker2}.*  (bash notation)

  the function does not check that such a string exists
"""
def find_string_between(input_str, marker1, marker2):
  start = input_str.find(marker1) + len(marker1)
  end = input_str.find(marker2, start)
  return input_str[start:end]

# =================================================================================================
#     System Functions
# =================================================================================================

def num_pyhsical_cores():
  out = subprocess.check_output(['lscpu', '--parse=Core,Socket'], encoding = 'utf-8')
  out = out.split('\n')
  num_cores = len(
     dict.fromkeys(
       [line for line in out if not line.startswith('#') and line != '']
  ))
  return num_cores
