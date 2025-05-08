# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

WAVES ?= 0
SIM ?= icarus
SRC_DIR = $(PWD)/../src
MODULE_NAME ?= top
PROG_DUMPFILE = top_$(PROG)_dump.vcd
PROG_FILE = top_$(PROG)_test.hex
PROJECT_SOURCES = packages/* modules/*v units/*.sv tt_um_strau0106_simple_viii.v
TOPLEVEL_LANG = verilog



COMPILE_ARGS +=  -DPROG_FILE=\"top_prog.hex\"

COMPILE_ARGS +=  -DDUMPFILE=\"top_dump.vcd\"
COMPILE_ARGS += -DSCAN=YES

ifneq ($(GATES),yes)
ifneq ($(SYNTH),yes)

# RTL simulation:
SIM_BUILD				= sim_build/top_$(SIM)
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -DSIM
COMPILE_ARGS 		+= -I$(SRC_DIR)

else

NL ?= nl

SIM_BUILD				= sim_build/top_synth

COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v


VERILOG_SOURCES += ../runs/wokwi/final/$(NL)/tt_um_strau0106_simple_viii.$(NL).v

endif

else

SIM_BUILD        = sim_build/top_gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

VERILOG_SOURCES += $(addprefix $(PWD)/,top_tb.sv)
VERILOG_SOURCES += $(addprefix $(PWD)/,sim_qspi.v)

ifeq ($(SIM), verilator)
COMPILE_ARGS += -DVM_COVERAGE
EXTRA_ARGS			+= --timing --trace --trace-fst --coverage
endif


TOPLEVEL = top_tb

# MODULE is the basename of the Python test file
MODULE = top_$(PROG)_test


$(shell cp $(PROG_FILE) top_prog.hex)
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

$(shell mv top_dump.vcd top_$(PROG)_dump.vcd)
