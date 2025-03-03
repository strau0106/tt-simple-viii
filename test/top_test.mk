# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

WAVES ?= 1
SIM ?= icarus
SRC_DIR = $(PWD)/../src
MODULE_NAME ?= top
DUMPFILE = top_$(PROG)_dump.fst
PROG_FILE = top_ops_test.hex
PROJECT_SOURCES = packages/* modules/*v units/*.sv tt_um_strau0106_simple_viii.v
TOPLEVEL_LANG = verilog


COMPILE_ARGS +=  -DPROG_FILE=\"$(PROG_FILE)\"

COMPILE_ARGS +=  -DDUMPFILE=\"$(DUMPFILE)\"

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
ifeq ($(NL),pnl) 
COMPILE_ARGS    += -DGL_PNL_TEST
COMPILE_ARGS		+= -DUSE_POWER_PINS
endif
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v



VERILOG_SOURCES += ../runs/wokwi/final/$(NL)/tt_um_strau0106_simple_viii.$(NL).v

endif

else

# Gate level simulation:
SIM_BUILD				= sim_build/top_gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS		+= -DGL_PNL_TEST
COMPILE_ARGS		+= -DUSE_POWER_PINS
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

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

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
