!
! License-Identifier: GPL
!
! Copyright (C) 2006 The Yambo Team
!
! Authors (see AUTHORS file for details): AM
!
subroutine RT_INIT_load(defs,en,q,k,X,Xw,Dip)
 !
 use drivers,       ONLY:infile_editing
 use pars,          ONLY:schlen,SP
 use electrons,     ONLY:levels,nel,filled_tresh
 use zeros,         ONLY:G_mod_zero
 use frequency,     ONLY:w_samp
 use it_tools,      ONLY:it,runlevel_is_on
 use it_m,          ONLY:initdefs,E_unit,G_unit,T_unit,Bfield_unit,MEM_unit,&
&                        Time_unit,I_unit,Angle_unit,V_parallel,initmode,V_ph,&
&                        V_RL,V_kpt,V_sc,V_qp,V_io,V_general,V_resp,V_real_time,V_nl_optics
 use X_m,           ONLY:Chi_mode,X_t,q_plus_G_direction,Q_Shift_Order,&
&                        global_gauge,Chi_linalg_mode, &
&                        X_terminator_Kind,X_terminator_E,X_DbGd_percentual
 use DIPOLES,       ONLY:DIPOLE_t
 use com,           ONLY:grid_paths
 use stderr,        ONLY:slash
 use QP_m,          ONLY:QP_cg_percent,QP_G_damp,QP_solver,&
&                        QP_n_G_bands,QP_ng_Sx,QP_ng_Sc,QP_ng_SH,QP_ng_Vxc,GW_terminator_E,GW_terminator_Kind,&
&                        QP_G_er,QP_G_ir,QP_G_dr,QP_Sc_steps,QP_G_solver,&
&                        QP_dSc_delta,QP_G_Zoom_treshold,GF_energy_range_mode
 use LIVE_t,        ONLY:nhash
 use wave_func,     ONLY:wf_ng
 use D_lattice,     ONLY:Tel,non_periodic_directions,molecule_position,Bose_Temp
 use R_lattice,     ONLY:ng_closed,QP_states_k,nXkibz,k_GRIDS_string,RIM_W_ng,rimw_type,&
&                        bz_samp,RIM_ng,RIM_epsm1,RIM_id_epsm1_reference,&
&                        RIM_n_rand_pts,cyl_ph_radius,box_length,cyl_length,cut_geometry,ws_cutoff
 use BS,            ONLY:BSE_mode,BSE_prop,BSK_mode,BS_eh_en,BS_eh_win,BS_q,BS_bands,&
&                        BS_n_g_W,BS_n_g_exch,BS_n_g_fxc,BSE_L_kind,BS_K_cutoff,BSK_IO_mode,BSE_dipole_geometry
 use BS_solvers,    ONLY:BSS_mode,Haydock_threshold,Haydock_iterIO,BSS_n_freqs,&
&                        BSS_dr,BSS_er,BSS_E_dir,BSS_Q_dir,BSS_damp_reference,BSS_inversion_mode,&
&                        BSS_Wd,K_INV_EPS,K_INV_PL,BSS_n_eig,Haydock_iterMAX
#if defined _SLEPC && !defined _NL
 use BS_solvers,    ONLY:BSS_slepc_target_E,BSS_slepc_extraction,BSS_slepc_ncv,BSS_slepc_tol,BSS_slepc_maxit,&
 &                       BSS_slepc_precondition,BSS_slepc_approach,BSS_slepc_mpd,BSS_slepc_matrix_format
#endif
 use TDDFT,         ONLY:FXC_n_g_corr,FXC_per_memstps,FXC_LRC_alpha,FXC_LRC_beta, &
&                        FXC_SVD_digits,FXC_PF_alpha,FXC_mode
 use ACFDT,         ONLY:ACFDT_n_lambda,ACFDT_n_freqs,ACFDT_E_range
 use functions,     ONLY:bose_E_cut
 use parallel_m,    ONLY:n_log_CPUs
 use IO_m,          ONLY:DBs_IO_control_string,DBs_FRAG_control_string
#if defined _QED
 use QP_m,          ONLY:QP_QED_ng
#endif
#if defined _SC || defined _RT || defined _QED
 use hamiltonian,   ONLY:H_ref_bands,H_potential
 use collision_ext, ONLY:COLLISIONS_cutoff,COLL_bands,ng_oscll
#endif
 use QP_m,          ONLY:SC_E_threshold
