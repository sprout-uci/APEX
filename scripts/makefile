default :

install-clean :
	rm -rf ./verif-tools/verilog2smv-1.1.2 ./verif-tools/verilog2smv.sh	

install :
	cd verif-tools ; \
	tar -vxjf verilog2smv-1.1.2.tar.bz2 ; \
	cd verilog2smv-1.1.2 ; \
	sh build.sh ; \
	cp verilog2smv.sh ../

simple_app :
	sh build/run "simple_app" true

violation_forge_OR :
	sh build/run "violation_forge_OR" true

violation_forge_ER :
	sh build/run "violation_forge_ER" true

violation_forge_META :
	sh build/run "violation_forge_META" true

test :
	sh build/run "test" true

verify :
	sh verif-tools/run

clean :
	rm -rf simv *.mem pmem.inc stimulus.v tmp-build
