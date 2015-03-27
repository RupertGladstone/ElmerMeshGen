ElmerMeshGen
============

Examples of generating refined unstructured meshes for use with Elmer multi physics finite element code.

Author Fabien Gillet-Chaulet 2013, further modifications from Rupert Gladstone (rupertgladstone1972@gmail.com)

These directories can be obtained from a public github repository:


Note that gmsh and yams will need to be installed (and elmer, elmergrid, and possibly other libraries such as 
scalapack/lapack/blas).  There are some informal notes on installing these in installNotes.asc.


Directory structure
===================

"utils" *** add notes ***

"drawBoundary" contains matlab scripts to facilitate creation of a boundary.  This boundary would be hand drawn 
by interactively selecting points on a figure showing velocities (or it could easily be modified to use, for 
example, surface elevation).  The scripts also extract the relevant subregion for velocity, bedrock and surface 
elevation files, along with relevant metadata.  They assume that the input data are gridded netcdf files.

"refineMesh" contains Fab's scripts to use Yams for mesh refinement.  Copy the files created in drawBoundary into 
this directory.  The .geo file must be renamed Contour.geo.  Use the Yams inputs file to edit the input.txt file 
in the refineMesh directory.  Then just run make at the command line.


"meshExtrusion" ***NYI***
The refined mesh created by scripts in the above directories is a 2D footprint.  This directory contains a 
simple elmer sif file to read in the bedrock and surface elevation data from netcdf files and extrude the 
2D footprint mesh to 3D.


Code Improvements
=================

If these scripts become useful then I will try to improve/maintain them.  Email bugs to me or report through 
github.  Same with requested improvements.