#if defined _SC
 use QP_m,          ONLY:SC_band_mixing
 use SC,            ONLY:SC_iterations,SC_up_W_iters,&
&                        SC_rho_threshold,SC_cycle_mixing,&
&                        SC_bands,SC_preconditioning,OEP_approx,&
&                        SC_neq_kind,SC_mu,SC_last_coh_it
#endif
#if defined _RT
 use RT_control,    ONLY:CARR_RT_IO_t,OBS_RT_IO_t,OUTPUT_RT_IO_t,Gless_RESTART_RT_IO_t,     &
&                        CACHE_OBS_INTERVAL_time_INPUT,RT_BSE_Occ_Mode,Gless_RT_IO_t,Vbands_RT_IO_t
 use RT_occupations,ONLY:RT_RTA_temp,RT_RTA_chem
 use RT_lifetimes,  ONLY:RT_life_extrap_times_INPUT
 use real_time,     ONLY:RT_step, Integrator_name, RAD_LifeTime, Phase_LifeTime, &
&                        NE_tot_time,RT_bands,RT_deph_range,                     &
&                        RT_ave_dephasing,RT_eh_en,RT_scatt_tresh,Gr_kind,       &
&                        NE_MEM_treshold,NE_time_step_update_jump_INPUT,         &
&                        two_alpha,DbGd_EE_percent,NE_time_step_update_jump,     &
&                        NE_initial_time_step_update,NE_step_update_treshold,    &
&                        RT_MAX_step,RAD_magnification,  &
&                        RT_deph_deg_thresh,RT_step_manual_prefactor,NE_time_step_update_manual
 use fields,        ONLY:n_ext_fields_max,n_ext_fields
 use plasma,        ONLY:PLASMA_redux_percent
#endif
#if defined _NL
 use nl_optics,     ONLY:NL_bands,NL_damping,NL_correlation,NL_er,n_frequencies,NL_LRC_alpha, &
&                        NL_verb_name,n_angles,NL_rot_axis 
#endif 
#if defined _NL | defined _SC
 use fields,        ONLY:Efield
#endif 
#if defined _SC
 use magnetic,      ONLY:MAG_B,MAG_hamiltonian_type,MAG_radius,MAG_gauge,MAG_psi,MAG_theta
#endif
#if defined _ELPH 
 use ELPH,          ONLY:QP_PH_n_G_bands,elph_nQ_used,elph_Ham_ik,elph_Ham_bands,elph_branches,&
&                               RES_tresh,FAN_deltaE_treshold,DW_deltaE_treshold,E_kpq_sh_fact,gkkp_db
#endif
#if defined _OPENMP
 use openmp,        ONLY:n_threads_X,n_threads_SE,n_threads_RT,n_threads_DIP,n_threads_K,n_threads_NL, &
&                        n_threads_OSCLL
#endif
#if defined _SCALAPACK
 use SLK_m,         ONLY:SLK_test_H_dim
#endif
 use PHOTOLUM,      ONLY:PL_weights
#if defined _MEM_CHECK
 use memory,        ONLY:MEM_treshold
#endif
#if defined _PHEL
 use PHEL,          ONLY:PH_Self_Energy_mode,PH_DbGd_points,PH_Q,PHEL_broad_factor,PHEL_fit_Energies
#endif
 !
 implicit none
 !
 type(initdefs)::defs
 type(levels)  ::en          
 type(bz_samp) ::q,k
 type(X_t)     ::X(5)
 type(DIPOLE_t)::Dip
 type(w_samp)  ::Xw(5)
 !
 ! Work Space
 !
#if defined _RT
 integer  :: i_field
#endif
 real(SP) :: IO_times(3)
 !
#if defined _RT_SCATT
 call it('r',defs,'el_el_scatt','[R] Electron-Electron Scattering')
#endif
#if defined _RT_SCATT && _ELPH
 call it('r',defs,'el_ph_scatt','[R] Electron-Phonon   Scattering')   
#endif
#if defined _RT_SCATT && _PHEL
 call it('r',defs,'ph_el_scatt','[R] Phonon-Electron Scattering')   
#endif
#if defined _RT_SCATT
 call it('r',defs,'el_photon_scatt','[R] Electron-Photon   Scattering')   
#endif
#if defined _ELPH 
 call it('r',defs,'el_ph_corr',    '[R] Electron-Phonon Correlation')   
