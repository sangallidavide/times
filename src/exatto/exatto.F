!                                                                       
!        Copyright (C) 2024 the TIMES team                         
!              http://www.                              
!                                                                       
! Authors (see AUTHORS file for details): DS
!                                                                       
! This file is distributed under the terms of the GNU                   
! General Public License. You can redistribute it and/or                
! modify it under the terms of the GNU General Public                   
! License as published by the Free Software Foundation;                 
! either version 2, or (at your option) any later version.              
!                                                                       
! This program is distributed in the hope that it will                  
! be useful, but WITHOUT ANY WARRANTY; without even the                 
! implied warranty of MERCHANTABILITY or FITNESS FOR A                  
! PARTICULAR PURPOSE.  See the GNU General Public License               
! for more details.                                                     
!                                                                       
! You should have received a copy of the GNU General Public             
! License along with this program; if not, write to the Free            
! Software Foundation, Inc., 59 Temple Place - Suite 330,Boston,        
! MA 02111-1307, USA or visit http://www.gnu.org/copyleft/gpl.txt.      
!                                                                       
program exatto
 !
 use R_lattice,     ONLY:bz_samp
 use electrons,     ONLY:levels
 use X_m,           ONLY:X_t
 use dipoles,       ONLY:DIPOLE_t 
 !
 implicit none
 !
 type(levels)     :: en
 type(bz_samp)    :: q,k               
 type(X_t)        :: X(5)
 type(DIPOLE_t)   :: Dip
 !
 call RT_driver(en,X(:2),k,q,Dip) 
 !
end program
