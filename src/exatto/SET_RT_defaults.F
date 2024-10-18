!
! License-Identifier: GPL
!
! Copyright (C) 2006 The Yambo Team
!
! Authors (see AUTHORS file for details): AM
!
subroutine SET_RT_defaults(INSTR,IND,OD,COM_DIR)
 !
 use debug,      ONLY:dbg
 use pars,       ONLY:SP,cZERO
 use C_driver,   ONLY:code_branch
 use units,      ONLY:HA2EV,FS2AUT,kWCMm22AU
 use LOGO,       ONLY:ID_logo,ID_logo_stderr
 use global_XC,  ONLY:EXT_NONE
 use X_m,        ONLY:current_iq,self_detect_E_range,X_FILL_UP_matrix_only,eps_2_alpha,l_drude,&
&                     alpha_dim,use_X_DbGd,X_DbGd_nkpts,Chi_mode,skip_cond_sum_rule,&
&                     q_plus_G_direction,Q_Shift_Order,&
&                     l_X_terminator,X_terminator_E,global_gauge,&
&                     Chi_linalg_mode,X_use_lin_sys,X_use_gpu,X_DbGd_percentual
 use DIPOLES,    ONLY:use_covariant_approach,use_real_space_approach,&
&                     Vnl_commutator_warning,use_shifted_grids_approach,use_g_space_approach,&
&                     compute_P2_dipoles,compute_Spin_dipoles,compute_Orb_dipoles
 use QP_m,       ONLY:QP_dSc_steps,QP_n_W_freqs,QP_G_Zoom_treshold,&
&                     QP_dSc_test,QP_solver,QP_G_damp,QP_dSc_delta,&
&                     QP_cg_percent,QP_n_states,SC_E_threshold, &
&                     QP_Sc_steps,QP_G_er,QP_G_ir,QP_G_dr,SC_band_mixing,QP_G_solver,&
&                     COHSEX_use_empties,On_Mass_Shell_approx,&
&                     Vnlxc_kind,Vxc_kind,l_extended_output,l_GW_terminator,&
&                     GW_terminator_E
 use QP_CTL_m,   ONLY:QP_ctl_user,QP_ctl_DB_user
 use functions,  ONLY:bose_E_cut
 use D_lattice,  ONLY:i_space_inv,inv_index,n_atoms_species_max,n_atomic_species,mag_syms,&
&                     input_Tel_is_negative,non_periodic_directions,lattice,Bose_Temp,    &
&                     molecule_position,l_0D,l_1D,l_2D,l_3D
 use pseudo,     ONLY:pp_n_l_times_proj_max,pp_kbv_dim
 use R_lattice,  ONLY:n_g_shells,ng_closed,bse_scattering,coll_scattering,&
&                     Xk_grid_is_uniform,RIM_id_epsm1_reference,RIM_epsm1,&
&                     RIM_anisotropy,RIM_ng,RIM_W_ng,rimw_type,RIM_n_rand_pts,nqibz,q0_def_norm,&
&                     cutoff_presets,k_map,qindx_S_max_Go
 use electrons,  ONLY:n_spin,n_sp_pol,n_spinor,filled_tresh,l_spin_orbit,n_spin_den,eval_magn
 use parallel_m, ONLY:ncpu,CPU_str_reset,CREATE_hosts_COMM
 use com,        ONLY:isec,depth,secnm,previous_secmode,of_name,n_ofs_defined,of_opened,of_unit,max_open_ofs,&
&                     more_io_path,core_io_path,com_path,repfile,grid_paths,fat_log,exp_user
 use stderr,     ONLY:win_size,tty_size,logfile,set_real_printed_length,log_as_a_file
 use LIVE_t,     ONLY:log_line_to_dump,log_line,nhash,ct
 use wave_func,  ONLY:wf_ng,wf_norm_test,wf_nb_io,wf_nb_io_groups,WF,WF_buffer,WF_buffered_IO
 use FFT_m,      ONLY:fft_dim_loaded,fft_size,fft_dim,fft_multiplier
 use IO_m,       ONLY:io_reset,max_io_units,serial_number,frag_WF
 use BS_solvers, ONLY:BSS_mode,BSS_n_freqs,BSS_er,BSS_dr,BSS_P_dir,BSS_E_dir,BSS_Q_dir,&
&                     Haydock_threshold,Haydock_iterIO,Haydock_iterMAX,BSS_uses_DbGd,BSS_Wd,&
&                     BSS_damp_reference,BSS_Vnl_included,BSS_uses_GreenF,BSS_inversion_mode,&
&                     BSS_perturbative_width,K_INV_EPS,K_INV_PL,K_INV_PI_PH,BSS_desc
 use descriptors,ONLY:IO_desc_reset
