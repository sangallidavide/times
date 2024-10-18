!
! License-Identifier: GPL
!
! Copyright (C) 2006 The Yambo Team
!
! Authors (see AUTHORS file for details): AM DS
!
subroutine RT_INIT_activate()
 !
 use BS_solvers,     ONLY:BSS_mode
 use QP_m,           ONLY:QP_solver,COHSEX_use_empties
 use stderr,         ONLY:STRING_match
 use global_XC,      ONLY:WF_exx_fraction,WF_exx_screening
 use drivers,        ONLY:l_em1s,l_acfdt,l_HF_and_locXC,l_col_cut,l_alda_fxc,l_bs_fxc,l_optics,l_bse,l_bss,&
&                         l_chi,l_cohsex,l_life,l_rpa_IP,l_td_hf,l_setup,l_sc_run,l_rim,l_rim_w,&
&                         l_real_time,l_ppa,l_mpa,l_lrc_fxc,l_gw0,l_elel_corr,l_elel_scatt,l_elph_corr,l_td_sex,&
&                         l_elph_Hamiltonian,l_elph_scatt,l_elphoton_corr,l_elphoton_scatt,l_em1d,l_eval_collisions,&
&                         l_sc_magnetic,l_sc_electric,l_dipoles,l_pf_fxc,l_nl_optics,l_phel_corr,l_nl_p_and_p,l_X
#if defined _SC || defined _RT
 use hamiltonian,    ONLY:H_potential
#endif
#if defined _SC
 use magnetic,       ONLY:MAG_landau
#endif
#if defined _RT
 use fields,         ONLY:n_ext_fields
#endif
#if defined  _ELPH 
 use ELPH,           ONLY:elph_use_q_grid
#endif
#if defined _SCALAPACK
 use drivers,        ONLY:l_slk_test
#endif
 !
 implicit none
 !
#if defined _RT
 integer          :: i1
#endif
 character(2)     :: X_kind
 !
#if defined _SC
 if (l_eval_collisions .or. l_sc_run) then
   call CPU_activate("SE")
   call initactivate(1,'SE_Threads')
 endif
#endif
 !
#if defined _RT 
 if (l_eval_collisions .or. l_real_time) then
   call CPU_activate("RT")
   call initactivate(1,'RT_Threads')
 endif
#endif
 !
#if defined _NL
 if (l_nl_optics) then
   call CPU_activate("NL")
   call CPU_activate("DIP")
   call CPU_activate("OSCLL")
   call initactivate(1,'DIP_Threads NL_Threads OSCLL_Threads')
 endif
#endif
 !
#if defined  _ELPH 
 if ((l_life.or.l_gw0).and.l_phel_corr) then
   call CPU_activate("PH_SE")
 endif
#endif
 !
#if defined  _ELPH 
 if (l_setup) call initactivate(1,'BSEscatt')
#endif
 !
 if (l_dipoles) then
#if defined _NL || defined _SC
   call initactivate(1,'EvPolarization')
#endif
 endif
 !
 if ((l_optics.and.l_chi).or.(l_em1d.and..not.(l_life.or.l_ppa.or.l_mpa.or.l_gw0)).or.l_X) then
   !
#if defined _RT
   call INIT_RT_ctl_switch('X')
#endif
   !
 endif
 !
 if (l_optics.and.l_bse) then
   !
#if defined _RT
   call INIT_RT_ctl_switch('K')
   call INIT_RT_ctl_switch('R')
#endif
   !
#if defined _NL || defined _SC
   call initactivate(1,'EvPolarization FrSndOrd')
#endif
   !
#if defined _RT
   call initactivate(1,'RTOccMode ForceEqTrans')
#endif
   !
 endif                    
 !
 ! BSE solver
 !
 if (l_optics.and.l_bse.and.l_bss.or.(l_bse.and.l_rpa_IP)) then
#if defined _ELPH 
   if (l_elph_corr.and..not.elph_use_q_grid) call initactivate(1,'ElPhRndNq')
#endif
 endif
 !
 ! Static screen 
 !
 if (l_em1s) then
#if defined _RT
   call INIT_RT_ctl_switch('X')