#endif
#if defined _PHEL 
 call it('r',defs,'ph_el_corr',    '[R] Phonon-Electron Correlation')   
#endif
 call it('r',defs,'el_el_corr',    '[R] Electron-Electron Correlation') 
#if defined _QED
 call it('r',defs,'el_photon_corr','[R] Electron-Photon Correlation') 
#endif
 !
#if defined _ELPH 
 call it('f',defs,'BSEscatt', '[KPT] Compute extended k/q scatering',verb_level=V_kpt)
 call it(defs,'ElPhRndNq',  '[ELPH] Read random Q-points',elph_nQ_used,verb_level=V_ph) 
 call it(defs,'EkpqShFact', '[ELPH] E(k+q) Interpolation shell factor (used only with double-grid)',E_kpq_sh_fact,verb_level=V_ph)
#endif
 !
#if defined _QED
 call it(defs,'QEDRLvcs', '[QED] Vector-Potential G-vectors components',QP_QED_ng,G_unit)
#endif
#if defined _SC
 call it(defs,'GbndRnge', '[GW] G[W] bands range',QP_n_G_bands,verb_level=V_sc)
 call it('f',defs,'UseEbands', '[GW] Force COHSEX to use empty bands',verb_level=V_sc)
 call it('f',defs,'ALLGexx', '[XX] Force the use use all RL vectors for the exchange part',verb_level=V_sc)
 call it('f',defs,'ALLGHAR', '[HA] Force the use use all RL vectors for the Hartree potential',verb_level=V_sc)
#else
 call it(defs,'GbndRnge', '[GW] G[W] bands range',QP_n_G_bands)
 call it('f',defs,'UseEbands', '[GW] Force COHSEX to use empty bands',verb_level=V_qp)
#endif
#if defined _PHEL
 call it(defs,'GDamping', '[GW] G[W] damping',QP_G_damp,E_unit)
#else
 call it(defs,'GDamping', '[GW] G[W] damping',QP_G_damp,E_unit,verb_level=V_qp)
#endif
 !
#if defined _RT
 !
 ! BSE: Real-Time
 !
 call it(defs,'RTOccMode','[RT-BSE] (K)ernel/(R)esiduals. BSE components to be corrected with the TD occupations',&
&             RT_BSE_Occ_Mode,verb_level=V_real_time)
 call it('f',defs,'ForceEqTrans','[RT-BSE] Use only equilibrium transitions',verb_level=V_real_time)
 !
 ! Real Time dynamics
 !
 call it(defs,'RTBands',    '[RT] Bands',RT_bands)
 !
 call TMP_mirror_bands( )
 !
 call it(defs,'TwoAlpha',   '[RT] C_nk ~ alpha*Gamma_nk^2 ',two_alpha,Verb_level=V_real_time)
 call it(defs,'GrKind',     '[RT] G-ret kind: Lorentzian (QP)/ Hyperbolic QP_secant (HS)',Gr_kind,Verb_level=V_real_time)
 call it(defs,'RADLifeTime','[RT] Radiative life-time (if negative RADLifeTime=Phase_LifeTime)', &
&         RAD_LifeTime,unit=Time_unit(1))
 call it(defs,'RADmagnific','[RT] Radiative life-time magnification',RAD_magnification,Verb_level=V_real_time)
 call it(defs,'PhLifeTime', '[RT] Constant Dephasing Time',Phase_LifeTime,unit=Time_unit(1))
 call it(defs,'DephTRange', '[RT] Time range in which Dephasing is applied',RT_deph_range,unit=Time_unit(1),Verb_level=V_real_time)
 call it(defs,'DephEThresh', '[RT] Threshold on the energy difference between two states to dephase them',&
         &   RT_deph_deg_thresh,unit=E_unit,Verb_level=V_real_time)
 !
 ! Dynamics
 !
 call it(defs,'RTstep',      '[RT] Real Time step length',RT_step,unit=Time_unit(3))
 call it(defs,'NETime',      '[RT] Simulation Time',NE_tot_time,unit=Time_unit(2))
 call it(defs,'dTupdateTimeSet','[RT] Time for manual deltaT update',NE_time_step_update_manual,&
&                            unit=Time_unit(1),verb_level=V_real_time)
 call it(defs,'dTupdateTime','[RT] Initial Time for deltaT update (active only if non-zero) ',NE_initial_time_step_update,&
&                            unit=Time_unit(1),verb_level=V_real_time)
 call it(defs,'dTupdateJump','[RT] Time betweem two deltaT updates',  NE_time_step_update_jump_INPUT,&
&                            unit=Time_unit(1),verb_level=V_real_time)
 call it(defs,'dTupdateTresh','[RT][o/o] Treshold of deltaT updates',  NE_step_update_treshold ,verb_level=V_real_time)
 call it(defs,'dT_MAX',      '[RT] Maximum value for the time-dependent dT',  RT_MAX_step ,verb_level=V_real_time,unit=Time_unit(1))
 call it(defs,'dT_SET',      '[RT] Prefactor for manual dT update',  RT_step_manual_prefactor,verb_level=V_real_time)
 call it(defs,'Integrator',  '[RT] Integrator. Use keywords space separated  ( "EULER/EXPn/INV" "SIMPLE/RK2/RK4/HEUN" "RWA") ',&
&              Integrator_name)
 !
