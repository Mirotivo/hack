PROJ = Hack
DEVICE = hx1k

all: prog

$(PROJ).vvp: $(PROJ).v
	iverilog -o $(PROJ).vvp -s $(PROJ)_tb $(PROJ)_tb.v

$(PROJ).vcd: $(PROJ).vvp
	vvp $(PROJ).vvp -t 10s

sim: $(PROJ).vvp
	vvp $(PROJ).vvp

view: $(PROJ).vcd
	gtkwave $(PROJ).vcd


assemble:
	$(MAKE) -C programs clean
	$(MAKE) -C programs
	@bash -c 'read -p "Press enter to continue..."'


$(PROJ).blif: $(PROJ).v
	rm -f *.blif *.asc *.bin
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $<
	# @bash -c 'read -p "Press enter to continue..."'

$(PROJ).asc: $(PROJ).pcf $(PROJ).blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100
	# @bash -c 'read -p "Press enter to continue..."'

$(PROJ).bin: $(PROJ).asc
	icepack $< $@
	# @bash -c 'read -p "Press enter to continue..."'

prog: $(PROJ).bin
	../../../tools/winiceprogduino/winiceprogduino.exe -I COM3 $(PROJ).bin

clean:
	rm -f *.blif *.asc *.bin *.vvp *.vcd *.out programs/*.hex programs/*.hack

.PHONY: all clean prog sim view assemble prog
