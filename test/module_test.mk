# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

WAVES ?= 1
SIM ?= icarus
SRC_DIR = $(PWD)/../src
MODULE_NAME ?= alu
PROJECT_SOURCES = packages/* modules/$(MODULE_NAME).sv
TOPLEVEL_LANG = verilog

# RTL simulation:
SIM_BUILD				= sim_build/$(MODULE_NAME)_$(SIM)

# Add verilog sources
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

# Add testbench
VERILOG_SOURCES += $(addprefix $(PWD)/,$(MODULE_NAME)_tb.sv)

COMPILE_ARGS 		+= -DSIM

# Include packages
COMPILE_ARGS 		+= -I$(SRC_DIR)/packages

# Verilator things
ifeq ($(SIM), verilator)
COMPILE_ARGS += -DVM_COVERAGE
EXTRA_ARGS			+= --timing --trace --trace-fst --coverage
endif

# Python Module
MODULE = $(MODULE_NAME)_test
# Verilog Toplevel
TOPLEVEL = $(MODULE_NAME)_tb

# MODULE is the basename of the Python test file
include $(shell cocotb-config --makefiles)/Makefile.sim
