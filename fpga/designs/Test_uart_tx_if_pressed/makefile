PROJ = Hack
TOP_MODULE = $(PROJ)_tb
OUTPUT_BIN = $(TOP_MODULE).vvp
OUTPUT_VCD = $(TOP_MODULE).vcd
PIN_DEF = $(PROJ).pcf
DEVICE = hx1k

ASM_FILES := $(wildcard *.asm)

all: assemble $(OUTPUT_BIN) $(OUTPUT_VCD)

assemble: $(ASM_FILES)
	@echo "Running Python assembler for all .asm files..."
	@for asm in $(ASM_FILES); do \
		python3 ../../../tools/assembler/Assembler.py $$asm; \
	done

$(OUTPUT_BIN): assemble $(TOP_MODULE).v
	iverilog -o $(OUTPUT_BIN) -s $(TOP_MODULE) $(TOP_MODULE).v

$(OUTPUT_VCD): $(OUTPUT_BIN)
	vvp $(OUTPUT_BIN) -t 10s

%.blif: %.v
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $<
	# yosys -p 'synth_ice40 -top Hack -blif Hack.blif' Hack.v

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100

%.bin: %.asc
	icepack $< $@

sim: $(OUTPUT_BIN)
	vvp $(OUTPUT_BIN)

view: $(OUTPUT_VCD)
	gtkwave $(OUTPUT_VCD)

prog: assemble $(PROJ).bin
	../../../tools/winiceprogduino/winiceprogduino.exe -I COM4 $(PROJ).bin

clean:
	rm -f  *.hack *.blif *.asc *.bin   *.vvp *.vcd *.out

.PHONY: all clean view assemble prog
