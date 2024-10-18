!
! License-Identifier: GPL
!
! Copyright (C) 2019 The Yambo Team
!
! Authors (see AUTHORS file for details): AM DS
!
subroutine RT_INIT_check_databases(X,Xbsk,qp,Xxcw,Xw,q,k,en,en_sc,Dip,lnstr,instr,INIT,&
&                               io_X_err,io_BS_err,io_BS_Fxc_err,io_QINDX_err,&
&                               io_ELPH_err,io_SC_E_err)
 !
 use electrons,      ONLY:levels,n_spinor
 use C_driver,       ONLY:code_branch
 use drivers,        ONLY:infile_editing
 use X_m,            ONLY:X_t
 use DIPOLES,        ONLY:DIPOLE_t
 use frequency,      ONLY:w_samp
 use BS,             ONLY:BS_n_g_exch,BS_n_g_fxc,BS_q,BSqpts
 use R_lattice,      ONLY:ng_closed,nqibz,bz_samp
 use QP_m,           ONLY:QP_t,QP_ng_Sx,QP_ng_Sc,QP_ng_SH,QP_ng_Vxc
 use wave_func,      ONLY:io_WF
 use TDDFT,          ONLY:io_BS_Fxc
 use it_tools,       ONLY:switch_off_runlevel
 use IO_int,         ONLY:io_control
 use IO_m,           ONLY:OP_RD_CL,DUMP,NONE
#if defined _SC || defined _RT
 use collision_ext,  ONLY:COH_collisions,HXC_collisions,P_collisions,GW_NEQ_collisions
# if !defined _PAR_IO
 use COLL_interfaces,ONLY:io_COLLISIONS
# endif
#endif
 !
 ! Inside collisions.h, io_COLLs_header is defined as either
 ! - io_COLLISIONS        (serial I/O) or
 ! - io_COLLISIONS_header (parallel I/O case)
 !
#include<collisions.h>
 !
#include<memory.h>
 !
 type(X_t)        :: X(5),Xbsk
 type(QP_t)       :: qp
 type(w_samp)     :: Xxcw,Xw(5)
 type(levels)     :: en,en_sc
 type(bz_samp)    :: q,k
 type(DIPOLE_t)   :: Dip
 !
 integer          :: lnstr
 character(lnstr) :: instr
 integer          :: INIT
 integer          :: io_X_err(5),io_BS_err,io_BS_Fxc_err,io_QINDX_err,io_ELPH_err(2),io_SC_E_err
 !
 ! Workspace
 !
 integer           :: i_io,io_ID,io_err,io_DIP_err,io_WF_err,io_KB_abinit_err,io_KB_pwscf_err,io_ATMPROJ_pwscf_err
 !
 integer, external :: io_X,io_DIPOLES,io_GROT,io_QINDX,io_RIM,&
&                     io_HF_and_locXC,io_QP_and_GF,io_DB1,io_KB_abinit,io_KB_pwscf,&
&                     io_COL_CUT,io_E_SOC_map,io_ATMPROJ_pwscf,io_Double_Grid
#if !defined _PAR_IO
 integer, external :: io_BS
#endif
#if defined _PAR_IO
 integer, external :: io_COLLs_header,io_BS_header
#endif
 !
 logical           :: OSTNTS_Vnl_included
 !
#if defined _SC
 integer           :: io_SC_V_err
#endif
#if defined _RT
 integer           :: io_G,io_OBS
#endif
#if defined _SC || defined _RT
 integer           :: io_COLLISIONS_err
#endif
#if defined _SC || defined _RT
 integer, external :: io_SC_components,io_RT_components
#endif
#if defined _ELPH 
 integer, external :: io_ELPH
#endif 
 !
 ! ELPH 
 !
#if defined _ELPH 
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_ELPH_err(1)=io_ELPH(io_ID,'gkkp')
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_ELPH_err(2)=io_ELPH(io_ID,'gkkp_expanded')
#endif
 !
 ! RT 
 !
#if defined _RT
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_OBS=io_RT_components('OBSERVABLES',io_ID)
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_G=io_RT_components('G_lesser_RESTART',io_ID)
#endif
 !
 ! SC 
 !
#if defined _SC
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_SC_V_err=io_SC_components('V',en_sc,io_ID)
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_SC_E_err=io_SC_components('E',en_sc,io_ID)
 if (io_SC_E_err==0.and.io_SC_V_err/=0) io_SC_E_err=-1
#endif
 !
 ! COLLISIONS 
 !
#if defined _SC || defined _RT
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_COLLISIONS_err=io_COLLs_header(io_ID,COH_collisions)
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_COLLISIONS_err=io_COLLs_header(io_ID,HXC_collisions)
#endif
#if defined _RT
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_COLLISIONS_err=io_COLLs_header(io_ID,GW_NEQ_collisions)
#endif
#if defined _QED && defined _RT
 call io_control(ACTION=OP_RD_CL,COM=NONE,MODE=DUMP,SEC=(/1/),ID=io_ID)
 io_COLLISIONS_err=io_COLLs_header(io_ID,P_collisions)
#endif
 !
end subroutine
