!##############################################################       
!     Make2DMesh: 
!       + perform mesh adaptation using YAMS
!
!       1) Initialisation (Initialiase.f90: read input and velocity DEM)
!       2) Create the metric (CreateSol.f90)
!       3) Run YAMS
!       4) show result using medit
!       5) go back to 2 or
!       6) convert final mesh in msh format
!
! INPUT : "mesh2D_1.mesh" (mesh file produced with GeoToMesh.f90)
!         "input.txt" input file
!
! OUTPUT: "mesh2D.msh" and mesh2D Elmer mesh format (2D mesh file optiomized with YAMS in gmsh format)
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble
!##############################################################       
!!!!!!!! 
!       Parametres d'entree pour YAMS lus dans le fichier "input.txt"
!           (initialisé dans la routine Initialisation)
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      program Make2DMesh
      use DEMVar
      implicit none
      integer :: i,j
      integer :: imax=8
      character*100 :: fname,fname2,finname
      character*120 :: DoYams,UxCom,DoMed
      character*1:: YesNo


      !!!! Initialise (read input.txt and velocity DEM)
      call Initialisation 

      Do i=1,imax
         write(fname,'(A,I1)') 'mesh2D_',i

          !!! create the .sol file (contains the metric for YAMS)
          call CreateSol(fname)

          !!! RUN YAMS (cf YAMS Documentation for DEFAULT parameters, e.g. gradation may be changed in DEFAULT.yams
          write(DoYams,'(A,A)') 'yams -O 1 -v 10 -b -f  ', trim(fname)
          call system(DoYams)

          !!! show the results using medit
          write(DoMed,'(A,A,2x,A,A)') 'medit  ',trim(fname), trim(fname),'.d'
          call system(DoMed)
          
          if (i.eq.imax) exit

          write(*,*) 'Continue? Yes/No'
          read(*,*)  YesNo
          if (.NOT.((YesNo.eq.'Y').OR.(YesNo.eq.'y'))) exit
           
          !!!! go to next step
          write(fname2,'(A,I1)') 'mesh2D_',i+1
          write(UxCom,'(5A)') 'cp ',trim(fname),'.d.mesh  ',trim(fname2),'.mesh  '
          call system(UxCom)

      End do

      !!!!! convert to gmsh and elmer format
      write(finname,'(A,A)') trim(fname),'.d'
      call MeshToElmer(finname)

      end
