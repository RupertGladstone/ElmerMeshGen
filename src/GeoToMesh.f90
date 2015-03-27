!##############################################################       
!     GeoToMesh: 
!       + Run gmsh to produce mesh file from file Contour.geo       
!       + Do some format conversion (change dimension from 3 to 2)
!
! INPUT : "Contour.geo" (GMSH geo file made from ythe contour of the domain)
! OUTPUT: "mesh2D_1.mesh" (mesh file used by Make2DMesh.f90 for YAMS mesh adaptation)       
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble, France
!##############################################################       
       program GeoToMesh
       implicit none
       real, dimension(:,:) , allocatable :: xy_c,xy_b
       real :: lc=2500.0
       real :: x,y,zero
       real :: dumyR
       integer :: np_c,np_b,np
       integer :: i,j
       integer :: compt,compt2
       character*100 :: uxcom,test
       character*1 :: dumy


!  Cree maillage en format mesh
       call system('gmsh  Contour.geo -1 -2  -format mesh')

!  need to change dimension from 3 to 2 to be used with yams
       open(11,file='Contour.mesh');
       read(11,*) dumy
       read(11,*) dumy
       read(11,*) dumy
       read(11,*) dumy
       read(11,*) nP

       open(12,file='tmp.mesh')
       write(12,*) '  '
       write(12,*) 'MeshVersionFormatted'
       write(12,*) 1
       write(12,*) '  '
       write(12,*) 'Dimension'
       write(12,*) 2
       write(12,*) '  '
       write(12,*) 'Vertices'
       write(12,*) nP
       write(12,*) '  '


       Do i=1,np
         read(11,*) x,y,zero,zero
         write(12,'(e13.7,x,e13.7,x,i1)') x,y,1
       End do

       close(11)
       close(12)


       write(test,*)np+6
       write(uxCom,*) 'tail -n +',trim(adjustl(test)), &
           ' Contour.mesh > tmp2.mesh'

       call system(uxCom)

       ! Produce initial mesh file mesh2D_1.mesh
       call system('cat tmp.mesh tmp2.mesh > mesh2D_1.mesh')



 1000  format('Point(',i6,')={',e13.7,',',e13.7,', 0.0 ,', e13.7,'};')


       End
