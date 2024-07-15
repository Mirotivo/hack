PROJ = Hack
TOP_MODULE = $(PROJ)_tb
OUTPUT_BIN = $(TOP_MODULE).vvp
OUTPUT_VCD = $(TOP_MODULE).vcd
PIN_DEF = $(PROJ).pcf
DEVICE = hx1k

all: $(OUTPUT_BIN) $(OUTPUT_VCD)

$(OUTPUT_BIN): $(TOP_MODULE).v
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

prog: $(PROJ).bin
	../../../tools/winiceprogduino/winiceprogduino.exe -I COM3 $<

clean:
	rm -f  *.blif *.asc *.bin   *.vvp *.vcd *.out

.PHONY: all clean view