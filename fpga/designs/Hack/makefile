PROJ = Hack
DEVICE = hx1k

# Predefined configurations
CONFIG ?= sys

JACK_sys = jack/demos/Sys jack/system/Mem jack/system/UART
JACK_demo = jack/demos/demo_bluescreen jack/system/Mem jack/system/Screen

ASM_hello = programs/asm/helloworld.asm
ASM_echo = programs/asm/echo.asm
ASM_bluescreen = programs/asm/bluescreen.asm

FILES = $(or $(JACK_$(CONFIG)),$(ASM_$(CONFIG)),$(JACK_sys))

# Tool paths
TOOLS_PATH = ../../../tools/IDE/main.py

# Build directory
BUILD_DIR = programs/build

all: build

$(PROJ).vvp: $(PROJ).v
	iverilog -o $(PROJ).vvp -s $(PROJ)_tb $(PROJ)_tb.v

$(PROJ).vcd: $(PROJ).vvp
	vvp $(PROJ).vvp -t 10s

sim: $(PROJ).vvp
	vvp $(PROJ).vvp

view: $(PROJ).vcd
	gtkwave $(PROJ).vcd

# Compile .jack files to .vm (FILES = basenames without extension)
compile:
	@echo "Compiling: $(FILES)"
	@mkdir -p $(BUILD_DIR)
	@for file in $(FILES); do \
		echo "  programs/$$file.jack → programs/$$file.vm"; \
		python3 $(TOOLS_PATH) "compile" programs/$$file.jack; \
	done

# Translate .vm files to .asm (FILES = basenames without extension)
vmtranslate:
	@echo "Translating: $(FILES)"
	@mkdir -p $(BUILD_DIR)
	@cat $(addprefix programs/, $(addsuffix .vm, $(FILES))) > $(BUILD_DIR)/combined.vm
	@echo "  $(BUILD_DIR)/combined.vm → $(BUILD_DIR)/combined.asm"
	@python3 $(TOOLS_PATH) "translate" $(BUILD_DIR)/combined.vm

# Assemble .asm file to .hack (FILES = path to .asm file)
assemble:
	@echo "Assembling: $(FILES)"
	@mkdir -p $(BUILD_DIR)
	@python3 $(TOOLS_PATH) "assemble" $(FILES)
	@HACK_FILE=$$(dirname $(FILES))/$$(basename $(FILES) .asm).hack; \
	if [ "$$HACK_FILE" != "$(BUILD_DIR)/combined.hack" ]; then \
		cp $$HACK_FILE $(BUILD_DIR)/combined.hack; \
	fi
	@echo "  Output: $(BUILD_DIR)/combined.hack"

# Auto-detect and build
build:
	@if echo "$(FILES)" | grep -q "\.asm$$"; then \
		$(MAKE) build_asm; \
	else \
		$(MAKE) build_jack; \
	fi

# Build Jack files (full chain)
build_jack: compile vmtranslate
	@$(MAKE) FILES="$(BUILD_DIR)/combined.asm" assemble
	@echo "Build complete! Output: $(BUILD_DIR)/combined.hack"

# Build ASM file (direct assembly)
build_asm: assemble
	@echo "Build complete! Output: $(BUILD_DIR)/combined.hack"

$(PROJ).blif: $(PROJ).v
	rm -f *.blif *.asc *.bin
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $<

$(PROJ).asc: $(PROJ).pcf $(PROJ).blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

prog: build $(PROJ).bin
	@echo "Programming FPGA..."
	@if [ -f ../../../tools/winiceprogduino/winiceprogduino.exe ]; then \
		../../../tools/winiceprogduino/winiceprogduino.exe -I COM4 $(PROJ).bin; \
	else \
		echo "Error: No FPGA programmer found (iceprog or winiceprogduino.exe)"; \
		exit 1; \
	fi

# Show usage examples
help:
	@echo "Simple Makefile Usage"
	@echo "====================="
	@echo ""
	@echo "Predefined Configurations (CONFIG=<name>):"
	@echo "  Jack Configs:"
	@echo "    sys         - Sys + Mem + UART (default)"
	@echo "    demo        - demo_bluescreen + Mem + Screen"
	@echo "  ASM Configs:"
	@echo "    hello       - helloworld.asm"
	@echo "    echo        - echo.asm"
	@echo "    bluescreen  - bluescreen.asm"
	@echo ""
	@echo "Targets:"
	@echo "  build        - Full chain: compile → vmtranslate → assemble"
	@echo "  prog         - Build + synthesize + program FPGA"
	@echo "  compile      - Compile .jack → .vm"
	@echo "  vmtranslate  - Translate .vm → .asm"
	@echo "  assemble     - Assemble .asm → .hack"
	@echo "  sim          - Run Verilog simulation"
	@echo "  view         - View waveform"
	@echo "  clean        - Clean all build files"
	@echo ""
	@echo "Easy Usage (with CONFIG):"
	@echo "  make prog                    # Default (sys)"
	@echo "  make CONFIG=demo prog        # Demo bluescreen"
	@echo "  make CONFIG=hello prog       # Hello world ASM"
	@echo ""
	@echo "Custom Files (with FILES):"
	@echo "  make FILES=\"jack/demos/Sys jack/system/Mem\" build"
	@echo "  make FILES=\"programs/asm/custom.asm\" assemble"

clean:
	rm -f *.blif *.asc *.bin *.vvp *.vcd *.out
	rm -f $(BUILD_DIR)/*.vm $(BUILD_DIR)/*.asm $(BUILD_DIR)/*.hack
	rm -f programs/jack/demos/*.vm programs/jack/system/*.vm
	rm -f programs/asm/*.hack

.PHONY: all build compile vmtranslate assemble clean prog sim view help
