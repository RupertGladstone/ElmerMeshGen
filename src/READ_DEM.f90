!##############################################################       
!     READ_DEM
!       + read the velocity data used to create the metric
!       + has to initialise : nx,ny,xmin,ymin,dx,dy,noval,dem(nx,ny)
!       +  Typically to be modified by the user in function of the data set format
!
! INPUT : "../Data/GreenlandVelocity.dem" Greenland velocity DEM produced from
!            I. Joughin data sets available in the nsidc website
! OUTPUT: nx,ny,xmin,ymin,dx,dy,noval,dem(nx,ny)
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble
!##############################################################       
subroutine  READ_DEM(DEM_fname)
  use DEMVar
  
  ! real,allocatable :: DEM(:,:)
  ! real :: xmin,ymin,dx,dy,noval,R, threshold
  ! real,dimension(3) :: Param, Param2  !hmin,hmax,err
  ! integer :: nx,ny
  
  implicit none
  
  character(*) :: DEM_fname
  integer :: i,j
  real :: u,v,e
  
  nx=DEM_nx
  ny=DEM_ny
  xmin=DEM_xmin
  ymin=DEM_ymin
  dx=DEM_dx
  dy=DEM_dy
  noval=DEM_noval
  
  Allocate(dem(DEM_nx,DEM_ny))
  !'/mnt/hgfs/VM_share/GreenlandVelocity.dem'
  open(10,file=DEM_fname)
  Do j=1,DEM_ny
     Do i=1,DEM_nx
        read(10,*) u,v,e
        if ((u.lt.-1.0e06).or.(v.lt.-1.0e06)) then
           dem(i,j)=DEM_noval
        else
           dem(i,j)=sqrt(u*u+v*v)
        endif
     End do
  End do
  close(10)

End subroutine READ_DEM