#endif
 endif
 !
 ! GW (PPA, MPA, & COHSEX) 
 !
 if ( (l_em1d.and.l_ppa) .or. (l_em1d.and.l_mpa) .or. (l_em1s.and.l_cohsex)) then
#if defined _RT
   call INIT_RT_ctl_switch('X')
#endif
 endif
 !
 ! ACFDT
 !
 if (l_acfdt) then
#if defined _RT
   call INIT_RT_ctl_switch('X')
#endif
 endif
 !
 ! GW/Life
 !
 if (l_gw0.or.l_life) then
   !
   if (l_HF_and_locXC.or.l_elel_corr) then
#if defined _RT
     call INIT_RT_ctl_switch('G')
#endif
   endif
   !
   if (l_elel_corr) then
#if defined _RT
     call INIT_RT_ctl_switch('X')
#endif
   endif
   !
#if defined  _PHEL 
   !
   if (l_phel_corr) then
     call initactivate(1,'ElecTemp BoseTemp PH_SE_mode GphBRnge GDamping PHELQpts ElPhModes PHDbGdsize DbGdQsize GDamping')
     call initactivate(1,'ExtendOut OnMassShell')
     if (      l_gw0) call initactivate(1,'DysSolver GEnSteps GEnRnge PHEL_QPH_En')
     if (.not. l_gw0) call initactivate(1,'GDamping PHELTrans') 
   endif
   !
#endif
#if defined  _ELPH 
   !
   if (l_elph_corr) then
     call INIT_QP_ctl_switch('G')
     call initactivate(1,'DysSolver')
     call initactivate(1,'GphBRnge FANdEtresh DWdEtresh ElPhModes GDamping dScStep ExtendOut ElPhRndNq RandQpts')
     call initactivate(1,'GkkpDB WRgFsq NewtDchk OnMassShell')
   endif
   if (trim(QP_solver)=="g".and.l_elph_corr) then
     call initactivate(1,'GEnSteps GEnRnge GEnMode GDmRnge GreenFTresh GreenF2QP') 
     call initactivate(-1,'WRgFsq NewtDchk GDamping ExtendOut OnMassShell')
   endif
   !
#endif
   !
 endif
 !
 ! El-Ph: Frohlich Hamiltonian
 !
#if defined _ELPH 
 !
 if (l_elph_Hamiltonian) then
   call initactivate(1,'ElPhHBRnge ElPhModes ElPhHKpt GDamping REStresh')
 endif
 !
#endif
 !
#if defined _SC || defined _RT
 !
 ! Collisions
 !
 if (l_eval_collisions) call initactivate( 0,'COLLBands COLLBseMem')
 !
 if ( (l_eval_collisions.or.l_real_time).and.l_elel_scatt ) call initactivate(1,'PlasmaPerc')
 !
 if (l_eval_collisions.or.l_real_time.or.l_sc_run) then
   !
   if ( .not. STRING_match(trim(H_potential),"NONE") ) call initactivate(1,'HXC_Potential')
   !
   call initactivate( 1,'FFTGvecs')
   !
   call initactivate( 1,'COLLCut')
   !
   call initactivate(-1,'QpntsRXs')
   !
   if( index(H_potential,"IP")>0 )  call initactivate(1,'HARRLvcs ALLGHAR')
   if( index(H_potential,"HARTREE")>0 .or. index(H_potential,"DEFAULT")>0 )  call initactivate(1,'HARRLvcs ALLGHAR')
   if( index(H_potential,"GS_XC")>0   .or. index(H_potential,"DEFAULT")>0 ) call initactivate(1,'VXCRLvcs UseNLCC FxcLibxc')
   !
   if (l_eval_collisions) then
     if( STRING_match(trim(H_potential),"SEX").or.&
&        STRING_match(trim(H_potential),"FOCK") ) call initactivate(1,'EXXRLvcs ALLGexx')
     if( STRING_match(trim(H_potential),"SEX").or.&
&        STRING_match(trim(H_potential),"COH") ) call initactivate(1,'CORRLvcs ALLGexx')
   endif
   !
 endif
 !
#endif
 !
