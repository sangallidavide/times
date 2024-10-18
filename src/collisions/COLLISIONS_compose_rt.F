!
! License-Identifier: GPL
!
! Copyright (C) 2015 The Yambo Team
!
! Authors (see AUTHORS file for details): CA AM DS
!
subroutine COLLISIONS_compose_rt(dG_avg)
 !
 ! HF/SEX(state) = - (0.,1.) * \sum_{n,n',q} COLLISIONS(n,n',q,state) x G_lesser(n,n',k-q)
 ! 
 use pars,             ONLY:SP,cZERO,cI
 use drivers,          ONLY:l_sc_fock,l_sc_coh,l_sc_sex,l_sc_exx,l_sc_hartree
 use collision_ext,    ONLY:HXC_COLL_element,COLL_bands,HXC_collisions,COLLISIONS_CV_only
 use electrons,        ONLY:spin,n_met_bands,n_full_bands
 use R_lattice,        ONLY:nXkibz
 use parallel_int,     ONLY:PP_redux_wait
 use parallel_m,       ONLY:PAR_COM_Xk_ibz_A2A,PAR_IND_Xk_ibz,PAR_IND_Bp_mat
 use hamiltonian,      ONLY:B_mat_index
 use real_time,        ONLY:RT_Vnl_xc,RT_bands
 use timing_m,         ONLY:timing
 !
 implicit none
 !
 complex(SP), intent(in)   :: dG_avg(RT_bands(1):RT_bands(2),RT_bands(1):RT_bands(2),nXkibz)
 !
 ! Work Space
 !
 integer           :: i_coll,i_comp,i_coll_mem,i_spin,i_n,i_m,i_kmq,ib,ibp,i_k
 logical           :: do_collisions(COLL_bands(1):COLL_bands(2),COLL_bands(1):COLL_bands(2),2)
 !
 if(.not.l_sc_fock.and..not.l_sc_coh.and..not.l_sc_sex.and..not.l_sc_exx.and..not.l_sc_hartree) return
 !
 call timing('COLLISIONS (compose)',OPR='start')
 !
 do_collisions=.false.
 !
 do ibp=COLL_bands(1),COLL_bands(2)
   do ib=COLL_bands(1),COLL_bands(2)
     if ( COLLISIONS_CV_only .and. (ib> maxval(n_met_bands)  .and. ibp>maxval(n_met_bands) )  ) cycle
     if ( COLLISIONS_CV_only .and. (ib<=minval(n_full_bands) .and. ibp<=minval(n_full_bands)) ) cycle
     do_collisions(ib,ibp,1)=.true.
     if (.not.PAR_IND_Bp_mat%element_1D( B_mat_index(ib,ibp,COLL_bands) ) ) cycle
     do_collisions(ib,ibp,2)=.true.
   enddo
 enddo
 !
 RT_Vnl_xc=cZERO
 !
 do i_coll=1,HXC_collisions%N
   !
   if (.not.HXC_collisions%PAR_IND%element_1D(i_coll)) cycle
   !
   i_k       =HXC_collisions%state(i_coll,3)
   i_n       =HXC_collisions%state(i_coll,1)
   i_m       =HXC_collisions%state(i_coll,2)
   i_spin    =HXC_collisions%state(i_coll,4)
   i_coll_mem=HXC_collisions%PAR_map(i_coll)
   !
   ! If the COLLISIONS are read from a DB with more bands than RT_bands:
   !
   if (i_n<RT_bands(1).or.i_n>RT_bands(2)) cycle
   if (i_m<RT_bands(1).or.i_m>RT_bands(2)) cycle
   !
   i_comp=0
   !
   do i_kmq=1,nXkibz
     !
     do ibp=COLL_bands(1),COLL_bands(2)
       do ib=COLL_bands(1),COLL_bands(2)
         !
         if (.not.do_collisions(ib,ibp,1)) cycle
         !
         if (HXC_COLL_element(i_coll_mem)%table(ib,ibp,i_kmq)=='f') cycle
         !
         i_comp=i_comp+1
         !
         if (.not.do_collisions(ib,ibp,2)) cycle
         !
         RT_Vnl_xc(i_n,i_m,i_k,i_spin)=RT_Vnl_xc(i_n,i_m,i_k,i_spin) &
&                                      -cI*HXC_COLL_element(i_coll_mem)%v_c(i_comp)*dG_avg(ib,ibp,i_kmq)
         !
       enddo
     enddo
     !
   enddo
   !
 enddo
 !
 call timing('COLLISIONS (compose)',OPR='stop')
 !
 call timing('COLLISIONS (sym-red)',OPR='start')
 !
 ! Redux over bands
 !==================
 call PP_redux_wait(RT_Vnl_xc,COMM=PAR_COM_Xk_ibz_A2A%COMM)
 !
 ! Symmetrization
 !================
 do i_k=1,nXkibz
   if (.not.PAR_IND_Xk_ibz%element_1D(i_k) ) cycle
   do i_n=COLL_bands(1),COLL_bands(2)
     RT_Vnl_xc(i_n,i_n,i_k,:)= real(RT_Vnl_xc(i_n,i_n,i_k,:))
     do i_m=i_n+1,COLL_bands(2)
       RT_Vnl_xc(i_m,i_n,i_k,:)=conjg(RT_Vnl_xc(i_n,i_m,i_k,:))
     enddo
   enddo
 enddo
 !
 ! Redux over kpts (is this needed?)
 !====================================
 !call PP_redux_wait(RT_Vnl_xc,COMM=PAR_COM_Xk_ibz_INDEX%COMM)
 !
 call timing('COLLISIONS (sym-red)',OPR='stop')
 !
end subroutine COLLISIONS_compose_rt
!
!
subroutine Build_dG_avg(dG_in,dG_avg)
 !
 use pars,             ONLY:SP,cZERO
 use drivers,          ONLY:l_sc_fock,l_sc_coh,l_sc_sex,l_sc_exx,l_sc_hartree
 use R_lattice,        ONLY:nXkibz
 use parallel_int,     ONLY:PP_redux_wait
 use parallel_m,       ONLY:PAR_COM_Q_INDEX,PAR_COM_Xk_ibz_INDEX,PAR_IND_Xk_ibz,PAR_G_k_range
 use real_time,        ONLY:RTibz,RT_bands
 use timing_m,         ONLY:timing
 !
 implicit none
 !
 complex(SP), intent(in)   :: dG_in(RT_bands(1):RT_bands(2),RT_bands(1):RT_bands(2),PAR_G_k_range(1):PAR_G_k_range(2))
 complex(SP), intent(out)  :: dG_avg(RT_bands(1):RT_bands(2),RT_bands(1):RT_bands(2),nXkibz)
 !
 ! Work Space
 !
 integer           :: i_k,i_k_RT
 !
 if(.not.l_sc_fock.and..not.l_sc_coh.and..not.l_sc_sex.and..not.l_sc_exx.and..not.l_sc_hartree) return
 !
 call timing('COLLISIONS (G average)',OPR='start')
 !
 dG_avg=cZERO
 !
 do i_k=1,nXkibz
   !
   if (.not.PAR_IND_Xk_ibz%element_1D(i_k) ) cycle
   !
   do i_k_RT=RTibz%k_range(i_k,1),RTibz%k_range(i_k,2)
     dG_avg(:,:,i_k)=dG_avg(:,:,i_k)+dG_in(:,:,i_k_RT)
   enddo
   !
   ! The 1/real(RT_k_FT%N_mapped(i_k),SP) factor is needed here because I'm integrating
   ! over kmq. With the DbGd the size of the integrating factor has to be reduced
   ! 
   dG_avg(:,:,i_k)=dG_avg(:,:,i_k)/real(RTibz%N_mapped(i_k),SP)/real(PAR_COM_Q_INDEX%n_CPU)
   !
 enddo
 !
 call PP_redux_wait(dG_avg,COMM=PAR_COM_Xk_ibz_INDEX%COMM)
 !
 call timing('COLLISIONS (G average)',OPR='stop')
 !
end subroutine Build_dG_avg
