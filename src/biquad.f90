!##############################################################       
!     biquad: 
!        perform a biquadratic fit of the DEM data around each mesh node
!         v=a x^2 + b y^2 + c xy + d x + e y + f
!
!      OUTPUT in coefs_blin: d2v/dx^2 ;  d2v/dy^2 ; d2v/dxdy
!                            dv/dx    ; dv/dy ; v 
!                      at each mesh nodes      
!
!  Author :V. Peyaud; LGGE, Grenoble, France 
!          F. Gillet-Chaulet; LGGE, Grenoble, France
!           
!##############################################################       

!------------------------------------------------------------------
subroutine biquad(nx,ny,xmin, ymin, dx,dy,R,ncoefs,dem, ndata, xc, yc, noval,coefs_blin) 

! **** intent(in) ****
! NX        Size of the first  dimension of the DEM 
! NY        Size of the second dimension of the DEM 
! DX        grid size (in meters)
! R         radius for the subgrid where is calculated the biquad. (in meter) 
! ncoefs    Number of coefficient of the bilinear interpolation NCOEFS=6
! DEM       Digital elevation model
! xc        x of points to make calculation    
! yc        y of points to make calculation
! ndata     Number of data used to calculate the biquad. interpolation (size = (ndata,ncoefs)) 
! noval     Value corresponding to NaN
! **** intent(out) ****
! coefs_blin

implicit none
! ------------------------------------------!
! parametres de passages

integer,intent(in)                   :: nx,ny    ! taille du tableau
real,intent(in)                      :: xmin,ymin! lower left coordinate
real   ,intent(in)                   :: dx,dy       ! pas de la grille (en m)
real   ,intent(in)                   :: R        ! rayon/resolution : ex. 50 km/5km -> NR=10
integer,intent(in)                   :: ncoefs   != 6 coefficients de la biquadratique/MNODE
integer,intent(in)                   :: ndata    !nombre de points utilisé pour le calcul de la biquad.
real   ,intent(in) ,dimension(nx,ny) :: dem      ! Digital Elevation Model
real   ,intent(in), dimension(ndata) :: xc, yc
real   ,intent(in)                   :: noval    ! valeur correspondant a du No Data
real   ,intent(out),dimension(ndata,ncoefs)   ::coefs_blin

! ------------------------------------------!
! dimensionnements pour la sous-grille

integer                              :: NRa      !
integer                              :: MNODE    ! nombre de points du sous-tableau

integer                              :: k,km        ! index des points du cercle
integer                              :: l        ! compteur du nb de points reelement selectionnes
integer                              :: imin, imax, jmin, jmax ! Si on est trop près du bord (< distance R)
integer                              ::  i , j, ii   ! compteurs pour parcourir tt le domaine
integer                              ::  iz, jz  ! compteurs pour parcourir la sous-grille

real                                 :: x,y      ! coordonnees dans la sous-grille
real                                 :: dx_ls = 1! pas de la grille dans le moindre carre
real                                 :: dist     ! distance au centre 
integer,dimension(:,:), allocatable  :: cercle   ! cercle de rayon R
real                                 :: Xcenter, Ycenter     ! distance au centre du cercle
!-------------------------------------------!

real,dimension(:,:),    allocatable  :: Blin     ! en input c'est la surface sur les points du cercle
real,dimension(:,:),    allocatable  :: Bp       ! partie non vide de la matrice Blin  (pour envoie a sgelsy)
                                                 ! en output les coeffients de la bi quadratique
real,dimension(:,:),    allocatable  :: AA       ! matrice A en input x,xy,x2,y2,...de chaque point du cercle
real,dimension(:,:),    allocatable  :: Ap       ! partie non vide de la matrice A (pour envoie a sgelsy)
real,dimension(:,:),    allocatable  :: Abis     ! matrice pour sauvegarder A qui est modifie par sgelsy
! ------------------------------------------!

! variable specifiques a l'appel de sgelsy
real                           :: rcond = 1.e-30 ! pour appel a sgelsy  ~ max(A)/min(A)
integer                        :: rank                             ! pour sgelsy (output) -> rang de R11
integer, parameter             :: lwork = 150000 ! taille du tableau de travail voir sgelsy depend du rayon
real,dimension(lwork)          :: work           ! tableau de travail
integer,dimension(ncoefs)      :: jpvt           ! vecteur entier
integer                        :: info           ! retour des info
integer                        :: mm,nn,npp,lw
integer,parameter              :: npts  = 1      ! nombre de points pour lesquels le calcul est fait simultanement
!-------------------------------------------!



!      remplissage de la matrice A (la meme pour tous les points)
NRa   = R / dx
MNODE = (2*NRa+1)*(2*NRa+1)