#if defined _NL
 IO_times=(/CARR_RT_IO_t%INTERVAL_time_INPUT,Vbands_RT_IO_t%INTERVAL_time_INPUT,OUTPUT_RT_IO_t%INTERVAL_time_INPUT/)
#elif defined _RT
 IO_times=(/CARR_RT_IO_t%INTERVAL_time_INPUT,Gless_RESTART_RT_IO_t%INTERVAL_time_INPUT,OUTPUT_RT_IO_t%INTERVAL_time_INPUT/)
#endif
 call it(defs,'IOtime',      '[RT] Time between two consecutive I/O (CARRIERs - GF/WF - OUTPUT)',IO_times,unit=Time_unit(1))
 CARR_RT_IO_t%INTERVAL_time_INPUT             =IO_times(1)
 Gless_RESTART_RT_IO_t%INTERVAL_time_INPUT    =IO_times(2)
 Gless_RT_IO_t%INTERVAL_time_INPUT            =IO_times(2)
 Vbands_RT_IO_t%INTERVAL_time_INPUT           =IO_times(2)
 OUTPUT_RT_IO_t%INTERVAL_time_INPUT           =IO_times(3)
 !
 IO_times(1:2)=(/CACHE_OBS_INTERVAL_time_INPUT,OBS_RT_IO_t%INTERVAL_time_INPUT/)
 call it(defs,'IOCachetime', '[RT] Time between two consecutive (caching - I/O) of OBSERVABLES',IO_times(1:2),unit=Time_unit(1),&
 &       verb_level=V_real_time)
 CACHE_OBS_INTERVAL_time_INPUT  =IO_times(1)
 OBS_RT_IO_t%INTERVAL_time_INPUT=IO_times(2)
 !
 call it(defs,'RTehEny',     '[RT] Electron-hole energy range',RT_eh_en,unit=E_unit,verb_level=V_real_time)
 !
 ! ... flags ...
 call it('f',defs,'DephCVonly',    '[RT] Dephase only in the CV channel',Verb_level=V_real_time)
 call it('f',defs,'RTskipImposeN', '[RT] Conservation of N, dN  imposed by hand on-the-fly',Verb_level=V_real_time)
 call it('f',defs,'RTEvalEnergy',  '[RT] Energy variation computed on the fly',Verb_level=V_real_time)
 call it('f',defs,'RTEvalEntropy', '[RT] Entropy variation computed on the fly',Verb_level=V_real_time)
 call it('f',defs,'SaveGhistory',  '[RT] Save the history of the green function',Verb_level=V_real_time)
 !
 ! ... updates ...
 call it('f',defs,'RTUpdateSOC',     '[RT] Update the SOC interaction',Verb_level=V_real_time)
 call it('f',defs,'RTUpdateE',     '[RT] Update the Enery levels on-the-fly',Verb_level=V_real_time)
 !
 call it('f',defs,'RTEqScatt',     '[RT] Include Gamma0f0 term in scattering',Verb_level=V_real_time)
 call it('f',defs,'RTImpForMet',   '[RT] Impose structure optimized for metals',Verb_level=V_real_time)
 call it('f',defs,'RTzeroTempRef', '[RT] Use zero temperature Fermi districution as reference',Verb_level=V_real_time)
 call it('f',defs,'RTskipPHabs',   '[RT] Skip e-p Lifetimes due to phonon absorption',Verb_level=V_real_time)
 !
 ! Scattering
 !
 call it('f',defs,'LifeExtrapolation',    '[RT] Skipped Lifetimes are extrapolated')
 call it(defs,'LifeExtrapSteps',   '[RT] Step length between and inside two consecutive groups of lifetimes',&
&                                  RT_life_extrap_times_INPUT,unit=Time_unit(1))
 call it('f',defs,'RelaxTimeApprox',    '[RT] Skipped Lifetimes are extrapolated',Verb_level=V_real_time)
 call it(defs,'RTAtemp',   '[RT] Temperatures for relaxation time approximation',&
&              RT_RTA_temp,unit=T_unit,Verb_level=V_real_time)
 call it(defs,'RTAchem',   '[RT] Chemical potentials for relaxation time approximation',&
&              RT_RTA_chem,unit=E_unit,Verb_level=V_real_time)
 call it(defs,'ScattTresh', '[RT] Treshold on the eh energy to compute the scattering',RT_scatt_tresh,&
&                           unit=E_unit,verb_level=V_real_time)
 !
 ! EE scattering
 !
 call it(defs,'PlasmaPerc', '[RT] % (0-100) of PLASMA eh pair reduction. =0 correspond to no reduction.',&
&        PLASMA_redux_percent,Verb_level=V_real_time)
 call it(defs,'EERimPerc',  '[RT] EE Double Grid (0-100): % of the points used in EE scatt',DbGd_EE_percent,Verb_level=V_real_time)
 call it('f',defs,'RTskipImposeE',   '[RT] Conservation of E (e-e channel) imposed by hand on-the-fly')
 !
 ! ELPH
 !
 call it(defs,'MemTresh',   '[RT] Treshold on the decay of the retarded GF',NE_MEM_treshold,verb_level=V_real_time)
 call it('f',defs,'UseDebyeE',   '[RT] Use a single Debye energy for all phonon modes',verb_level=V_real_time)
 call it('f',defs,'RT_T_evol',   '[RT] Use a complete Time evolution instead of the CCA',verb_level=V_real_time)
 !
 call it('f',defs,'InducedField','[RT] Include induced field in coupling and current',verb_level=V_real_time)
 call it('f',defs,'VelGaugeCorr','[RT] Correct the non local term of the pseudo with the vector potential',verb_level=V_real_time)
 !
 ! OLD / EXPERIMENTAL
 !
 call it(defs,'RTAveDeph',    '[RT] Dephasing for all elements not included in RTDePhMatrix', &
&                             RT_ave_dephasing,verb_level=V_real_time,unit=Time_unit(1))
 call it('f',defs,'LifeFitTemp','[RT] Fit on the fly  lifetimes ratio to a Fermi distribution',verb_level=V_real_time)
 !
