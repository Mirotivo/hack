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

# import argparse
# from assembler.asm_translator import AsmTranslator

# def main():
#     parser = argparse.ArgumentParser(description="nand2tetris assembler tool")
#     parser.add_argument("input", help="Input file or directory")
#     args = parser.parse_args()

#     translator = AsmTranslator()
#     translator.translate(args.input)

# if __name__ == "__main__":
#     main()

# # main.py
# import argparse
# from vm_translator.vm_translator import VMTranslator

# def main():
#     parser = argparse.ArgumentParser(description="nand2tetris VM Translator")
#     parser.add_argument("input", help="Input file or directory")
#     args = parser.parse_args()

#     translator = VMTranslator()
#     translator.translate(args.input)

# if __name__ == "__main__":
#     main()

# # main.py
# import argparse
# import os
# from compiler.jack_translator import JackTranslator

# def main():
#     parser = argparse.ArgumentParser(description="nand2tetris Jack Compiler")
#     parser.add_argument("input", help="Input file or directory")
#     parser.add_argument("-r", "--recursive", action="store_true", help="Process directories recursively")
#     args = parser.parse_args()

#     analyzer = JackTranslator()
#     paths = [args.input]
#     if args.recursive and os.path.isdir(args.input):
#         for root, _, files in os.walk(args.input):
#             paths.extend([os.path.join(root, file) for file in files if file.endswith(analyzer.ext)])
#     else:
#         if os.path.isdir(args.input):
#             paths = [os.path.join(args.input, file) for file in os.listdir(args.input) if file.endswith(analyzer.ext)]
#         elif not args.input.endswith(analyzer.ext):
#             print(f"Invalid input file: {args.input}")
#             return

#     for path in paths:
#         destPath = path.replace(analyzer.ext, analyzer.extP)
#         print(f"Processing {path}...")
#         analyzer.parse(path, destPath)
#         print(f"Output written to {destPath}")

# if __name__ == "__main__":
#     main()
