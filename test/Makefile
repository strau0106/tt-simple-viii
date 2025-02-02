.PHONY: all

%_results.xml:
	#make -f test_$*.mk clean
	make -f $*_test.mk
	mv results.xml $@

all: clean alu_results.xml
	cat *results.xml > results.xml

clean:
	rm *results.xml || true