#if defined _SLEPC && !defined _NL
 use BS_solvers, ONLY:BSS_slepc_extraction,BSS_slepc_ncv,BSS_slepc_tol,BSS_slepc_target_E,BSS_slepc_maxit,&
 &                    BSS_slepc_precondition,BSS_slepc_approach,BSS_slepc_matrix_format,BSS_slepc_mpd
#endif
 use BS,         ONLY:BS_n_g_W,BS_eh_en,BS_identifier,BS_q,BS_eh_win,MAX_BSK_LIN_size,&
&                     BS_K_dim,BS_not_const_eh_f,BSK_mode,l_BSE_kernel_complete,&
&                     BS_K_is_ALDA,BSE_mode,BSE_prop,BSE_L_kind,BS_K_cutoff,BS_perturbative_SOC,BSK_IO_mode
 use TDDFT,      ONLY:FXC_type,FXC_n_g_corr,FXC_mode,&
&                     FXC_per_memstps,FXC_LRC_alpha,FXC_PF_alpha,FXC_LRC_beta,FXC_SVD_digits,&
&                     FXC_is_retarded,TDDFT_mode
 use ACFDT,      ONLY:ACFDT_n_lambda,ACFDT_n_freqs,ACFDT_E_range
#if defined _ELPH 
 use ELPH,       ONLY:ph_modes,elph_nb,gsqF_energy_steps,eval_G_using_KK,use_PH_DbGd,EkplusQ_mode,gkkp_db,&
&                     elph_Ham_bands,elph_Ham_ik,elph_branches,RES_tresh,FAN_deltaE_treshold,DW_deltaE_treshold
#endif
 use zeros,      ONLY:zero_norm,k_iku_zero,k_rlu_zero,G_iku_zero,G_mod_zero,zero_dfl
 use memory,     ONLY:MEMs,LARGE_MEMs,N_MEM_max,N_MEM_SAVE_max,MEM_element_init
 use xc_functionals,  ONLY:GS_xc_FUNCTIONAL,GS_xc_KIND,GS_exx_FRACTION,GS_exx_SCREENING 
 use BS,         ONLY:l_BS_anomalous_Hall
 use PHOTOLUM,   ONLY:PL_weights
#if defined _SC 
 use SC,         ONLY:SC_iterations,SC_rho_threshold,SC_potential,OEP_approx,l_NSC_shot,&
&                     compatible_SC_DB,SC_cycle_mixing,SC_fft_size,found_SC_DB,&
&                     l_Mean_Potential,SC_up_W_iters,l_SC_diagonal,&
&                     l_SC_nl_mix,SC_kind,SC_perturbation,SC_desc,SC_neq_kind,SC_last_coh_it
#endif
#if defined _SC || defined _RT || defined _QED || defined _NL
 use collision_ext,  ONLY:COLLISIONS_naming,COLLISIONS_cutoff,COLLISIONS_CV_only, &
&                         COLLISIONS_load_SP,COLLISIONS_compr
 use hamiltonian,    ONLY:H_potential
#endif
#if defined _RT || defined _YPP_RT
 use RT_output_m,ONLY:n_RT_headings,N_RT_o_files,RT_o_file_long,RT_o_file_short,RT_o_file_is_open,&
&                     RT_headings,YPP_append,Gr_desc,TIME_STEP_desc,RT_desc
 use RT_control, ONLY:CARR_RT_IO_t,OBS_RT_IO_t,OUTPUT_RT_IO_t,Gless_RESTART_RT_IO_t,SAVE_G_history,RT_ctl_db,&
&                     Vbands_RT_IO_t,CACHE_OBS_last_point,CACHE_OBS_INTERVAL_time,CACHE_OBS_INTERVAL_time_INPUT,   &
&                     CACHE_OBS_steps,CACHE_OBS_steps_now,RT_NAN_found,SAVE_Vb_history
 use RT_lifetimes,ONLY:RT_life_extrap_times
 use real_time,  ONLY:RT_step,NE_steps,NE_time,Integrator_name,RT_deph_range,&
&                     Gr_kind,two_alpha,RAD_LifeTime,Phase_LifeTime,&
&                     NE_tot_time,NE_MEM_treshold,RT_eh_en,l_update_SOC,&
&                     DbGd_EE_percent,RT_scatt_tresh,integrator_step,RT_nk,&
&                     i_MEM_old,i_MEM_prev,i_MEM_now,G_MEM_steps,RT_step_manual_prefactor,&
&                     RT_deph_deg_thresh,RT_deph_cv_only,NE_time_step_update_manual,&
&                     NE_time_step_update_last_point,NE_time_step_update_jump,NE_time_step_update_jump_INPUT, &
&                     NE_initial_time_step_update,NE_step_update_treshold
 use fields,     ONLY:Efield,Efield_reset,n_ext_fields_max,n_ext_fields,A_vecpot_reset,   &
