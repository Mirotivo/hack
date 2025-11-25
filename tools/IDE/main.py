"""
Nand2Tetris IDE - Main Entry Point
Provides command-line interface for compile, translate, and assemble operations
"""

import argparse
import os
from commands import CompileCommand, TranslateCommand, AssembleCommand
from executor import CommandExecutor


def main():
    """
    Main function - parses arguments and executes the requested pipeline
    
    Supports comma-separated steps: compile, translate, assemble
    Example: python main.py compile,translate,assemble input.jack
    """
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="nand2tetris tool")
    parser.add_argument("steps", help="Comma-separated list of steps to execute (compile, translate, assemble)")
    parser.add_argument("input", help="Input file or directory")
    args = parser.parse_args()

    # Map step names to command objects
    step_map = {
        "compile": CompileCommand(),
        "translate": TranslateCommand(),
        "assemble": AssembleCommand()
    }

    # Build command chain from requested steps
    steps = args.steps.split(',')
    commands = [step_map[step] for step in steps if step in step_map]

    # Execute command chain
    executor = CommandExecutor(commands)
    result = executor.execute(args.input)

    # Determine output file extension based on final step
    extension_map = {
        "compile": ".vm",
        "translate": ".asm",
        "assemble": ".hack"
    }
    last_step = steps[-1]
    output_extension = extension_map.get(last_step, ".out")

    # Generate output filename
    input_file_name, _ = os.path.splitext(args.input)
    output_file = f"{input_file_name}{output_extension}"

    # Write result to output file
    with open(output_file, 'w') as f:
        f.write(result)


if __name__ == "__main__":
    main()