#endif
 !
#if defined _NL
 !
 ! Non-linear Optics
 !
 call it(defs,'NLBands',      '[NL] Bands range',NL_bands)
 call it(defs,'NLverbosity',  '[NL] Verbosity level (low | high)',NL_verb_name) 
 call it(defs,'NLstep',       '[NL] Time step length',RT_step,unit=Time_unit(1),Verb_level=V_nl_optics)
 call it(defs,'NLtime',       '[NL] Simulation Time',NE_tot_time,unit=Time_unit(1))
 call it(defs,'NLintegrator', '[NL] Integrator ("EULEREXP/RK2/RK4/RK2EXP/HEUN/INVINT/CRANKNIC")',Integrator_name)
 call it(defs,'NLCorrelation','[NL] Correlation ("IPA/HARTREE/TDDFT/LRC/LRW/JGM/SEX/LSEX/LHF") ',NL_correlation)
 call it(defs,'NLLrcAlpha',   '[NL] Long Range Correction',NL_LRC_alpha)
 call it(defs,'NLDamping',    '[NL] Damping (or dephasing)',NL_damping,unit=E_unit)
 call it(defs,'NLEnRange',    '[NL] Energy range (for loop on frequencies NLEnSteps/=0',NL_er,E_unit)
 call it(defs,'NLAngSteps',   '[NL] Angular steps (if NLAngSteps/=0 field versor will be ignored)',n_angles)
 call it(defs,'NLrotaxis',    '[NL] Rotation axis (for the loop on angles NLAngSteps/=0)',NL_rot_axis)
 call it(defs,'NLEnSteps',    '[NL] Energy steps for the loop on frequencies',n_frequencies)
 call it('f',defs,'UseDipoles','[NL] Use Covariant Dipoles (just for test purpose)',verb_level=V_nl_optics)
 call it('f',defs,'TestOSCLL','[NL] Test Oscillators vs Full Collisions [for testing purposes]',verb_level=V_nl_optics)
 call it('f',defs,'FrSndOrd','[NL] Force second order in Covariant Dipoles',verb_level=V_nl_optics)
 call it('f',defs,'NoComprCOLL','[NL] Load collisions in double-precision and do not remove small elements (default false)',&
&  verb_level=V_nl_optics)
 call it('f',defs,'EvalCurrent','[NL] Evaluate the current')
 call it('f',defs,'SaveVbhistory',  '[RT] Save the history of the wave-functions function',Verb_level=V_nl_optics)
 !