#if defined _SC 
 !
 ! Self-Consistency
 !
 if (l_sc_run) then
   !
   call initactivate( 1,'SCBands')
   !
   if( STRING_match(trim(H_potential),"SEX").or.&
&      STRING_match(trim(H_potential),"COH")  ) call initactivate(1,'UseEbands SCUpWIter')
   !
   if( STRING_match(trim(H_potential),"EXX").or.&
&      STRING_match(trim(H_potential),"SRPA") ) call initactivate(1,'OEPapprox OEPItSolver') 
   !
   call initactivate(1,'SCIter SCEtresh SCRhoTresh SC_precondition')
   call initactivate(1,'SCmixing SClwBand SCnlMix BandMix')
   call initactivate(1,'SCdiag Mean_Potential')
   !
   call initactivate(1,'SCneqKIND SCmu SCocc SCcohIt')
   !
 endif
 !
#endif
 !
#if defined _RT
 !
 ! AM March 2024: the following line has been added in order to perform
 ! e-p calculations on top of RT carriers distribution.
 !
 if (l_elph_corr) call INIT_RT_ctl_switch('G')
 !
 if (l_real_time) then
   !
   call INIT_QP_ctl_switch('G')
   !
   call INIT_RT_ctl_switch('G')
   !
   call initactivate(1,'RTskipImposeN RTeeImposeE InducedField')
   call initactivate(1,'Gauge VelGaugeCorr VelGaugeDiam PfromJ RTUpdateSOC RTUpdateE SaveGhistory')
   call initactivate(1,'RTEqScatt RTImpForMet RTzeroTempRef RTskipPHabs RTEvalEnergy RTEvalEntropy')
   call initactivate(1,'dTupdateTime dTupdateTimeSet dTupdateJump dTupdateTresh dT_MAX dT_SET')
   if (l_elel_scatt .or. l_elph_scatt .or. l_elphoton_scatt) then
     call initactivate(1,'LifeExtrapolation LifeExtrapSteps LifeFitTemp RelaxTimeApprox RTAtemp RTAchem LifeFitTemp')
   endif
   if (l_elph_scatt) call initactivate(1,'MemTresh RandQpts RT_T_evol ElPhModes UseDebyeE')
   if (l_elel_scatt) call initactivate( 1,'EERimPerc')
   !
   call initactivate(1,'RTBands Integrator GrKind TwoAlph RTehEny ScattTresh')
   call initactivate(1,'RADLifeTime RADmagnific PhLifeTime DephCVonly DephEThresh DephTRange')
   call initactivate(1,'RTstep NEsteps NETime DipoleEtresh SPINprojected')
   call initactivate(1,'IOtime IOCachetime')
   !
   ! n_ext_fields is by default 0.  It is set to the input number of fields when a command line option is provided (below in init.F)
   ! or parsed from the input file in INIT_load.F
   !
   do i1=1,n_ext_fields
     call Afield_activate(i1)
   enddo
   !
 endif
 !
#endif
 !
#if defined _NL
 if (l_nl_optics) then
   call initactivate(1,'FFTGvecs NLBands NLverbosity NLstep NLtime NLintegrator NLCorrelation NLLrcAlpha')
   call initactivate(1,'TestOSCLL')
   if(.not.l_nl_p_and_p) call initactivate(1,'NLEnRange NLEnSteps NLrotaxis NLAngSteps')
   if(     l_nl_p_and_p) call initactivate(1,'IOtime IOCachetime SaveVbhistory')
   call initactivate(1,'NLDamping RADLifeTime UseDipoles FrSndOrd NoComprCOLL EvalCurrent InducedField FrPolPerdic') 
   call initactivate(1,'TestOSCLL Gauge RADLifeTime HARRLvcs EXXRLvcs CORRLvcs') 
   call init_QP_ctl_switch('G')
   !
   do i1=1,n_ext_fields
     call Afield_activate(i1)
   enddo
   !
 endif
 !
#endif
 !
#if defined _SC
 !
 ! Magnetic
 !
 if (l_sc_magnetic) then
   call initactivate(1,'Hamiltonian B_Field B_psi B_theta B_Gauge PhaseTrick')
   if (MAG_landau) call initactivate(1,'B_radius')
 endif
 !
 ! Electric
 !
 if (l_sc_electric) then
   call initactivate(1,'EvPolarization ExtF_Dir ExtF_Int FrSndOrd')
 endif
 !
#endif
 !
end subroutine
