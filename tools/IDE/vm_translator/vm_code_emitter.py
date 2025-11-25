"""
VM Code Emitter
Generates Hack assembly code from VM commands
"""

from vm_translator.vm_constants import *


class VMCodeEmitter:
    """Emits assembly code for VM commands"""
    
    def __init__(self, output):
        """
        Initialize code emitter with output stream
        
        Args:
            output: Output stream for writing assembly code
        """
        self.file = output
        self.unique_num = 0
        self.source = ''
        self.function_calls = {}
        
        self._write_bootstrap_code()

    def _write_bootstrap_code(self):
        """Write VM bootstrap initialization code"""
        instructions = [
            "\t//System Init: Initialize VM, set SP=256",
            "\t@256",
            "\tD=A",
            "\t@SP",
            "\tM=D",
        ]
        # Set stack pointer to 256
        self._write_instructions(instructions)
        # Call Sys.init
        self.write_call('Sys.init', 0)

    def set_filename(self, filename):
        """Set source filename for static variables"""
        self.source = filename.split('/')[-1]

    def write_arithmetic(self, command):
        """
        Write assembly for arithmetic/logical command
        
        Args:
            command: Arithmetic command (add, sub, neg, etc.)
        """
        self._write_comment(command)
        instructions = self._generate_arithmetic_instructions(command, self.unique_num)
        self._write_instructions(instructions)

    def write_push_pop(self, command, segment, index):
        """
        Write assembly for push/pop command
        
        Args:
            command: C_PUSH or C_POP
            segment: Memory segment
            index: Segment index
        """
        seg_to_d, d_to_stack, stack_to_d, d_to_seg = self._generate_push_pop_snippets(segment, index)
        
        if segment == 'local':
            mem_seg = 'LCL'
        elif segment == 'argument':
            mem_seg = 'ARG'
        else:
            mem_seg = segment.upper()

        if command == C_PUSH:
            self._write_comment(f'push {segment}[{index}]')
            if segment == 'constant':
                instructions = [f'\t@{index}', '\tD=A', '\t\n'.join(d_to_stack)]
            elif segment == 'static':
                instructions = [f'\t@{self.source}.{index}', '\tD=M', '\t\n'.join(d_to_stack)]
            elif segment == 'pointer':
                instructions = ['\t@THIS' if index == 0 else '\t@THAT', '\tD=M', '\t\n'.join(d_to_stack)]
            else:
                instructions = ['\t\n'.join(seg_to_d).format(seg=mem_seg), '\t\n'.join(d_to_stack)]
            self._write_instructions(instructions)
        else:
            self._write_comment(f'pop {segment}[{index}]')
            if segment == 'static':
                instructions = ['\t\n'.join(stack_to_d), f'\t@{self.source}.{index}', '\tM=D']
            elif segment == 'pointer':
                instructions = ['\t\n'.join(stack_to_d), '\t@THIS' if index == 0 else '\t@THAT', '\tM=D']
            else:
                instructions = ['\t\n'.join(stack_to_d), '\t\n'.join(d_to_seg).format(seg=mem_seg)]
            self._write_instructions(instructions)

    def write_label(self, label):
        """Write assembly for label command"""
        self._write_comment(f'label {label}')
        instructions = [f'({label})']
        self._write_instructions(instructions)

    def write_goto(self, label):
        """Write assembly for goto command"""
        self._write_comment(f'goto {label}')
        instructions = [f'\t@{label}', '\t0;JMP']
        self._write_instructions(instructions)

    def write_if(self, label):
        """Write assembly for if-goto command"""
        self._write_comment(f'if-goto {label}')
        instructions = ['\t@SP', '\tAM=M-1', '\tD=M', f'\t@{label}', '\tD;JNE']
        self._write_instructions(instructions)

    def write_function(self, function, local_variables):
        """
        Write assembly for function declaration
        
        Args:
            function: Function name
            local_variables: Number of local variables
        """
        self._write_comment(f'function {function} {local_variables}')
        instructions = [f'({function})', '\t@SP', '\tD=M', '\t@LCL', '\tM=D']
        for _ in range(local_variables):
            instructions += ['\t@0', '\tD=A', '\t@SP', '\tM=M+1', '\tA=M-1', '\tM=D']
        self._write_instructions(instructions)

    def write_call(self, function, num_arguments):
        """
        Write assembly for function call
        
        Args:
            function: Function name
            num_arguments: Number of arguments
        """
        self._write_comment(f'//Function Call: Function Call {function} {num_arguments} Setup')
        try:
            self.function_calls[function] += 1
            call_num = self.function_calls[function]
        except (KeyError):
            self.function_calls[function] = 0
            call_num = 0
        return_address = f'{function}$ret.{call_num}'
        instructions = [
            f'\t@{return_address}', '\tD=A', '\t@SP', '\tM=M+1', '\tA=M-1', '\tM=D',
            f'\t//Function Call: Save Caller State',
            self._push_segment('LCL'), self._push_segment('ARG'),
            self._push_segment('THIS'), self._push_segment('THAT'),
            f"\t//Function Call: Reposition ARG and LCL, then call function",
            f'\t@{5 + num_arguments}', '\tD=A', '\t@SP', '\tD=M-D\t// ARG = SP - 5 - n_args',
            '\t@ARG', '\tM=D\t\t// Reposition ARG',
            '\t@SP', '\tD=M', '\t@LCL', '\tM=D\t\t// Reposition LCL',
            f'\t@{function}\t//Jump to function {function}', '\t0;JMP',
            f'({return_address})'
        ]
        self._write_instructions(instructions)

    @staticmethod
    def _push_segment(segment):
        """Generate code to push segment onto stack"""
        instructions = [
            f'\t@{segment}', '\tD=M', '\t@SP', '\tM=M+1\t// Increment SP',
            '\tA=M-1', f'\tM=D\t\t// Push {segment}'
        ]
        return '\n'.join(instructions)

    def write_return(self):
        """Write assembly for return command"""
        self._write_comment('return')
        instructions = [
            '\t@LCL', '\tD=M', '\t@R13', '\tM=D',
            '\t@5', '\tA=D-A', '\tD=M', '\t@R14', '\tM=D',
            '\t@SP', '\tA=M-1', '\tD=M', '\t@ARG', '\tA=M', '\tM=D',
            '\tD=A+1', '\t@SP', '\tM=D',
            '\t@R13', '\tAM=M-1', '\tD=M', '\t@THAT', '\tM=D',
            '\t@R13', '\tAM=M-1', '\tD=M', '\t@THIS', '\tM=D',
            '\t@R13', '\tAM=M-1', '\tD=M', '\t@ARG', '\tM=D',
            '\t@R13', '\tAM=M-1', '\tD=M', '\t@LCL', '\tM=D',
            '\t@R14', '\tA=M', '\t0;JMP'
        ]
        self._write_instructions(instructions)

    @staticmethod
    def _generate_arithmetic_instructions(command, unique_num):
        """Generate assembly instructions for arithmetic operations"""
        single_operand_prep = ['\t@SP', '\tA=M', '\tA=A-1']
        double_operand_prep = ['\t@SP', '\tM=M-1', '\tA=M', '\tD=M', '\tA=A-1']
        equality_operation = [
            '\tD=M-D', '\t@{op}_{unique}', '\tD;J{op}', '\tD=0',
            '\t@FINALIZE_{unique}', '\t0;JMP', '({op}_{unique})',
            '\tD=-1', '(FINALIZE_{unique})', '\t@SP', '\tA=M-1'
        ]
        instruction = []
        if command == 'neg' or command == 'not':
            instruction.append('\t\n'.join(single_operand_prep))
            if command == 'neg':
                instruction.append('\tM=-M')
            else:
                instruction.append('\tM=!M')
        else:
            instruction.append('\n'.join(double_operand_prep))
            if command == 'add':
                instruction.append('\tD=M+D')
            elif command == 'sub':
                instruction.append('\tD=M-D')
            elif command == 'and':
                instruction.append('\tD=M&D')
            elif command == 'or':
                instruction.append('\tD=M|D')
            else:
                instruction.append('\t\n'.join(equality_operation).format(op=command.upper(), unique=unique_num))
            instruction.append('\tM=D')
        return instruction

    @staticmethod
    def _generate_push_pop_snippets(segment, index):
        """Generate assembly snippets for push/pop operations"""
        seg_to_d = [
            f'\t@{index}', '\tD=A',
            '\t@' + ('5' if segment == 'temp' else '{seg}'),
            '\tA=D+' + ('A' if segment == 'temp' else 'M'), '\tD=M'
        ]
        d_to_stack = ['\t@SP', '\tM=M+1', '\tA=M-1', '\tM=D']
        stack_to_d = ['\t@SP', '\tM=M-1', '\tA=M', '\tD=M']
        d_to_seg = [
            '\t@R13', '\tM=D', f'\t@{index}', '\tD=A',
            '\t@' + ('5' if segment == 'temp' else '{seg}'),
            '\tD=D+' + ('A' if segment == 'temp' else 'M'),
            '\t@R14', '\tM=D', '\t@R13', '\tD=M', '\t@R14', '\tA=M', '\tM=D'
        ]
        return seg_to_d, d_to_stack, stack_to_d, d_to_seg

    def _write_comment(self, comment):
        """Write comment line to output"""
        self.file.write(f'\t// {comment}\n')

    def _write_instructions(self, instructions):
        """Write instructions to output"""
        self.file.write('\n'.join(instructions) + '\n')
        self.unique_num += 1

    def close(self):
        """Close output file if applicable"""
        if hasattr(self.file, 'close'):
            self.file.close()