#endif
 !
#if defined _RT || defined _NL
 !
 ! External fields
 !
 if (initmode==4.and..not.infile_editing) n_ext_fields=0
 do i_field=1,n_ext_fields_max
   call Afield(defs,i_field)
 enddo
 !
#endif
 !
#if defined _SC
 call it(defs,'ExtF_Dir',             '[NL ExtF] Versor',Efield(1)%versor)
 call it(defs,'ExtF_Int',             '[NL ExtF] Intensity',Efield(1)%intensity,unit=I_unit)
 call it(defs,'ExtF2_Dir',             '[NL ExtF] Versor',Efield(2)%versor,verb_level=V_nl_optics)
 call it(defs,'ExtF2_Int',             '[NL ExtF] Intensity',Efield(2)%intensity,unit=I_unit,verb_level=V_nl_optics)
 call it('f',defs,'FrSndOrd','[NL] Force second order in Covariant Dipoles',verb_level=V_sc)
#endif
 !
#if defined _SC
 call it(defs,'Hamiltonian',   '[MAG] Hamiltonian kind [pauli,landau,all]',MAG_hamiltonian_type,protect=.FALSE.)
 call it(defs,'B_Field',       '[MAG] Magnetic field modulus',MAG_B,unit=Bfield_unit)
 call it(defs,'B_psi',         '[MAG] Magnetic field psi angle',MAG_psi,unit=Angle_unit(1),verb_level=V_sc)
 call it(defs,'B_theta',       '[MAG] Magnetic field theta angle',MAG_theta,unit=Angle_unit(1),verb_level=V_sc)
 call it(defs,'B_Gauge',       '[MAG] Gauge ("SYMM"etric, "X_ASYMM", "Y_ASYMM" or "Z_ASYMM"etric)',MAG_gauge,verb_level=V_sc)
 call it('f',defs,'PhaseTrick','[MAG] Phase trick for a better diagonalization',verb_level=V_sc)
 call it(defs,'B_radius',      '[MAG] Magnetic flux radius',MAG_radius,verb_level=V_sc)
#endif
 !
#if defined _PHEL 
 call it(defs,'PHDbGdsize', '[PHEL] Size of subset of double grid k-points',PH_DbGd_points)
 call it(defs,'PHELQpts',   '[PHEL] Q-points considered',PH_Q)
 call it(defs,'PHELTrans',  '[PHEL] Energy window around W_ph to select transitions (units of GDamping)',PHEL_broad_factor)
 call it(defs,'PHEL_QPH_En','[PHEL] Energy points to get the Quasi-Phonon solution (units of the bare PH energy)',PHEL_fit_Energies)
 call it(defs,'PH_SE_mode', '[PHEL] Self-Energy scattering mode ("bare-bare","dressed-bare","dressed-dressed")',PH_Self_Energy_mode)
#endif
 !
#if defined _RT
 !
 ! RT ctl 
 !
 call INIT_RT_ctl_load(defs,1)
 call INIT_RT_ctl_load(defs,2)
 call INIT_RT_ctl_load(defs,3)
 !
#endif
 !
#if defined _NL || defined _ELECTRIC
 call it('f',defs,'EvPolarization','[DIP] Evaluate Polarization (require DipApproach=Covariant)',verb_level=V_resp)
 call it('f',defs,'FrPolPerdic','[DIP] Force periodicity of polarization respect to the external field')
#endif
#if defined _RT
 call it('f',defs,'SPINprojected', '[DIP] Project the spin dipoles in the c/v channels ',verb_level=V_real_time)
#endif
 !
 ! El-Ph
 !
