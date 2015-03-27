
#
Executables= $(EXEDIR)/MakeGeo \
             $(EXEDIR)/GeoToMesh \
	     $(EXEDIR)/Make2DMesh \

#
Routines = $(OBJDIR)/DEMVar.o $(OBJDIR)/Initialisation.o $(OBJDIR)/READ_DEM.o $(OBJDIR)/CreateSol.o $(OBJDIR)/Metrics.o $(OBJDIR)/biquad.o $(OBJDIR)/MeshToElmer.o 
Routines := $(Routines) $(OBJDIR)/StereoPolarProj.o


$(EXEDIR)/MakeGeo : $(SRCDIR)/MakeGeo.f90 $(OBJDIR)/StereoPolarProj.o
	$(F90) $(FFLAGS) $^ -o $@

$(EXEDIR)/GeoToMesh: $(SRCDIR)/GeoToMesh.f90
	$(F90) $(FFLAGS) $^ -o $@


$(EXEDIR)/Make2DMesh : $(SRCDIR)/Make2DMesh.f90 $(Routines) 
	$(F90) $(FFLAGS)  $^ -o $@ $(LAPACK)

$(OBJDIR)/DEMVar.o : $(SRCDIR)/DEMVar.f90
	$(F90) $(FFLAGS) -c $^ -o $@

$(OBJDIR)/Initialisation.o: $(SRCDIR)/Initialisation.f90 $(OBJDIR)/DEMVar.o
	$(F90) $(FFLAGS) -c $^ -o $@

$(OBJDIR)/READ_DEM.o : $(SRCDIR)/READ_DEM.f90 $(OBJDIR)/DEMVar.o 
	$(F90) $(FFLAGS) -c $^ -o $@

$(OBJDIR)/CreateSol.o : $(SRCDIR)/CreateSol.f90 $(OBJDIR)/DEMVar.o  $(OBJDIR)/Metrics.o 
	$(F90) $(FFLAGS) -c $^ -o $@

$(OBJDIR)/Metrics.o : $(SRCDIR)/Metrics.f90 $(OBJDIR)/DEMVar.o 
	$(F90) $(FFLAGS) -c $^ -o $@

$(OBJDIR)/biquad.o : $(SRCDIR)/biquad.f90
	$(F90) $(FFLAGS) $(LAPACK) -c $^ -o $@

$(OBJDIR)/MeshToElmer.o : $(SRCDIR)/MeshToElmer.f90
	$(F90) $(FFLAGS) -c $^ -o $@

$(OBJDIR)/StereoPolarProj.o: $(SRCDIR)/StereoPolarProj.f90
	$(F90) $(FFLAGS) -c $^ -o $@