allocate( cercle(-NRa:NRa,-NRa:NRa) )

allocate( AA(mnode,ncoefs)   )
allocate( Ap(mnode,ncoefs)   )
allocate( Abis(mnode,ncoefs) ) 
allocate( Blin(mnode,1)     ) 
allocate(  Bp(mnode,1)      )

coefs_blin=0.

k=0
do j=-NRa,NRa                                ! balaye tous les points du sous tableau
   do i=-NRa,NRa
      x=i*dx_ls
      y=j*dx_ls
      dist=(x*x+y*y)**0.5

      if (dist.le.real(NRa)) then           ! a l'interieur du cercle
         k=k+1
         AA(k,1)=x*x
         AA(k,2)=y*y
         AA(k,3)=x*y
         AA(k,4)=x
         AA(k,5)=y
         AA(k,6)=1
         cercle(i,j)=k
      else
         cercle(i,j)=0
      end if

   end do
end do
km=k
Abis(:,:)=AA(:,:)

 write(6,*) 'local circle used for the bi-quadratic fit of the velocities'
do k=-NRa,NRa
   write(6,'(25(i3,1x))') (cercle(i,k),i=-NRa,NRa)
end do
 write(6,*) '  '

 write(6,*) 'noval',noval

do ii=1, ndata
      i = nint((xc(ii)-xmin) / dx) + 1  
      j = nint((yc(ii)-ymin) / dy) + 1 

  
      Xcenter = (xc(ii) - (xmin + (i-1)*dx))/dx
      Ycenter = (yc(ii) - (ymin + (j-1)*dy))/abs(dy)

      imin=max(-i+1,-NRa)
      jmin=max(-j+1,-NRa)
      imax=min(nx-i,NRa)
      jmax=min(ny-j,NRa)
      Blin(:,:)=0.
      l=0

      subgrid :       do jz=jmin,jmax       !Constructjon de la sous-grjlle centree sur g
        do iz=imin,imax

           if ((cercle(iz,jz).gt.0).and.(dem(iz+i,jz+j).ne.noval)) then
           !if ((cercle(iz,jz).gt.0).and.(dem(iz+i,jz+j).gt.0.0)) then
              k= cercle(iz,jz)
              l=l+1

              Blin(k,1)=dem(iz+i,jz+j)
              Bp(l,1) = Blin(k,1)
              Ap(l,:) = AA(k,:)
           else
           end if

        end do
      end do subgrid

      mm = l
    
! appel a la resolution pour 1 point : subroutine lapack (voir doc en fin de programme)
! mm=mnode, nn = coef = 6 npp = 1
      nn=ncoefs
      npp=npts
      lw=lwork
      AA(:,:)=Abis(:,:)

!mm peut changer, aini que Amm,nn & Bmm,1
      if ((mm.ge.(km/2)).AND.(mm.ge.6)) then  ! test sur le No Data (nb suffisant de point pour le calcul?)

         call sgelsy(mm,nn,npp,Ap(1:mm,:),mm,Bp(1:mm,1),mm,jpvt,rcond,rank,work,lw,info)
         ! cherche X tel que  minimize || A * X - Blin ||
         ! mm  : nombre de lignes de A   nn nombre de colonnes de A
         ! npp : nombre de colonnes de B et de X
         ! 
         ! apres l'appel les coefficients sont dans Blin(1:6,pp)
         !        Blin(1,pp)= a    coeff de x2
         !        Blin(2,pp)= b    coeff de y2
         !        Blin(3,pp)= c    coeff de xy
         !        Blin(4,pp)= d    coeff de x
         !        Blin(5,pp)= e    coeff de y
         !        Blin(6,pp)= f    terme constant

	Blin(1,1) = 2.0 * Bp(1,1) / dx**2
	Blin(2,1) = 2.0 * Bp(2,1) / dx**2
	Blin(3,1) = Bp(3,1)  / dx**2
	Blin(4,1) = (2 * Bp(1,1) * Xcenter + Bp(3,1) * Ycenter + Bp(4,1)) /dx
	Blin(5,1) = (2 * Bp(2,1) * Ycenter + Bp(3,1) * Xcenter + Bp(5,1))  /dx 
	Blin(6,1) = Bp(1,1) * Xcenter**2 +  Bp(2,1) * Ycenter**2 +  Bp(3,1) * Xcenter * Ycenter + &
                    Bp(4,1) * Xcenter +  Bp(5,1) * Ycenter + Bp(6,1)
	coefs_blin(ii,:) = Blin(:,1)
      else
	  coefs_blin(ii,:) = noval
      endif
enddo

end subroutine biquad
!///////////////////////////////////////////////////////////////////////