&                     A_tot,A_ind,A_ext,field_from_file_fname,field_from_file_steps
 use plasma,     ONLY:PLASMA_redux_percent
#endif
#if defined _NL
 use nl_optics,  ONLY:NL_correlation,NL_er,n_frequencies,NL_damping,NL_LRC_alpha,NL_initial_versor,     &
&                     NL_verb_name,NL_bands,NL_desc,n_angles,NL_rot_axis
 use fields,     ONLY:Efield,Efield_reset
#endif
#if defined _SC
 use magnetic,    ONLY:MAG_B,MAG_radius,MAG_hamiltonian_type,MAG_landau,MAG_pauli,&
&                      MAG_gauge,MAG_psi,MAG_theta,phase_trick
 use electric,    ONLY:l_P_periodic,l_force_SndOrd
#endif
#if defined _YAML_OUTPUT
 use com,         ONLY:depth_yaml
#endif
 use timing_m,    ONLY:timing_allocate,nclockx
 use openmp,      ONLY:OPENMP_initialize,OPENMP_update,master_thread,omp_is_off
 use cuda_m,      ONLY:cuda_setup,have_cuda
 !
 implicit none
 !
 character(*) :: INSTR,IND,OD,COM_DIR
 !
 ! Work Space 
 !
 integer           :: i1,i2
 !
 ! Printed reals format lengths 
 !
 include 'branch.inc'
 !
#if defined _RT
 !
 ! RT control
 !
 RT_ctl_db="none"
 !
#endif
 !
#if defined _ELPH 
 !
 ! ELPH
 !
 ph_modes=0
 elph_nb=0
 elph_branches=0
 gsqF_energy_steps=2
 eval_G_using_KK=.FALSE.
 elph_Ham_bands=0
 elph_Ham_ik=1
 RES_tresh=0.01_SP
 DW_deltaE_treshold=1.E-6_SP/HA2EV   ! This is a cutoff on electronic energy differences
 FAN_deltaE_treshold=1.E-6_SP/HA2EV  ! This is a cutoff on phonon energies
 use_PH_DbGd=.FALSE.
 EkplusQ_mode='interp' ! E(k+q) energies (interp | dftp )
 gkkp_db='gkkp'        ! gkkp_db ( gkkp | gkkp_expanded | genFroh )
 !
#endif
 !
#if defined _SC || defined _RT || defined _QED || defined _NL
 !
 call COLLISIONS_naming( 0 , "all" )
 !
 ! COLLISIONS I/O
 !
# if defined _PAR_IO
 COLLISIONS_cutoff=0.0000_SP
# else
 COLLISIONS_cutoff=0.0005_SP
# endif
 !
# if defined _NL
 COLLISIONS_cutoff=0.0005_SP
# endif
 !
 COLLISIONS_CV_only=.FALSE.
 COLLISIONS_load_SP=.FALSE.
 COLLISIONS_compr  =.FALSE.
 !
 H_potential="NONE"
 !
#endif
 !
#if defined _SC
 ! SC
 !
 SC_fft_size=0
 SC_iterations=100
 SC_cycle_mixing=0.5_SP
 SC_rho_threshold=1.E-5_SP
 SC_up_W_iters=0
 SC_potential='NONE'
 SC_kind=0
 SC_perturbation=EXT_NONE
 OEP_approx='n'
 compatible_SC_DB=.FALSE.
 found_SC_DB=.FALSE.
 l_Mean_Potential=.FALSE.
 l_SC_diagonal=.FALSE.
 l_SC_nl_mix =.FALSE.
 l_NSC_shot  =.FALSE.
 !
 SC_neq_kind   ='none'
 SC_last_coh_it=50
 !
 call IO_desc_reset(SC_desc)
 !
 l_P_periodic   =.FALSE.
 l_force_SndOrd =.FALSE.
 !
#endif
 !
