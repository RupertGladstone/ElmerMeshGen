!#########################################################################
! MeshToElmer:
!    + transform the final mesh to Elmer format
!    + we need to convert first to .gmsh format
!    + some mesh transformation is required to go from .mesh to .msh
!         suppress empty lines and has to change dimension from 2 to 3
!
!
!   INPUT : final mesh2D_"i".mesh
!   OUTPUT : final mesh in GMSH format (mesh2D.msh) and Elmer format 
!
!   Author: F. Gillet-Chaulet, LGGE, Grenoble, France
!##########################################################################
subroutine MeshToElmer(fname)
  implicit none
  INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(12)
  real(dp) :: pi
  real(dp)   :: x,y,x1,y1,lat,lon
  character*100 :: fname
  character*100 :: uxcom,test
  integer :: i, np
  character*1 :: dumy
  
  pi=Dacos(-1.0_dp)
  
  
  call system('rm -f tmp.mesh')
  
  write(UxCom,'(A,A,A)') 'cp  ',trim(fname),'.mesh  tmp.mesh'
  write(*,*) UxCom
  call system(UxCom)
  
  call system('sed -i "/^$/d" tmp.mesh')
  
  call system('rm -f fin.mesh')
  
  write(UxCom,'(A)') 'cat tmp.mesh  | grep -v "^ "   > fin.mesh'
  write(*,*) UxCom
  call system(UxCom)
  
  open(11,file='fin.mesh')
  Do i=1,5
     read(11,*) dumy
  End do
  read(11,*) nP
  PRINT *, nP
  
  
  open(12,file='tmp.mesh');
  write(12,'(A)') 'MeshVersionFormatted'
  write(12,'(A)') '1'
  write(12,'(A)') 'Dimension '
  write(12,'(A)') '3'
  write(12,'(A)') 'Vertices'
  write(12,*) nP
  
  
  Do i=1,np
     read(11,*) x,y,dumy
     write(12,'(e13.7,x,e13.7,xe13.7,x,i1)') x,y,0.0,1
  End do
  
  close(11)
  close(12)
  
  
  
  write(test,*)np+6
  write(uxCom,*) 'tail -n +',trim(adjustl(test)), &
       ' fin.mesh > tmp2.mesh'
  call system(uxCom)
  
  call system('cat tmp.mesh tmp2.mesh > mesh2D.mesh')
  
  call system('rm -f tmp.mesh')
  call system('rm -f tmp2.mesh')
  call system('rm -f fin.mesh')
  
  call system('rm -f mesh2D.msh')
  call system('gmsh -1 -2 mesh2D.mesh mesh2D.msh')
  call system('ElmerGrid 14 2 mesh2D.msh -autoclean')
  
End subroutine MeshToElmer

