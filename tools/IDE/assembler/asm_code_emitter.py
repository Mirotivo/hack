"""
Assembler Code Emitter
Generates binary machine code from parsed assembly instructions
"""

from interfaces import ICodeEmitter


class AsmSymbolTable(dict):
    """Symbol table with predefined Hack assembly symbols"""
    
    def __init__(self):
        """Initialize with predefined symbols"""
        super().__init__()
        self.update({
            'SP': 0, 'LCL': 1, 'ARG': 2, 'THIS': 3, 'THAT': 4,
            'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3, 'R4': 4, 'R5': 5, 'R6': 6, 'R7': 7,
            'R8': 8, 'R9': 9, 'R10': 10, 'R11': 11, 'R12': 12, 'R13': 13, 'R14': 14, 'R15': 15,
            'ADDR_UART_RX': 0x0802, 'ADDR_UART_TX': 0x0803,
            'SCREEN': 0x4000, 'KBD': 0x6000
        })

    def contains(self, symbol):
        """Check if symbol exists in table"""
        return symbol in self

    def add_entry(self, symbol, address):
        """Add symbol with address to table"""
        self[symbol] = address

    def get_address(self, symbol):
        """Get address for symbol"""
        return self[symbol]


class AsmCodeEmitter(ICodeEmitter):
    """Generates binary machine code from assembly instructions"""
    
    # Hack machine language encoding tables
    _jump_codes = ['', 'JGT', 'JEQ', 'JGE', 'JLT', 'JNE', 'JLE', 'JMP']
    _dest_codes = ['', 'M', 'D', 'MD', 'A', 'AM', 'AD', 'AMD']
    _comp_codes = {
        '0': '0101010', '1': '0111111', '-1':'0111010', 'D':'0001100', 'A': '0110000',
        '!D': '0001101', '!A': '0110001', '-D': '0001111', '-A': '0110011',
        'D+1': '0011111', 'A+1': '0110111', 'D-1': '0001110', 'A-1': '0110010',
        'D+A': '0000010', 'D-A': '0010011', 'A-D':'0000111', 'D&A': '0000000', 'D|A': '0010101',
        'M': '1110000', '!M': '1110001', '-M': '1110011', 'M+1': '1110111', 'M-1': '1110010',
        'D+M': '1000010', 'M+D': '1000010', 'D-M': '1010011', 'M-D': '1000111',
        'D&M': '1000000', 'D|M': '1010101'
    }

    def _bits(self, n):
        """Convert number to binary string"""
        return bin(int(n))[2:]

    def gen_a_instruction(self, address_value):
        """
        Generate A-instruction binary code
        
        Args:
            address_value: Address or constant value
            
        Returns:
            16-bit binary string
        """
        return '0' + self._bits(address_value).zfill(15)

    def gen_c_instruction(self, dest, comp, jump):
        """
        Generate C-instruction binary code
        
        Args:
            dest: Destination field
            comp: Computation field
            jump: Jump field
            
        Returns:
            16-bit binary string
        """
        comp_bits = self._comp_codes[comp]
        dest_bits = self._bits(self._dest_codes.index(dest)).zfill(3)
        jump_bits = self._bits(self._jump_codes.index(jump)).zfill(3)
        return '111' + comp_bits + dest_bits + jump_bits

    def emit_code(self, instruction):
        """
        Emit machine code for instruction
        
        Args:
            instruction: Assembly instruction string
            
        Returns:
            16-bit binary machine code
        """
        if instruction[0] == '@':
            return self.gen_a_instruction(instruction[1:])
        else:
            parts = instruction.split('=')
            if len(parts) == 2:
                dest, rest = parts
            else:
                dest, rest = '', parts[0]

            parts = rest.split(';')
            if len(parts) == 2:
                comp, jump = parts
            else:
                comp, jump = parts[0], ''

            return self.gen_c_instruction(dest, comp, jump)
