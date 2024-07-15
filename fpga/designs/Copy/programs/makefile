# File bases
# BASES = Sys Mem UART
BASES = SPISYS Mem UART SPI

# Extensions
JACK_EXT = .jack
VM_EXT = .vm

# Tools
JACK_ANALYZER = ../../../../tools/Compiler/JackAnalyzer.py
VM_TRANSLATOR = ../../../../tools/VMTranslator/vm_translator.py
HACK_ASSEMBLER = ../../../../tools/Assembler/Assembler.py
# JACK_ANALYZER = ../../../../tools/IDE/main.py "compile"
# VM_TRANSLATOR = ../../../../tools/IDE/main.py "translate"
# HACK_ASSEMBLER = ../../../../tools/IDE/main.py "assemble"

# File lists
JACK_FILES = $(addsuffix $(JACK_EXT), $(BASES))
VM_FILES = $(addsuffix $(VM_EXT), $(BASES))
VM_FILE = combined.vm
ASM_FILE = combined.asm
HEX_FILE = combined.hex
BIN_FILE = combined.hack

# Default target
all: compile translate assemble

# Pattern rule to compile .jack files to .vm files
%.vm: %.jack
	python3 $(JACK_ANALYZER) $<

# Target to combine .vm files into one .vm file
compile: $(VM_FILE)

$(VM_FILE): $(VM_FILES)
	cat $(VM_FILES) > $(VM_FILE)

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
	rm -f $(BIN_FILE) $(HEX_FILE) $(VM_FILES) $(VM_FILE) $(ASM_FILE) *.hack *.hex

.PHONY: all clean compile translate assemble