#if defined _RT
 !
 ! Real Time
 !
 field_from_file_fname=""
 field_from_file_steps=0
 n_ext_fields=0
 do i1=1,n_ext_fields_max
   call Efield_reset(Efield(i1))
   Efield(i1)%t_initial=RT_step
 enddo
 !
 call A_vecpot_reset(A_tot)
 call A_vecpot_reset(A_ext)
 call A_vecpot_reset(A_ind)
 !
 ! RT dynamics 
 !
 l_update_SOC=.FALSE.
 !
 ! RT current 
 !
 RT_step_manual_prefactor=0._SP
 RT_step=0.010*FS2AUT
 NE_steps=1
 NE_time=0._SP
 NE_tot_time= 1000._SP*FS2AUT
 !
 NE_time_step_update_last_point = 1
 NE_time_step_update_jump       = 0._SP
 NE_time_step_update_jump_INPUT  = 0._SP
 NE_initial_time_step_update    = 0._SP
 NE_step_update_treshold        = 0.1_SP
 NE_time_step_update_manual     =-1.0_SP
 !
 CACHE_OBS_steps      = 0
 CACHE_OBS_steps_now  = 0
 CACHE_OBS_last_point = 0
 CACHE_OBS_INTERVAL_time       = 0._SP
 CACHE_OBS_INTERVAL_time_INPUT  = 0._SP
 !
 G_MEM_steps = 2
 i_MEM_old   = 0
 i_MEM_prev  = 0
 i_MEM_now   = 1
 !
 integrator_step=1
 Integrator_name='RK2'
 !
 RAD_LifeTime = 0._SP
#if defined _NL
 RAD_LifeTime = -1._SP*FS2AUT  ! Automatic set equal to the dephasing
#endif
 Phase_LifeTime = 0._SP
 RT_deph_deg_thresh = 1.E-5_SP
 RT_deph_cv_only =.FALSE.
 RT_deph_range=-1._SP
 !
 NE_MEM_treshold=0._SP
 RT_nk=0
 RT_eh_en=0._SP
 RT_scatt_tresh=-1._SP/HA2EV
 PLASMA_redux_percent=100._SP
 DbGd_EE_percent=0._SP
 !
 ! Scattering
 !
 RT_life_extrap_times(1)=-1._SP*FS2AUT
 RT_life_extrap_times(2)=-1._SP*FS2AUT
 !
 ! G_retarded
 !
 Gr_kind="HS"
 two_alpha=1
 !
 ! RT_ctl
 !
 OBS_RT_IO_t%INTERVAL_time_INPUT              =2.0_SP*FS2AUT
 CARR_RT_IO_t%INTERVAL_time_INPUT             =2.0_SP*FS2AUT
 OUTPUT_RT_IO_t%INTERVAL_time_INPUT           =0.1_SP*FS2AUT
 Gless_RESTART_RT_IO_t%INTERVAL_time_INPUT    =5.0_SP*FS2AUT
 Vbands_RT_IO_t%INTERVAL_time_INPUT           =5.0_SP*FS2AUT
 SAVE_G_history=.FALSE.
 SAVE_Vb_history=.FALSE.
 RT_NAN_found  =.FALSE.
 !
 ! RT_output
 !
 n_RT_headings=0
 N_RT_o_files=0
 RT_o_file_is_open=.FALSE.
 RT_o_file_long= " "
 RT_o_file_short= " "
 RT_headings= " "
 YPP_append=" "
 !
 call IO_desc_reset(RT_desc)
 call IO_desc_reset(Gr_desc)
 call IO_desc_reset(TIME_STEP_desc)
 !
#endif
 !
#if defined _NL
 !
 NE_tot_time   =  -1._SP*FS2AUT 
 Integrator_name='INVINT'
 NL_bands      =(/0,0/)
 NL_correlation="IPA"
 NL_er         =(/-1._SP,-1._SP/)/HA2EV
 n_frequencies =0
 n_angles      =0
 NL_rot_axis   =(/0._SP,0._SP,0._SP/)
 NL_initial_versor=(/0._SP,0._SP,0._SP/)
 NL_damping    =0.2_SP/HA2EV
 NL_LRC_alpha  =0._SP
 !
 field_from_file_fname=""
 field_from_file_steps=0
 do i1=1,n_ext_fields_max
   call Efield_reset(Efield(i1))
   Efield(i1)%t_initial=RT_step
   Efield(i1)%frequency=0.1_SP/HA2EV
   Efield(i1)%intensity=0.0_SP
   Efield(i1)%FWHM=2._SP*FS2AUT
   Efield(i1)%ef_name="none"
   Efield(i1)%versor =(/0._SP,0._SP,0._SP/)
   Efield(i1)%ef_pol ="linear"
 enddo
 !
 Efield(1)%versor =(/0._SP,0._SP,0._SP/)
 Efield(1)%intensity=1000._SP*kWCMm22AU
 Efield(1)%ef_name="SOFTSIN"
 NL_verb_name='high'
 !
 call IO_desc_reset(NL_desc)
 !
#endif
 !
#if defined _SC
 !
 ! Magnetic
 !
 MAG_B=0._SP
 MAG_radius=0._SP
 MAG_hamiltonian_type=' '
 MAG_pauli=.FALSE.
 MAG_landau=.FALSE.
 MAG_gauge='SYMM'
 MAG_psi=0._SP
 MAG_theta=0._SP
 phase_trick=.FALSE.
 !
#endif
 !
end subroutine
