PROJ = Hack
DEVICE = CCGM1A1
# CCGM1A1 is the GateMate A1 device identifier

# OSS CAD Suite tools path
# Adjust this to match your installation location
OSS_CAD_SUITE = $(HOME)/oss-cad-suite
YOSYS = $(OSS_CAD_SUITE)/bin/yosys
NEXTPNR = $(OSS_CAD_SUITE)/bin/nextpnr-himbaechel
GMPACK = $(OSS_CAD_SUITE)/bin/gmpack
OPENFPGALOADER = $(OSS_CAD_SUITE)/bin/openFPGALoader
IVERILOG = $(OSS_CAD_SUITE)/bin/iverilog
VVP = $(OSS_CAD_SUITE)/bin/vvp
GTKWAVE = $(OSS_CAD_SUITE)/bin/gtkwave

# Flags
PNR_FLAGS = --device $(DEVICE) --router router2

all: $(PROJ).bit

# Synthesis using Yosys with GateMate target
$(PROJ).json: $(PROJ).v
	@echo "=== Synthesis with Yosys ==="
	@echo "Using: $(YOSYS)"
	$(YOSYS) -ql $(PROJ)_synth.log -p "read_verilog $(PROJ).v; synth_gatemate -top $(PROJ) -nomx8 -nomult -luttree -json $@"

# Place and Route using nextpnr-himbaechel with GateMate architecture
$(PROJ).asc: $(PROJ).json $(PROJ).ccf
	@echo "=== Place and Route with nextpnr-himbaechel ==="
	@echo "Using: $(NEXTPNR)"
	$(NEXTPNR) $(PNR_FLAGS) --json $(PROJ).json --vopt ccf=$(PROJ).ccf --vopt out=$(PROJ).asc

# Generate bitstream using gmpack
$(PROJ).bit: $(PROJ).asc
	@echo "=== Generating Bitstream with gmpack ==="
	@echo "Using: $(GMPACK)"
	$(GMPACK) $(PROJ).asc $(PROJ).bit

# Check if USB device is attached to WSL
check-usb:
	@echo "=== Checking USB Device Status ==="
	@if command -v lsusb >/dev/null 2>&1; then \
		if lsusb 2>/dev/null | grep -q "1209:c0ca"; then \
			echo "✓ DirtyJTAG device found!"; \
		else \
			echo "✗ DirtyJTAG device NOT found in WSL"; \
			echo ""; \
			echo "Please run this in Windows PowerShell (as Admin):"; \
			echo "  usbipd attach --wsl --busid 2-5"; \
			echo ""; \
			exit 1; \
		fi \
	else \
		echo "⚠ lsusb not installed, skipping USB check"; \
		echo "  (Install with: sudo apt-get install usbutils)"; \
		echo "  Assuming device is attached..."; \
	fi

# Show instructions for attaching USB
attach-help:
	@echo "=== USB Device Attachment Instructions ==="
	@echo ""
	@echo "The FPGA programmer needs to be attached to WSL."
	@echo ""
	@echo "Step 1: Open Windows PowerShell as Administrator"
	@echo "Step 2: Run this command:"
	@echo "        usbipd attach --wsl --busid 2-5"
	@echo ""
	@echo "Step 3: Come back here and run: make prog"
	@echo ""
	@echo "Tip: Keep a WSL terminal open to maintain the USB connection"

# Program the FPGA using openFPGALoader (JTAG to SRAM - volatile)
# Note: Use --cable dirtyJtag if your board uses DirtyJTAG (VID:PID 1209:c0ca)
#       Use -b gatemate_evb_jtag if your board uses standard FTDI interface
#       sudo is required for USB permissions in WSL
prog: $(PROJ).bit check-usb
	@echo "=== Programming FPGA via JTAG (SRAM) ==="
	@echo "Using: $(OPENFPGALOADER)"
	sudo $(OPENFPGALOADER) --cable dirtyJtag $(PROJ).bit

# Program the FPGA to SPI Flash (non-volatile - persists after power cycle)
flash: $(PROJ).bit
	@echo "=== Programming FPGA to SPI Flash ==="
	@echo "Using: $(OPENFPGALOADER)"
	sudo $(OPENFPGALOADER) --cable dirtyJtag -f $(PROJ).bit

# Simulation using iverilog (optional)
$(PROJ).vvp: $(PROJ).v
	iverilog -o $(PROJ).vvp -s $(PROJ)_tb $(PROJ)_tb.v

sim: $(PROJ).vvp
	vvp $(PROJ).vvp

view: $(PROJ).vcd
	gtkwave $(PROJ).vcd

# Clean build artifacts
clean:
	rm -f *.json *.asc *.bit *.vvp *.vcd *.log *.rpt

.PHONY: all clean prog flash sim view
