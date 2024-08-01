import argparse
import os
from commands import CompileCommand, TranslateCommand, AssembleCommand
from executor import CommandExecutor

def main():
    parser = argparse.ArgumentParser(description="nand2tetris tool")
    parser.add_argument("steps", help="Comma-separated list of steps to execute (compile, translate, assemble)")
    parser.add_argument("input", help="Input file or directory")
    args = parser.parse_args()

    step_map = {
        "compile": CompileCommand(),
        "translate": TranslateCommand(),
        "assemble": AssembleCommand()
    }

    steps = args.steps.split(',')
    commands = [step_map[step] for step in steps if step in step_map]

    executor = CommandExecutor(commands)
    result = executor.execute(args.input)

    # Determine the output extension based on the last step
    extension_map = {
        "compile": ".vm",
        "translate": ".asm",
        "assemble": ".hack"
    }
    last_step = steps[-1]
    output_extension = extension_map.get(last_step, ".out")

    # Determine the output file name
    input_file_name, _ = os.path.splitext(args.input)
    output_file = f"{input_file_name}{output_extension}"

    # Write the result to the output file
    with open(output_file, 'w') as f:
        f.write(result)

if __name__ == "__main__":
    main()
