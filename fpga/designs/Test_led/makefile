PROJ = Hack
PIN_DEF = $(PROJ).pcf
DEVICE = hx1k

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $<
	# yosys -p 'synth_ice40 -top Hack -blif Hack.blif' Hack.v

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	../../../tools/winiceprogduino/winiceprogduino.exe -I COM8 $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin

.PHONY: all prog clean
