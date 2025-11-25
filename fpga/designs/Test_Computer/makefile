PROJ = Hack
DEVICE = hx1k

# Build Mode Configuration
# Usage: make MODE=<mode> prog
# Available modes:
#   combined_sys      - Jack: Sys + Mem + UART (default)
#   combined_demo     - Jack: demo_bluescreen + Mem + Screen
#   asm_bluescreen    - ASM: bluescreen.asm
#   asm_echo          - ASM: echo.asm
#   asm_helloworld    - ASM: helloworld.asm
#   empty_rom         - Empty ROM for testing

MODE ?= combined_sys

# Mode definitions: ROMFILE~BASES~ASM_FILE (using ~ as delimiter to avoid space issues)
MODE_combined_sys = programs/build/combined.hack~jack/demos/Sys jack/system/Mem jack/system/UART~
MODE_combined_demo = programs/build/combined.hack~jack/demos/demo_bluescreen jack/system/Mem jack/system/Screen~
MODE_asm_bluescreen = programs/build/bluescreen.hack~~programs/asm/bluescreen.asm
MODE_asm_echo = programs/build/echo.hack~~programs/asm/echo.asm
MODE_asm_helloworld = programs/build/helloworld.hack~~programs/asm/helloworld.asm
MODE_empty_rom = empty_rom.rom~~

# Parse mode configuration using shell to preserve spaces in BASES
MODE_CONFIG = $(MODE_$(MODE))
ROMFILE = $(shell echo "$(MODE_CONFIG)" | cut -d'~' -f1)
BASES = $(shell echo "$(MODE_CONFIG)" | cut -d'~' -f2)
ASM_FILE = $(shell echo "$(MODE_CONFIG)" | cut -d'~' -f3)

all: prog

$(PROJ).vvp: $(PROJ).v
	iverilog -o $(PROJ).vvp -s $(PROJ)_tb $(PROJ)_tb.v

$(PROJ).vcd: $(PROJ).vvp
	vvp $(PROJ).vvp -t 10s

sim: $(PROJ).vvp
	vvp $(PROJ).vvp

view: $(PROJ).vcd
	gtkwave $(PROJ).vcd

# Update Hack.v with selected ROMFILE
update_romfile:
	@echo "Building for MODE=$(MODE)"
	@echo "  ROMFILE: $(ROMFILE)"
	@echo "  BASES: $(BASES)"
	@echo "  ASM_FILE: $(ASM_FILE)"
	@sed -i 's|^`define ROMFILE.*|`define ROMFILE "../designs/Test_Computer/$(ROMFILE)"|g' $(PROJ).v

assemble: update_romfile
	$(MAKE) -C programs clean
ifneq ($(ASM_FILE),)
	@echo "Assembling ASM file: $(ASM_FILE)"
	python3 ../../../tools/IDE/main.py "assemble" $(ASM_FILE)
else
	@echo "Compiling Jack files with BASES: $(BASES)"
	$(MAKE) -C programs BASES="$(BASES)"
endif
	@bash -c 'read -p "Press enter to continue..."'

$(PROJ).blif: $(PROJ).v
	rm -f *.blif *.asc *.bin
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $<

$(PROJ).asc: $(PROJ).pcf $(PROJ).blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

prog: assemble $(PROJ).bin
	../../../tools/winiceprogduino/winiceprogduino.exe -I COM4 $(PROJ).bin

# Show available modes
help:
	@echo "Available build modes:"
	@echo "  make MODE=combined_sys prog      - Jack: Sys + Mem + UART (default)"
	@echo "  make MODE=combined_demo prog     - Jack: demo_bluescreen + Mem + Screen"
	@echo "  make MODE=asm_bluescreen prog    - ASM: bluescreen.asm"
	@echo "  make MODE=asm_echo prog          - ASM: echo.asm"
	@echo "  make MODE=asm_helloworld prog    - ASM: helloworld.asm"
	@echo "  make MODE=empty_rom prog         - Empty ROM"
	@echo ""
	@echo "Example: make MODE=asm_bluescreen prog"

clean:
	rm -f *.blif *.asc *.bin *.vvp *.vcd *.out
	$(MAKE) -C programs clean

.PHONY: all clean prog sim view assemble help update_romfile
