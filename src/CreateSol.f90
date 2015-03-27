!##############################################################       
!     CreateSol: 
!       + Create .sol file
!       + The hessian is contructed from a bi-quadratic fit of the DEM
!           data contains in a circle of radius R (biqad.f90)
!       + Metric constructed by Metric.f90
!
! INPUT : "mesh2D_"i".mesh" contains the mesh description
! OUTPUT: "mesh2D_"i".sol" contains the metric associated to each node
!         "mesh2D_"i".vel" contains the interpolated velocity at each node
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble, France
!##############################################################       
subroutine CreateSol(fname)
  use DEMVar
  use metrics
  
  implicit none
  
  character*100 :: fname
  real,dimension(3) :: Metric,Hessian
  
  real,dimension(:), allocatable :: x,y
  real,dimension(:,:), allocatable :: coefs_blin
  real :: z, velocity
  integer :: i,nPoints
  character*100 :: filename,filename2
  character*1 :: YesNo,dumy
  logical :: Fexist
  
  
  ! read .mesh header
  write(filename,'(A,A)') trim(fname),'.mesh'
  inquire (file=filename,exist=Fexist)
  if (.NOT.Fexist) then
     write(*,*) 'File',trim(filename),'not existing'
     write(*,*) 'Stop'
     stop
  End if
  open(20,file=trim(filename),status='old')
  Do i=1,8
     read(20,*) 
  End do
  ! number of nodes
  read(20,*) NPoints
  read(20,*) 
  
  allocate(x(NPoints),y(NPoints),coefs_blin(NPoints,6))
  
  ! read .mesh nodes coordinates 
  Do i=1,nPoints
     read(20,*) x(i),y(i),z
  End do
  
  close(20)
  
!!! biquadratiq fit in the neighbourhood of each node (DEM data within a circle of radius R)
  call biquad(nx,ny,xmin, ymin, dx,dy,R,6,dem, nPoints, x, y, noval, coefs_blin)

  ! write .sol header
  write(filename,'(A,A)') trim(fname),'.sol'
  write(filename2,'(A,A)') trim(fname),'.vel'
  
  open(21,file=filename)
  write(21,'(A)') 'MeshVersionFormatted 1 '
  write(21,'(A)') 'Dimension'
  write(21,'(I1)') 2
  write(21,'(A)') 'SolAtVertices' 
  write(21,*) NPoints
  write(21,'(I1,2x,I1)') 1,3
  
  open(22,file=filename2)
  write(22,'(A)') 'MeshVersionFormatted 1 '
  write(22,'(A)') 'Dimension'
  write(22,'(I1)') 2
  write(22,'(A)') 'SolAtVertices' 
  write(22,*) NPoints
  write(22,'(I1,2x,I1)') 1,1
  
  ! and .sol Metric for each node
  Do i=1,nPoints
     
     Hessian(1)=coefs_blin(i,1)
     Hessian(2)=coefs_blin(i,2)
     Hessian(3)=coefs_blin(i,3)
     
     ! print *,Hessian(1),Hessian(2),Hessian(3)
     velocity = coefs_blin(i,6)
     
     
     if (abs(velocity-noval).lt.1.0e-3) then 
        Metric(1)=1.0/(Param2(2)*Param2(2))
        Metric(3)=0.0
        Metric(2)=1.0/(Param2(2)*Param2(2))
     else     
        if (velocity >= threshold) then
           param2use = Param
        else
           param2use = Param2
        end if
        select case(RefMode)
        case ('VelFudge')
           call ComputeMetric(velocity,param2use,Metric)
        case ('Hessian')
           call ComputeMetric(Hessian,param2use,Metric)
        case default
           print*,'Refinement mode not recognised'
           stop
        end select
     end if

     write(21,*) Metric(1),Metric(3),Metric(2)
     write(22,*) velocity
  End do
  
  write(21,'(A)') 'End'
  close(21)
  
  write(22,'(A)') 'End'
  close(22)
  
  deallocate(x,y)
  
  Return 
End subroutine CreateSol
