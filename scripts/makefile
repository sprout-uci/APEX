default :

install-clean :
	rm -rf ./verif-tools/verilog2smv-1.1.2 ./verif-tools/verilog2smv.sh	

install :
	cd verif-tools ; \
	tar -vxjf verilog2smv-1.1.2.tar.bz2 ; \
	cd verilog2smv-1.1.2 ; \
	sh build.sh ; \
	cp verilog2smv.sh ../

proxy :
	sh build/run "proxy" true

simple_app :
	sh build/run "simple_app" true

verify :
	sh verif-tools/run

clean :
	rm -rf simv *.mem pmem.inc stimulus.v tmp-build