#if defined _ELPH 
 call it(defs,'GphBRnge',  '[ELPH] G[W] bands range',QP_PH_n_G_bands)
 call it(defs,'ElPhModes', '[ELPH] Phonon modes included',elph_branches)
 call it(defs,'FANdEtresh','[ELPH] Energy treshold for Fan denominator',FAN_deltaE_treshold,verb_level=V_ph,unit=E_unit)
 call it(defs,'DWdEtresh', '[ELPH] Energy treshold for DW denominator',DW_deltaE_treshold,verb_level=V_ph,unit=E_unit)
 call it(defs,'GkkpDB',    '[ELPH] GKKP database (gkkp | gkkp_expanded | genFroh )',gkkp_db,verb_level=V_ph)
 call it(defs,'ElPhHBRnge','[ELPH] Hamiltonian bands range',elph_Ham_bands)
 call it(defs,'ElPhHKpt',  '[ELPH] Hamiltonian k-point',elph_Ham_ik)
 call it(defs,'REStresh',  '[ELPH] Residual treshold to report in output files',RES_tresh)
 call it('f',defs,'WRgFsq','[ELPH] Dump on file gFsq coefficients')
#endif
 ! 
 ! SC
 !
#if defined _SC
 !
 call it(defs,'SCBands',   '[SC] Bands',SC_bands)
 !
 call TMP_mirror_bands( )
 !
 call it(defs,'SCIter',    '[SC] SC Iterations',SC_iterations)
 call it(defs,'SCRhoTresh','[SC] Rho convergence threshold',SC_rho_threshold)
 call it(defs,'SC_precondition','[SC] Kind of preconditionin: thomas-fermi, simple, none',SC_preconditioning,verb_level=V_sc)
 call it(defs,'SCUpWIter', "[SC] Update W(q,G,G') every SCUpWIter iteractions",SC_up_W_iters,verb_level=V_qp) 
 call it('f',defs,'Mean_Potential','[SC] Real-space Mean Potential',verb_level=V_sc)
 call it('f',defs,'SCnlMix','[SC] Use SC non-local mixing',verb_level=V_sc)
 call it('f',defs,'FrozeDensity','[NL] Do not update density (for testing purposes)',verb_level=V_sc)
 !
 ! SC [NEQ]
 !
 call it(defs,'SCneqKIND',  '[SC] Options are [contrained-occ/constrained-mu/matsubara]',SC_neq_kind,verb_level=V_sc)
 call it(defs,'SCmu',       '[SC] Reference / holes / electrons chem potential',SC_mu,unit=E_unit,verb_level=V_sc)
 call it(defs,'SCcohIt',    '[SC] Impose off-diagonal rho in the initial basis set for N iterations',SC_last_coh_it,verb_level=V_sc)
 ! 
 ! SC [common with RT]
 !
 call it(defs,'BandMix',   '[SC] Band mixing',SC_band_mixing)
 call it(defs,'SCmixing',  '[SC] SC Cycle Mixing (< 1.)',SC_cycle_mixing,verb_level=V_sc)
 call it('f',defs,'SCdiag','[SC] Diagonal approximation for the self-energy(WF unchaged)',verb_level=V_sc)
 ! 
 call it(defs,'SCEtresh',  '[SC] Energy convergence threshold for SC-GW',SC_E_threshold,unit=E_unit,verb_level=V_qp)
 !
#endif
 !
#if defined _SC || defined _RT || defined _QED
 !
 ! SC and RT common
 !
 call it(defs,'COLLBands',   '[COLL] Bands for the collisions',COLL_bands)
 !
 call TMP_mirror_bands( )
 !
 call it(defs,'HXC_Potential',  '[SC] SC HXC Potential',H_potential,protect=.FALSE.,case="A")
 call it(defs,'COLLCut',        '[SC,RT] Cutoff on the collisions, 0=full 1=none',COLLISIONS_cutoff,verb_level=V_sc)
 call it('f',defs,'COLLBseMem', '[SC,RT] Minimize memory use in bse kernel conversion',verb_level=V_sc)
 !
#endif
 !
#if defined _RT
 call TMP_mirror_bands( )
#endif
 !
#if defined _SC
 call it('f',defs,'OEPItSolver','[SC] Iterative solution instead of inversion of OEP')
 call it(defs,'OEPapprox','[SC] OEP approximation: n=none s=Slater k=KLI c=CED +w=Weighted',OEP_approx)
