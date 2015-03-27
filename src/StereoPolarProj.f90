!##############################################################       
!     LatLon2xy and xy2LatLon:
!        + Stereopolar projection for Northern hemisphere
!
!  INPUT/OUTPUT: lat,lon: latitude longitude (in rad)
!                rlat,rlon: reference latitude and longitude (in rad)
!                x,y: projected coordinates (in m)
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble, France
!##############################################################       
! lat,lon,rlat,rlon en rad
! x,y en m
! rlat,rlon, lat et lon de reference
      subroutine LatLon2xy(lat,lon,rlat,rlon,x,y)
       implicit none
       INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(12)
       real(kind=dp) :: lat,lon,rlat,rlon,x,y
       real(kind=dp) :: r,mc,tc,t
       real(kind=dp),parameter :: a=6378137.0_dp,f=1._dp/298.257223563
       real(kind=dp),parameter :: e2=2._dp*f-f*f,e=sqrt(e2)

       mc=cos(rlat)/sqrt(1._dp-e2*sin(rlat)*sin(rlat))
       tc=sqrt(((1._dp-sin(rlat))/(1._dp+sin(rlat)))*((1._dp+e*sin(rlat))/(1._dp-e*sin(rlat)))**e)

       t=sqrt(((1._dp-sin(lat))/(1._dp+sin(lat)))*((1._dp+e*sin(lat))/(1._dp-e*sin(lat)))**e)
       r=a*mc*t/tc

       x=r*sin(lon-rlon)
       y=-r*cos(lon-rlon)

       end

       subroutine xy2LatLon(lat,lon,rlat,rlon,x,y)
        implicit none
        INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(12)
        real(kind=dp),parameter :: pi=dacos(-1._dp)
        real(kind=dp),parameter :: tol=1.0e-08
        real(kind=dp),parameter :: a=6378137.0_dp,f=1._dp/298.257223563
        real(kind=dp),parameter :: e2=2._dp*f-f*f,e=sqrt(e2)
        real(kind=dp) :: lat,lon,rlat,rlon,x,y
        real(kind=dp) :: r,mc,tc,t,lambda,rho
        real(kind=dp) :: phi_c,phi,phi1,change

        phi_c=rlat
        lambda=-rlon+atan2(-x,-y)

        tc=tan(pi/4._dp-phi_c/2._dp)/((1._dp-e*sin(phi_c))/(1._dp+e*sin(phi_c)))**(e/2._dp)
        mc=cos(phi_c)/sqrt(1._dp-e2*sin(phi_c)*sin(phi_c))
        rho=sqrt(x*x+y*y)
        t=rho*tc/(a*mc)

        phi1=pi/2._dp-2._dp*atan(t)
        phi=pi/2._dp-2._dp*atan(t*((1._dp-e*sin(phi1))/(1._dp+e*sin(phi1)))**(e/2._dp))
        change=2._dp*tol

        do while (change.GT.tol)
          phi1=phi
          phi=pi/2._dp-2._dp*atan(t*((1._dp-e*sin(phi1))/(1._dp+e*sin(phi1)))**(e/2._dp))
          change=abs(phi-phi1)
        enddo
          lat=phi
          lon=-lambda
         
       end
