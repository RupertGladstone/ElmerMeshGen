
##########################
F90=gfortran
FFLAGS = 

##########################
SRCDIR=../src
OBJDIR=objects
EXEDIR=.

# libraries  utilise une librarie scalapack
LAPACK=-L/usr/lib -lblas -llapack

all: Mesh2D

#############
include $(SRCDIR)/Makefile

Mesh2D: cleanyams cleanMesh2D compile
#	@echo '**************************************************'
#	@echo '**  Creating 2D mesh with yams              ******'
#	@echo '**************************************************'
#	@echo 
#	@echo 
#	@echo 
#	@echo '**************************************************'
#	@echo '**  Creating GMSH input file               ******'
#	@echo '**************************************************'
#	$(EXEDIR)/MakeGeo
#	@echo 
#	@echo 
#	@echo 
	@echo '**************************************************'
	@echo '**  Convert to mesh format                  ******'
	@echo '**************************************************'
	$(EXEDIR)/GeoToMesh
	@echo 
	@echo 
	@echo 
	@echo '**************************************************'
	@echo '**  Create 2D mesh                  ******'
	@echo '**************************************************'
	$(EXEDIR)/Make2DMesh

compile:$(EXEDIR)/MakeGeo  $(EXEDIR)/GeoToMesh $(EXEDIR)/Make2DMesh

cleanMesh2D:
	rm -f -r mesh2D


cleanyams:
	rm -f *.mesh *.sol *.msh *.vel
	rm -f *.vtk

clean	:
	rm -f $(Executables)  
	rm -f ExtrudeMesh
	rm -f $(OBJDIR)/*.o
	rm -f *~
	rm -f $(SRCDIR)/*~

cleanall: clean cleanyams  cleanMesh2D
