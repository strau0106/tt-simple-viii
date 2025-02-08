.PHONY: all

%_test:
	make -f module_test.mk MODULE_NAME=${*}
	mv results.xml $*_results.xml

all: clean alu_test registers_test
	cat *results.xml > results.xml

clean:
	rm *.xml *.vcd *.fst *.dat || true
	rm -rf sim_build/ __pycache__/ || true
