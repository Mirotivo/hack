# executor.py
class CommandExecutor:
    def __init__(self, commands):
        self.commands = commands

    def execute(self, input_data):
        data = input_data
        for command in self.commands:
            data = command.execute(data)
        return data
