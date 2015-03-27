!##############################################################       
!     ComputeMetric: 
!      + Compute the metric tensor (Eq.13: Frey et Alauzet, Anisotropic mesh adaptation 
!        for CFD computations, Computer methods in applied mechanics and engineering, 2005)
!
! INPUT : Hessian the componenets of the hessian matrix
!          Param: hmin,hmax,err
! OUTPUT: Metric
!
!  Author : F. Gillet-Chaulet; LGGE, Grenoble, France
!#########################################################################@

module metrics 
  interface ComputeMetric
     module procedure ComputeMetricHessian
     module procedure ComputeMetricVelFudge
  end interface ComputeMetric
  
contains
  
  subroutine ComputeMetricHessian(Hessian,Param,Metric)
    implicit none
    real,dimension(3),intent(in) :: Hessian
    real,dimension(3),intent(in) :: Param
    real,dimension(3),intent(out) :: Metric

    double precision :: e1,e2,en
    double precision :: Delta,l1,l2
    double precision :: hmin,hmax,err
    double precision :: Lambd1,Lambd2
    
    !PRINT*, Hessian
    
    hmin=Param(1)
    hmax=Param(2)
    err=Param(3)
    
    ! compute eigenvalues of Hessian
    IF (abs(Hessian(3)).lt.1.0e-12) then
       
       l1=Hessian(1)
       l2=Hessian(2)
       e1=1.0
       e2=0.0
       
    ELSE
       
       Delta=(Hessian(1)-Hessian(2))*(Hessian(1)-Hessian(2))
       Delta=Delta+4.0*Hessian(3)*Hessian(3)
       
       if (Delta.lt.0) then
          PRINT *,'Delta',Delta
          pause
       endif
       
       l1=(Hessian(1)+Hessian(2))+sqrt(Delta)
       l1=l1/2.0
       l2=(Hessian(1)+Hessian(2))-sqrt(Delta)
       l2=l2/2.0
       
       ! compute normilized eignevector 1 of Hessian
       e1=1.0
       e2=(l1-Hessian(1))/Hessian(3)
       en=sqrt(e1*e1+e2*e2)
       e1=e1/en
       e2=e2/en
       
    END IF
    
    ! compute Metric in eigenframe        
    Lambd1=min(max(abs(l1)/err,1.0/(hmax*hmax)),1.0/(hmin*hmin))
    Lambd2=min(max(abs(l2)/err,1.0/(hmax*hmax)),1.0/(hmin*hmin))
    
    ! Metric in reference frame
    Metric(1)=Lambd1*e1*e1+Lambd2*e2*e2  !Metric(1,1)
    Metric(2)=Lambd1*e2*e2+Lambd2*e1*e1  !Metric(2,2)
    Metric(3)=Lambd1*e1*e2-Lambd2*e1*e2  !Metric(1,2)=Metric(2,1)
        
    Return
  End subroutine ComputeMetricHessian
  
  subroutine ComputeMetricVelFudge(Vel,Param,Metric)
    implicit none
    real,intent(in)  :: Vel
    real,dimension(3),intent(in)  :: Param
    real,dimension(3),intent(out) :: Metric

    double precision :: hmin,hmax,err
    double precision :: e1,e2
    double precision :: l1,l2
    double precision :: Lambd1,Lambd2

    hmin=Param(1)
    hmax=Param(2)
    err=Param(3)

    l1=Vel/1000.
    l2=Vel/1000.
    
    e1=1.0
    e2=0.0

    Lambd1=min(max(abs(l1)/err,1.0/(hmax*hmax)),1.0/(hmin*hmin))
    Lambd2=min(max(abs(l2)/err,1.0/(hmax*hmax)),1.0/(hmin*hmin))
    
    Metric(1)=Lambd1*e1*e1+Lambd2*e2*e2
    Metric(2)=Lambd1*e2*e2+Lambd2*e1*e1
    Metric(3)=Lambd1*e1*e2-Lambd2*e1*e2
    
    return
  end subroutine ComputeMetricVelFudge

end module metrics
