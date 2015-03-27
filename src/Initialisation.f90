!##############################################################       
!     Initialisation: 
!       + Read "input.txt"
!       + and velocity DEM
!
! INPUT : "input.txt" 
! OUTPUT: varaibles contains in DEMVar (YAMS and velocity DEM pârameters)
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble
!##############################################################       
subroutine  Initialisation
  use DEMVar
  
  implicit none
  
  real :: hmin,hmax,err,hmin2,hmax2,err2
  character*1 :: YesNo

  NAMELIST /list_input/VelDem,RefMode,R,hmin,hmax,err,hmin2,hmax2,err2,threshold, &
       DEM_nx,DEM_ny,DEM_xmin,DEM_ymin,DEM_dx,DEM_dy,DEM_noval
     
  OPEN(12, file='input.txt', form='formatted', status='old')
  READ(12, nml=list_input)
  CLOSE(12)
  
  Param(1)=hmin
  Param(2)=hmax
  Param(3)=err
  
  Param2(1)=hmin2
  Param2(2)=hmax2
  Param2(3)=err2
  
  CALL READ_DEM(trim(VelDem))
  
  write(*,*) '----------------------------------------------------'
  Write(*,*) 'xmin,ymin',xmin,ymin
  write(*,*) 'dx,dy',dx,dy
  Write(*,*) 'noval',Noval
  Write(*,*) 'R',R
  Write(*,*) 'Yams  hmin,hmax,err',Param(1),Param(2),Param(3)
  Write(*,*) 'Yams  threshold',threshold
  Write(*,*) 'Yams  hmin2,hmax2,err2',Param2(1),Param2(2),Param2(3)
  write(*,*) '----------------------------------------------------'
!  write(*,*) 'Continue? Yes/No'
!  read(*,*)  YesNo
!  if (.NOT.((YesNo.eq.'Y').OR.(YesNo.eq.'y'))) stop
  
End subroutine Initialisation
