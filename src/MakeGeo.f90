!##############################################################       
!     MakeGeo: 
!       + Create a GMSH .geo file from a unique ascii file containing ordered
!       points forming the contour of the domain
!       + Particularity here, assume that the contour is in stereopolar projection with ref meridien 39W
!         I. Joughin velocity data sets use 45W => re-project the contour points
!       + The reverse projection (45W => 39W ) is made in  MeshToElmer_Greenland.f90
!
! INPUT : "../Data/Contour.dat" (contains x,y coordinate of the contour points)
! OUTPUT: "Contour.geo" (GMSH .geo file)
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble
!##############################################################       

       program MakeGeo
       implicit none
       INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(12)
       real(dp) :: pi
       real(dp)   :: x,y,x1,y1,lat,lon,zero
       real(dp) :: lc=5000.0
       integer :: np
       integer :: i,j
       integer :: compt
       character*100 :: uxcom,test
       character*1 :: dumy

       pi=Dacos(-1.0_dp)
! Create Contour.geo
       open(11,file='Contour.geo')
       write(11,'(A)') 'Mesh.Algorithm=5;'


       Open(10,file='../Data/Contour.dat')
       compt=0
       do while (.true.)
        read (10,*,end=300) x,y
        ! Compute LatLon then reproject
        call xy2LatLon(lat,lon,71.0_dp*pi/180._dp,-39._dp*pi/180._dp,x,y)
        call LatLon2xy(lat,lon,70.0_dp*pi/180._dp,-45._dp*pi/180._dp,x1,y1)
        compt=compt+1
        write(11,1000) compt,x1,y1,lc
       end do

 300 continue
       close(10)

       write(11,'(A)',advance='no') 'Spline(1)={'
       Do i=1,compt
                write(11,'(i6,A)',advance='no') i,','
       End do
                write(11,'(i6,A)') 1,'};'


       write(11,'(A)') 'Line Loop(2)={1};'
       write(11,'(A)') 'Plane Surface(3)={2};'
       write(11,'(A)') 'Physical Line(100)={1};'
       write(11,'(A)') 'Physical Surface(102)={3};'

       close(11)


 1000  format('Point(',i6,')={',e14.7,',',e14.7,', 0.0 ,', e14.7,'};')


       End
