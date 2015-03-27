!##############################################################       
!     DEMVar
!       + module for the general variables (DEM defintion and values and
!       YAMS parameters)
!
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble, France
!###########################################################     
module DEMVar
  real,allocatable :: DEM(:,:)
  real :: xmin,ymin,dx,dy,noval,R, threshold
  real,dimension(3) :: Param, Param2, param2use  !hmin,hmax,err
  integer :: nx,ny
  character(250) :: VelDem
  character(50)  :: RefMode
  integer :: DEM_nx,DEM_ny
  real ::DEM_xmin,DEM_ymin,DEM_dx,DEM_dy,DEM_noval
end module DEMVar
