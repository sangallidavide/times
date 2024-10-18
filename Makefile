

info:
	@echo  "Real time dynamics, nonequilibrium physics and nonlinear optics with the TIMES suite"
	@echo 
	@echo  "  Possible <target>'s are: "
	@echo  "     all            build all executables"
	@echo  "     exatto         EXcitons at ATTOsecond time slace"
	@echo  "                    Propagates the one body density matrix under the action of externa fields"
	@echo  "     lumen          Non linear optics in the time domain"
	@echo  "                    propagates quasi-particle wavefunction with nonequilibrium Berry phase"
	@echo  "     floquet        Nonlinear optics in frequency domain"
	@echo  "                    solves self-consistent Floquet equations"
	@echo  "     deps           generate fortran dependencies"
	@echo  "     clean          clean sources"
	@echo  "     distclean      "

all: lumen exatto floquet

exatto:
	+$(MAKE) -C src/collisions
	+$(MAKE) -C src/hamiltonian
	+$(MAKE) -C src/exatto
#	cd src/exatto ; make exatto

lumen:
	+$(MAKE) -C src/common
	+$(MAKE) -C src/lumen
#	cd src/lumen ; make  lumen

floquet:
	+$(MAKE) -C src/common
	+$(MAKE) -C src/floquet

deps:
	if test -x ./config/makedeps.sh ; then ./config/makedeps.sh ; fi

clean:
	cd src/exatto       ; make clean
	cd src/collisions   ; make clean
	cd src/hamiltonian  ; make clean
	#cd src/lumen    ; make clean
	#cd src/floquet  ; make clean
	-rm -rf ./bin/*.x
	-rm -rf ./lib/*
	-rm -rf ./include/*

distclean: clean
#	-rm make.inc

