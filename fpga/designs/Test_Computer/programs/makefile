# File bases - can be overridden from parent makefile
# Example: make BASES="jack/demos/Sys jack/system/Mem jack/system/UART"
BASES ?= jack/demos/Sys jack/system/Mem jack/system/UART

# Extensions
JACK_EXT = .jack
VM_EXT = .vm

# Tools
JACK_ANALYZER = ../../../../tools/IDE/main.py "compile"
VM_TRANSLATOR = ../../../../tools/IDE/main.py "translate"
HACK_ASSEMBLER = ../../../../tools/IDE/main.py "assemble"

# File lists
JACK_FILES = $(addsuffix $(JACK_EXT), $(BASES))
VM_FILES = $(addsuffix $(VM_EXT), $(BASES))
VM_FILE = build/combined.vm
ASM_FILE = build/combined.asm
HEX_FILE = build/combined.hex
BIN_FILE = build/combined.hack

# Default target
all: compile translate assemble

# Target to compile and combine VM files
compile: $(VM_FILE)

$(VM_FILE): $(JACK_FILES)
	@echo "Compiling Jack files..."
	@for base in $(BASES); do \
		echo "  Compiling $$base.jack..."; \
		python3 $(JACK_ANALYZER) $$base.jack; \
	done
	@echo "Combining VM files..."
	@cat $(VM_FILES) > $(VM_FILE)

# Target to generate the .asm file from the combined .vm file
translate: $(ASM_FILE)

$(ASM_FILE): $(VM_FILE)
	python3 $(VM_TRANSLATOR) $(VM_FILE)

# Target to generate the .hack file from the .asm file
assemble: $(BIN_FILE)

$(BIN_FILE): $(ASM_FILE)
	python3 $(HACK_ASSEMBLER) $(ASM_FILE)

# Clean up generated files
clean:
	rm -f build/*.hack build/*.hex build/*.vm build/*.asm
	rm -f jack/demos/*.vm jack/system/*.vm
	rm -f *.vm *.hack *.hex *.asm

.PHONY: all clean compile translate assemble
