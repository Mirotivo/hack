PROJ = Hack
PIN_DEF = $(PROJ).pcf
DEVICE = hx1k

all: prog

$(PROJ).blif: $(PROJ).v
	rm -f *.blif *.asc *.bin
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $<
	# @bash -c 'read -p "Press enter to continue..."'

$(PROJ).asc: $(PIN_DEF) $(PROJ).blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100
	# @bash -c 'read -p "Press enter to continue..."'

$(PROJ).bin: $(PROJ).asc
	icepack $< $@
	# @bash -c 'read -p "Press enter to continue..."'

prog: $(PROJ).bin
	../../../tools/winiceprogduino/winiceprogduino.exe -I COM4 $(PROJ).bin

clean:
	rm -f *.blif *.asc *.bin programs/*.hex programs/*.hack

.PHONY: all clean prog assemble

assemble:
	$(MAKE) -C programs clean
	$(MAKE) -C programs
	@bash -c 'read -p "Press enter to continue..."'