#endif
 !
 call DIP_mirror_bands_and_Qs(en)
 ! 
 contains 
   !
   subroutine DIP_mirror_bands_and_Qs(E_in)
     !
     use parser_m,       ONLY:parser
     !
     type(levels), intent(in) :: E_in
     !
     logical :: is_def(16)
     integer :: i1,bands(2),tmp_bands(2)
     !
     if (initmode/=4) return
     !
     is_def=.false.
     !
     call parser('BndsRnXx', is_def(1))
     call parser('BndsRnXs', is_def(2))
     call parser('BndsRnXd', is_def(3))
     call parser('BndsRnXp', is_def(4))
     call parser('BndsRnXm', is_def(5))
     call parser('DipBands', is_def(6))
     call parser('BSEBands', is_def(7))
     call parser('RTBands',  is_def(8))
     call parser('SCBands',  is_def(9))
     call parser('NLBands',  is_def(10))
     call parser('COLLBands',is_def(11))
     call parser('el_photon_corr',is_def(12))
     if (is_def(12)) call parser('life',is_def(12))
     call parser('QpntsRXd',is_def(13))
     call parser('QpntsRXs',is_def(14))
     call parser('QpntsRXx',is_def(15))
     call parser('BSEQptR', is_def(16))
     !
     ! Q's
     !
     if (is_def(13).and.runlevel_is_on('optics')) Dip%iq=X(3)%iq
     if (is_def(13).and.runlevel_is_on('em1d')  ) Dip%iq=X(3)%iq
     if (is_def(13).and.runlevel_is_on('ppa')   ) Dip%iq=X(4)%iq
     if (is_def(13).and.runlevel_is_on('mpa')   ) Dip%iq=X(5)%iq
     if (is_def(14)                             ) Dip%iq=X(2)%iq
     if (is_def(15)                             ) Dip%iq=X(1)%iq
     if (is_def(16).and..not.(runlevel_is_on('ppa').or.runlevel_is_on('em1s').or.runlevel_is_on('mpa') )) Dip%iq=BS_q
     !
     ! Bands
     !
     bands=-1 
     do i1=1,11
       if(.not.(is_def(i1))) cycle
       if(i1< 6) tmp_bands=X(i1)%ib
       if(i1==6) tmp_bands=Dip%ib
       if(i1==7) tmp_bands=BS_bands
#if defined _RT || defined _NL
       if(i1==8) tmp_bands=RT_bands
#endif
#if defined _SC
       if(i1==9) tmp_bands=SC_bands
#endif
#if defined _NL
       if(i1==10) tmp_bands=NL_bands
#endif
#if defined _RT || defined _SC || defined _NL
       if(i1==11) tmp_bands=COLL_bands
#endif
#if defined _QED
       if(i1==12) tmp_bands=QP_n_G_bands
#endif
       if(any((/bands==-1/))) then
         bands(1)=max(tmp_bands(1),   1   )
         bands(2)=min(tmp_bands(2),E_in%nb)
       else
         bands(1)=max(min(tmp_bands(1),bands(1)),   1   )
         bands(2)=min(max(tmp_bands(2),bands(2)),E_in%nb)
       endif
     enddo
     !
     Dip%ib=bands
     !
   end subroutine
   !
#if defined _SC || defined _RT || defined _QED
   !TMP>
   subroutine TMP_mirror_bands( )
     use parser_m,       ONLY:parser
     logical :: is_def(4)
     integer :: bands_(2)
     !
     if(initmode/=4) return
     !
     call parser('SCBands',  is_def(1))
     call parser('RTBands',  is_def(2))
     call parser('COLLBands',is_def(3))
     call parser('NLBands',  is_def(4))
#endif
     !
#if defined _SC 
     if (is_def(1)) bands_=SC_bands
#endif
#if defined _RT || defined _QED
     if (is_def(2)) bands_=RT_bands
#endif
#if defined _SC || defined _RT || defined _QED || defined _NL
     if (is_def(3)) bands_=COLL_bands
#endif
#if defined _NL
     if (is_def(4)) bands_=NL_bands
#endif
     !
#if defined _SC 
     SC_bands  =bands_
#endif
#if defined _RT || defined _QED
     RT_bands  =bands_
#endif
#if defined _NL
     NL_bands  =bands_
#endif
#if defined _SC || defined _RT || defined _QED || defined _NL
     COLL_bands=bands_
     H_ref_bands=bands_     
     !
   end subroutine
   !TMP<
#endif
   !
end subroutine
