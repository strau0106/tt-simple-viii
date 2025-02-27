.PHONY: all

%_top_test:
	make -f top_test.mk PROG=${*}
	mv results.xml $*_results.xml


%_unit_test:
	make -f $*_test.mk
	mv results.xml $*_results.xml


%_test:
	make -f module_test.mk MODULE_NAME=${*}
	mv results.xml $*_results.xml

all: clean alu_test registers_test mem_ctrl_test mem_unit_test ctrl_test ops_top_test
	cat *results.xml > results.xml

clean:
	rm *.xml *.vcd *.fst *.dat || true
	rm -rf sim_build/ __pycache__/ || true
