NAME ?= default

ifneq ($(filter sim view,$(MAKECMDGOALS)),)
  ifneq ($(NAME),default)
    override NAME := $(word 2, $(MAKECMDGOALS))
    $(eval $(NAME):;@:)
  endif
endif

TOP_MODULE = $(NAME)_tb
TEST_SRC= $(TOP_MODULE).v
OUTPUT_BIN = $(TOP_MODULE).vvp
OUTPUT_VCD = $(TOP_MODULE).vcd

all: $(OUTPUT_BIN) $(OUTPUT_VCD)

$(OUTPUT_BIN): $(TEST_SRC) ../modules/$(NAME).v
	iverilog -o $(OUTPUT_BIN) -s $(TOP_MODULE) $(TEST_SRC)

$(OUTPUT_VCD): sim

sim: $(OUTPUT_BIN)
	vvp $(OUTPUT_BIN)

view: $(OUTPUT_VCD)
	gtkwave $(OUTPUT_VCD)

clean:
	rm -f *.vvp *.vcd *.out *.log

.PHONY: all clean view