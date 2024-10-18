!
! License-Identifier: GPL
!
! Copyright (C) 2018 The Yambo Team
!
! Authors (see AUTHORS file for details): DS
!
module RT_interpolate_tools
 !
 use pars,         ONLY:SP,schlen
 use interpolate,  ONLY:INTERP_obj,l_INTERP_dE,l_INTERP_W,l_INTERP_f
 !
 implicit none
 !
 contains
   !
  subroutine FILL_SEED_RT(ID,SEED_RT)
    !
    use real_time, ONLY:RT_t
    !
    integer,    intent(in) :: ID
    type(RT_t), intent(in) :: SEED_RT
    !
    integer :: i_RT,ib,ik,i_s !WS
    !
    do i_RT=1,SEED_RT%nstates
      !
      ib   =SEED_RT%table(i_RT,1)
      !
      if (ib<INTERP_obj(ID)%nb(1).or.ib>INTERP_obj(ID)%nb(2)) cycle
      !
      ik   =SEED_RT%table(i_RT,3)
      i_s  =SEED_RT%table(i_RT,4)
      if (l_INTERP_f ) INTERP_obj(ID)%SEED(ib,ik,i_s)=SEED_RT%OCC_el%dN(i_RT) 
      if (l_INTERP_W ) INTERP_obj(ID)%SEED(ib,ik,i_s)=SEED_RT%NEQ_Lifetime(i_RT) 
      if (l_INTERP_dE) INTERP_obj(ID)%SEED(ib,ik,i_s)=SEED_RT%delta_E(i_RT) 
      !
    enddo
    !
  end subroutine
  !
end module RT_interpolate_tools
